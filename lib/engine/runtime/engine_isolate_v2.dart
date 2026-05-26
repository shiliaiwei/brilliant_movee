import 'dart:async';
import 'dart:isolate';
import '../models/uci_commands.dart';
import '../stockfish_wrapper.dart';

/// Professional Engine Isolate Runtime
/// Handles real UCI communication with Stockfish binaries.
class EngineIsolateV2 {
  final ReceivePort _receivePort = ReceivePort();
  SendPort? _sendPort;
  Isolate? _isolate;

  final _uciStreamController = StreamController<String>.broadcast();
  Stream<String> get uciOutput => _uciStreamController.stream;

  Future<void> init() async {
    _isolate = await Isolate.spawn(_entryPoint, _receivePort.sendPort);

    final completer = Completer<void>();
    _receivePort.listen((message) {
      if (message is SendPort) {
        _sendPort = message;
        completer.complete();
      } else if (message is String) {
        _uciStreamController.add(message);
      }
    });
    return completer.future;
  }

  void sendCommand(String command) {
    _sendPort?.send(command);
  }

  Future<void> dispose() async {
    sendCommand(UciCommands.quit);
    _isolate?.kill(priority: Isolate.immediate);
    await _uciStreamController.close();
  }

  static void _entryPoint(SendPort mainSendPort) {
    final isolateReceivePort = ReceivePort();
    mainSendPort.send(isolateReceivePort.sendPort);

    final stockfish = Stockfish();

    // UCI STDOUT -> Main Isolate
    stockfish.stdout.listen((line) {
      mainSendPort.send(line);
    });

    // Main Isolate -> UCI STDIN
    isolateReceivePort.listen((message) {
      if (message is String) {
        stockfish.stdin = message;
      }
    });
  }
}
