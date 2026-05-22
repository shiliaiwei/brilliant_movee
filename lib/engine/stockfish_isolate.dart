import 'dart:async';
import 'dart:isolate';
import 'move_classifier.dart';

/// Message types for Stockfish isolate communication.
enum StockfishMessageType { analyze, stop, quit }

class StockfishRequest {
  const StockfishRequest({
    required this.type,
    required this.fen,
    this.depth = 18,
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

/// Stockfish engine runner on a Dart Isolate.
/// ARCH-04: Engine MUST NOT run on main UI thread.
///
/// NOTE: In production, this would load the Stockfish 16 .so via dart:ffi.
/// This implementation provides the full UCI protocol interface and
/// simulates engine responses for development/testing.
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
    _sendPort?.send(request);
  }

  void stop() {
    _sendPort?.send(
      StockfishRequest(
        type: StockfishMessageType.stop,
        fen: '',
        requestId: 'stop',
      ),
    );
  }

  Future<void> dispose() async {
    _sendPort?.send(
      StockfishRequest(
        type: StockfishMessageType.quit,
        fen: '',
        requestId: 'quit',
      ),
    );
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _isRunning = false;
    await _responseController.close();
  }
}

/// Isolate entry point — runs on separate thread.
void _engineIsolateEntry(SendPort mainSendPort) {
  final receivePort = ReceivePort();
  mainSendPort.send(receivePort.sendPort);

  // In production: initialize Stockfish 16 via dart:ffi here
  // stockfish_ffi.init();

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
void _analyzePosition(StockfishRequest request, SendPort sendPort) {
  // Simulate engine thinking time
  Future.delayed(const Duration(milliseconds: 200), () {
    // Generate mock engine lines based on FEN
    final lines = _generateMockLines(request.fen, request.multiPv);

    sendPort.send(StockfishResponse(
      requestId: request.requestId,
      fen: request.fen,
      lines: lines,
      isComplete: true,
    ));
  });
}

List<EngineLineResult> _generateMockLines(String fen, int multiPv) {
  // Mock evaluation — in production this comes from Stockfish UCI output
  return List.generate(
    multiPv.clamp(1, 3),
    (i) => EngineLineResult(
      moves: ['e2e4', 'e7e5', 'g1f3'],
      eval: (50 - i * 30).toDouble(),
      depth: 18,
    ),
  );
}
