import 'dart:async';
import 'dart:isolate';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'stockfish_wrapper.dart';
import 'move_classifier.dart';

/// Message types for Stockfish isolate communication.
enum StockfishMessageType { analyze, stop, quit }

class StockfishRequest {
  const StockfishRequest({
    required this.type,
    required this.fen,
    this.depth = 26,
    this.multiPv = 3,
    this.requestId = '',
    this.nnuePath,
  });

  final StockfishMessageType type;
  final String fen;
  final int depth;
  final int multiPv;
  final String requestId;
  final String? nnuePath;
}

class StockfishResponse {
  const StockfishResponse({
    required this.requestId,
    required this.fen,
    required this.lines,
    this.currentDepth = 0,
    this.isComplete = false,
    this.error,
  });

  final String requestId;
  final String fen;
  final List<EngineLineResult> lines;
  final int currentDepth;
  final bool isComplete;
  final String? error;
}

final engineLastResponseProvider = StreamProvider<StockfishResponse>((ref) {
  return StockfishIsolate.instance.responses;
});

/// Stockfish engine runner using real UCI wiring for both App and Web.
class StockfishIsolate {
  StockfishIsolate._();

  static final StockfishIsolate instance = StockfishIsolate._();

  Isolate? _isolate;
  SendPort? _sendPort;

  // Web specific instance
  Stockfish? _webEngine;
  StreamSubscription? _webSubscription;
  final Map<int, EngineLineResult> _webLines = {};
  String _webRequestId = '';
  String _webFen = '';
  int _webTargetDepth = 26;

  final StreamController<StockfishResponse> _responseController =
      StreamController.broadcast();

  Stream<StockfishResponse> get responses => _responseController.stream;

  bool _isRunning = false;
  bool get isRunning => _isRunning;

  Future<void> start() async {
    if (_isRunning) return;

    if (kIsWeb) {
      _startWeb();
      return;
    }

    final receivePort = ReceivePort();
    _isolate = await Isolate.spawn(
      _engineIsolateEntry,
      receivePort.sendPort,
      debugName: 'StockfishEngine',
    );

    receivePort.listen((message) {
      if (message is SendPort) {
        _sendPort = message;
        _isRunning = true;
      } else if (message is StockfishResponse) {
        _responseController.add(message);
      }
    });

    await Future.delayed(const Duration(milliseconds: 200));
  }

  void _startWeb() {
    _webEngine = Stockfish();
    _webSubscription = _webEngine!.stdout.listen((line) {
      if (line.startsWith('info')) {
        final parsed = _parseUciInfo(line);
        if (parsed != null) {
          final pvIndex = _extractInt(line, 'multipv') ?? 1;
          _webLines[pvIndex] = parsed;
          if (pvIndex == 1) {
            _emitResponse(StockfishResponse(
              requestId: _webRequestId,
              fen: _webFen,
              lines: _webLines.values.toList(),
              currentDepth: parsed.depth,
              isComplete: false,
            ));
          }
        }
      } else if (line.startsWith('bestmove')) {
        _emitResponse(StockfishResponse(
          requestId: _webRequestId,
          fen: _webFen,
          lines: _webLines.values.toList(),
          currentDepth: _webTargetDepth,
          isComplete: true,
        ));
      }
    });
    _isRunning = true;
  }

  void analyze(StockfishRequest request) {
    if (kIsWeb) {
      if (_webEngine == null) {
        _analyzePositionMock(request);
        return;
      }
      _webRequestId = request.requestId;
      _webFen = request.fen;
      _webTargetDepth = request.depth;
      _webLines.clear();

      _webEngine!.stdin = 'stop';
      if (request.nnuePath != null) {
        _webEngine!.stdin = 'setoption name EvalFile value ${request.nnuePath}';
      }
      _webEngine!.stdin = 'setoption name MultiPV value ${request.multiPv}';
      _webEngine!.stdin = 'position fen ${request.fen}';
      _webEngine!.stdin = 'go depth ${request.depth}';
      return;
    }
    _sendPort?.send(request);
  }

  void stop() {
    if (kIsWeb) {
      _webEngine?.stdin = 'stop';
      return;
    }
    _sendPort?.send(
      const StockfishRequest(
        type: StockfishMessageType.stop,
        fen: '',
        requestId: 'stop',
      ),
    );
  }

