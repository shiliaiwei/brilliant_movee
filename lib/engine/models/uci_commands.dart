/// UCI Protocol Command Set for Stockfish 18
class UciCommands {
  static String setNnue(String path) => 'setoption name EvalFile value $path';
  static String setHash(int mb) => 'setoption name Hash value $mb';
  static String setThreads(int count) => 'setoption name Threads value $count';
  static String setMultiPv(int count) => 'setoption name MultiPV value $count';
  static String position(String fen) => 'position fen $fen';
  static String analyze(int depth) => 'go depth $depth';
  static const String isReady = 'isready';
  static const String uci = 'uci';
  static const String stop = 'stop';
  static const String quit = 'quit';
  static const String uciNewGame = 'ucinewgame';
}

class UciInfo {
  final int depth;
  final int selDepth;
  final double cp;
  final int? mate;
  final List<String> pv;
  final int multiPv;
  final int nodes;
  final int nps;
  final int hashFull;

  const UciInfo({
    required this.depth,
    required this.selDepth,
    required this.cp,
    this.mate,
    required this.pv,
    required this.multiPv,
    required this.nodes,
    required this.nps,
    required this.hashFull,
  });

  bool get isMate => mate != null;
}
