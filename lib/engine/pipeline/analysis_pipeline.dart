import 'dart:async';
import '../models/uci_commands.dart';
import '../runtime/engine_isolate_v2.dart';

/// Neural Analysis Pipeline
/// Manages the data flow between the UI, the Isolate, and the MoveClassifier.
class AnalysisPipeline {
  final EngineIsolateV2 _runtime;

  AnalysisPipeline(this._runtime);

  final _infoController = StreamController<UciInfo>.broadcast();
  Stream<UciInfo> get liveAnalysis => _infoController.stream;

  void startAnalysis(String fen, {int depth = 40, int multiPv = 5}) {
    _runtime.sendCommand(UciCommands.uciNewGame);
    _runtime.sendCommand(UciCommands.setMultiPv(multiPv));
    _runtime.sendCommand(UciCommands.position(fen));
    _runtime.sendCommand(UciCommands.analyze(depth));

    _runtime.uciOutput.listen(_handleRawUci);
  }

  void _handleRawUci(String line) {
    if (line.startsWith('info')) {
      final parsed = _parseUciInfo(line);
      if (parsed != null) _infoController.add(parsed);
    }
  }

  UciInfo? _parseUciInfo(String line) {
    try {
      final depth = _extractInt(line, 'depth') ?? 0;
      final selDepth = _extractInt(line, 'seldepth') ?? 0;
      final multipv = _extractInt(line, 'multipv') ?? 1;
      final nodes = _extractInt(line, 'nodes') ?? 0;
      final nps = _extractInt(line, 'nps') ?? 0;
      final hashfull = _extractInt(line, 'hashfull') ?? 0;

      double cp = 0.0;
      int? mate;
      if (line.contains('score cp')) {
        cp = _extractInt(line, 'cp')?.toDouble() ?? 0.0;
      } else if (line.contains('score mate')) {
        mate = _extractInt(line, 'mate');
      }

      final pvIndex = line.indexOf(' pv ');
      final pv =
          pvIndex != -1 ? line.substring(pvIndex + 4).split(' ') : <String>[];

      return UciInfo(
        depth: depth,
        selDepth: selDepth,
        cp: cp,
        mate: mate,
        pv: pv,
        multiPv: multipv,
        nodes: nodes,
        nps: nps,
        hashFull: hashfull,
      );
    } catch (_) {
      return null;
    }
  }

  int? _extractInt(String line, String key) {
    final match = RegExp('$key (\\-?\\d+)').firstMatch(line);
    return match != null ? int.tryParse(match.group(1)!) : null;
  }

  void stop() => _runtime.sendCommand(UciCommands.stop);
}