  Future<void> dispose() async {
    if (kIsWeb) {
      _webSubscription?.cancel();
      _webEngine?.dispose();
      _webEngine = null;
    } else {
      _sendPort?.send(
        const StockfishRequest(
          type: StockfishMessageType.quit,
          fen: '',
          requestId: 'quit',
        ),
      );
      _isolate?.kill(priority: Isolate.immediate);
      _isolate = null;
    }
    _isRunning = false;
    await _responseController.close();
  }

  void _analyzePositionMock(StockfishRequest request) {
    final thinkingTime = request.depth * 25;
    Future.delayed(Duration(milliseconds: thinkingTime), () {
      final hash = request.fen.hashCode;
      final baseEval = (hash % 400) - 200;
      final lines = List.generate(
        request.multiPv.clamp(1, 3),
        (i) => EngineLineResult(
          moves: ['e2e4', 'd2d4'],
          eval: (baseEval - i * 40).toDouble(),
          depth: request.depth,
        ),
      );
      _emitResponse(StockfishResponse(
        requestId: request.requestId,
        fen: request.fen,
        lines: lines,
        isComplete: true,
      ));
    });
  }

  void _emitResponse(StockfishResponse response) {
    if (!_responseController.isClosed) {
      _responseController.add(response);
    }
  }
}

void _engineIsolateEntry(SendPort mainSendPort) {
  final receivePort = ReceivePort();
  mainSendPort.send(receivePort.sendPort);

  try {
    final stockfish = Stockfish();

    Map<int, EngineLineResult> currentLines = {};
    String currentRequestId = '';
    String currentFen = '';
    int targetDepth = 26;

    stockfish.stdout.listen((line) {
      if (line.startsWith('info')) {
        final parsed = _parseUciInfo(line);
        if (parsed != null) {
          final pvIndex = _extractInt(line, 'multipv') ?? 1;
          currentLines[pvIndex] = parsed;

          if (pvIndex == 1) {
            mainSendPort.send(StockfishResponse(
              requestId: currentRequestId,
              fen: currentFen,
              lines: currentLines.values.toList(),
              currentDepth: parsed.depth,
              isComplete: false,
            ));
          }
        }
      } else if (line.startsWith('bestmove')) {
        mainSendPort.send(StockfishResponse(
          requestId: currentRequestId,
          fen: currentFen,
          lines: currentLines.values.toList(),
          currentDepth: targetDepth,
          isComplete: true,
        ));
      }
    }, onError: (e) {
      mainSendPort.send(StockfishResponse(
          requestId: currentRequestId,
          fen: currentFen,
          lines: [],
          error: e.toString()));
    });

    receivePort.listen((message) {
      if (message is! StockfishRequest) return;

      switch (message.type) {
        case StockfishMessageType.quit:
          try {
            stockfish.dispose();
          } catch (_) {}
          receivePort.close();
          return;
        case StockfishMessageType.stop:
          stockfish.stdin = 'stop';
          return;
        case StockfishMessageType.analyze:
          currentRequestId = message.requestId;
          currentFen = message.fen;
          targetDepth = message.depth;
          currentLines.clear();

          stockfish.stdin = 'stop';
          if (message.nnuePath != null) {
            stockfish.stdin =
                'setoption name EvalFile value ${message.nnuePath}';
          }
          stockfish.stdin = 'setoption name MultiPV value ${message.multiPv}';
          stockfish.stdin = 'position fen ${message.fen}';
          stockfish.stdin = 'go depth ${message.depth}';
      }
    });
  } catch (e) {
    mainSendPort.send(StockfishResponse(
        requestId: '', fen: '', lines: [], error: 'Engine Init Fail: $e'));
  }
}

EngineLineResult? _parseUciInfo(String line) {
  final depth = _extractInt(line, 'depth');
  if (depth == null) return null;

  double eval = 0.0;
  bool isMate = false;
  int? mateIn;

  if (line.contains('score cp')) {
    eval = _extractInt(line, 'cp')?.toDouble() ?? 0.0;
  } else if (line.contains('score mate')) {
    isMate = true;
    mateIn = _extractInt(line, 'mate');
    eval = (mateIn ?? 0) > 0 ? 10000.0 : -10000.0;
  }

  final pvMatch = RegExp(r' pv (.+)$').firstMatch(line);
  final pvMoves = pvMatch?.group(1)?.split(' ') ?? [];

  return EngineLineResult(
    moves: pvMoves,
    eval: eval,
    depth: depth,
    isMate: isMate,
    mateIn: mateIn,
  );
}

int? _extractInt(String line, String key) {
  final match = RegExp('$key (\\-?\\d+)').firstMatch(line);
  return match != null ? int.tryParse(match.group(1)!) : null;
}
