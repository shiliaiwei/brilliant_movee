import 'dart:async';
import 'dart:isolate';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'move_classifier.dart';

/// Message types for Stockfish isolate communication.
enum StockfishMessageType { analyze, stop, quit }

class StockfishRequest {
  const StockfishRequest({
    required this.type,
    required this.fen,
    this.depth = 22,
    this.multiPv = 3,
    this.requestId = '',
  });

  final StockfishMessageType type;
  final String fen;
  final int depth;
  final int multiPv;
  final String requestId;
}

class StockfishResponse {
  const StockfishResponse({
    required this.requestId,
    required this.fen,
    required this.lines,
    this.isComplete = false,
    this.error,
  });

  final String requestId;
  final String fen;
  final List<EngineLineResult> lines;
  final bool isComplete;
  final String? error;
}

/// Stockfish engine runner.
/// ARCH-04: Engine MUST NOT run on main UI thread (uses Isolate).
/// Web fallback: Runs directly in async tasks (as Stockfish isn't easily
/// usable on Web without WASM/Workers, this maintains simulation mode).
class StockfishIsolate {
  StockfishIsolate._();

  static final StockfishIsolate instance = StockfishIsolate._();

  Isolate? _isolate;
  SendPort? _sendPort;
  final StreamController<StockfishResponse> _responseController =
      StreamController.broadcast();

  Stream<StockfishResponse> get responses => _responseController.stream;

  bool _isRunning = false;
  bool get isRunning => _isRunning;

  Future<void> start() async {
    if (_isRunning) return;

    if (kIsWeb) {
      _isRunning = true;
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

    // Wait for isolate to be ready
    await Future.delayed(const Duration(milliseconds: 100));
  }

  void analyze(StockfishRequest request) {
    if (kIsWeb) {
      // Simulate engine thinking on Web directly
      _analyzePosition(request, null);
      return;
    }
    _sendPort?.send(request);
  }

  void stop() {
    if (kIsWeb) return;
    _sendPort?.send(
      const StockfishRequest(
        type: StockfishMessageType.stop,
        fen: '',
        requestId: 'stop',
      ),
    );
  }

  Future<void> dispose() async {
    if (!kIsWeb) {
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

  /// Internal bridge for Web to emit responses
  void _emitResponse(StockfishResponse response) {
    if (!_responseController.isClosed) {
      _responseController.add(response);
    }
  }
}

/// Isolate entry point — runs on separate thread.
void _engineIsolateEntry(SendPort mainSendPort) {
  final receivePort = ReceivePort();
  mainSendPort.send(receivePort.sendPort);

  receivePort.listen((message) {
    if (message is! StockfishRequest) return;

    switch (message.type) {
      case StockfishMessageType.quit:
        receivePort.close();
        return;
      case StockfishMessageType.stop:
        return;
      case StockfishMessageType.analyze:
        _analyzePosition(message, mainSendPort);
    }
  });
}

/// Simulates Stockfish analysis for development.
/// In production, this sends UCI commands to the Stockfish binary.
void _analyzePosition(StockfishRequest request, SendPort? sendPort) {
  // Simulate engine thinking time
  Future.delayed(const Duration(milliseconds: 200), () {
    // Generate mock engine lines based on FEN
    final lines = _generateMockLines(request.fen, request.multiPv);

    final response = StockfishResponse(
      requestId: request.requestId,
      fen: request.fen,
      lines: lines,
      isComplete: true,
    );

    if (sendPort != null) {
      sendPort.send(response);
    } else if (kIsWeb) {
      StockfishIsolate.instance._emitResponse(response);
    }
  });
}

List<EngineLineResult> _generateMockLines(String fen, int multiPv) {
  // Generate a pseudo-random but stable evaluation based on the FEN string
  final hash = fen.hashCode;
  final baseEval = (hash % 400) - 200; // Eval between -2.00 and +2.00

  return List.generate(
    multiPv.clamp(1, 3),
    (i) => EngineLineResult(
      moves: _generateMockMoves(fen, i),
      eval: (baseEval - i * 40).toDouble(),
      depth: 22,
    ),
  );
}

List<String> _generateMockMoves(String fen, int index) {
  // Very simple mock move generation
  final moves = [
    'e2e4',
    'd2d4',
    'g1f3',
    'b1c3',
    'e7e5',
    'd7d5',
    'g8f6',
    'b8c6'
  ];
  final start = (fen.length + index) % moves.length;
  return [moves[start], moves[(start + 1) % moves.length]];
}
