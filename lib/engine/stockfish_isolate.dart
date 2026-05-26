import 'dart:async';

import 'move_classifier.dart';

enum StockfishMessageType { analyze }

class StockfishRequest {
  final StockfishMessageType type;
  final String fen;
  final int depth;
  final int multiPv;
  final String requestId;
  final String? nnuePath;

  StockfishRequest({
    required this.type,
    required this.fen,
    required this.depth,
    required this.multiPv,
    required this.requestId,
    this.nnuePath,
  });
}

class StockfishResponse {
  final String requestId;
  final bool isComplete;
  final List<EngineLineResult> lines;

  StockfishResponse({
    required this.requestId,
    required this.isComplete,
    required this.lines,
  });
}

/// Minimal StockfishIsolate stub that simulates async analysis responses.
/// The real project may provide a native implementation; this keeps review
/// and analysis flow functional in environments without the engine.
class StockfishIsolate {
  StockfishIsolate._internal();

  static final StockfishIsolate instance = StockfishIsolate._internal();

  final StreamController<StockfishResponse> _responses =
      StreamController.broadcast();

  Stream<StockfishResponse> get responses => _responses.stream;

  Future<void> start() async {
    // Simulate engine startup delay
    await Future.delayed(const Duration(milliseconds: 50));
  }

  void stop() {}

  void analyze(StockfishRequest req) {
    // Simulate analysis by returning a simple response after a short delay
    Future.delayed(Duration(milliseconds: 100 + req.depth * 10), () {
      final lines = <EngineLineResult>[];
      // Provide at least one line with the requested depth and eval 0
      lines.add(EngineLineResult(moves: [], eval: 0.0, depth: req.depth));
      _responses.add(StockfishResponse(
          requestId: req.requestId, isComplete: true, lines: lines));
    });
  }
}
