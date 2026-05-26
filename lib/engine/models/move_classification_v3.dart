enum MoveCategory {
  brilliant,
  great,
  best,
  excellent,
  good,
  book,
  inaccuracy,
  mistake,
  blunder,
  miss,
  forced,
  onlyMove,
  engineResource,
  positionalBrilliancy,
  sacrificialAttack,
}

class MoveAnalysisV3 {
  final MoveCategory category;
  final String move;
  final double eval;
  final double evalDelta;
  final List<String> pv;
  final int depth;
  final String explanation;
  final String? materialSacrificed;
  final String? compensationType;
  final double humanDifficulty; // 0.0 to 10.0

  const MoveAnalysisV3({
    required this.category,
    required this.move,
    required this.eval,
    required this.evalDelta,
    required this.pv,
    required this.depth,
    required this.explanation,
    this.materialSacrificed,
    this.compensationType,
    this.humanDifficulty = 5.0,
  });

  String get glyph => switch (category) {
        MoveCategory.brilliant => '!!',
        MoveCategory.great => '!',
        MoveCategory.inaccuracy => '?!',
        MoveCategory.mistake => '?',
        MoveCategory.blunder => '??',
        MoveCategory.miss => 'X',
        _ => '',
      };
}
