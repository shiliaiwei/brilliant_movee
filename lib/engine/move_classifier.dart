import 'dart:math' as math;

/// Move quality classification for Brilliant Movee.
/// Implements the full classification algorithm from the build spec.

enum MoveQuality {
  brilliant,
  great,
  best,
  good,
  book,
  inaccuracy,
  mistake,
  blunder,
  miss,
  forced,
}

/// Result of classifying a single move.
class MoveClassification {
  const MoveClassification({
    required this.quality,
    required this.cpl,
    required this.evalBefore,
    required this.evalAfter,
    this.bestMove,
    this.engineLines = const [],
  });

  final MoveQuality quality;
  final int cpl; // centipawn loss
  final double evalBefore;
  final double evalAfter;
  final String? bestMove;
  final List<EngineLineResult> engineLines;

  String get qualityLabel => switch (quality) {
        MoveQuality.brilliant => '!! Brilliant',
        MoveQuality.great => '! Great',
        MoveQuality.best => 'Best',
        MoveQuality.good => 'Good',
        MoveQuality.book => 'Book',
        MoveQuality.inaccuracy => '?! Inaccuracy',
        MoveQuality.mistake => '? Mistake',
        MoveQuality.blunder => '?? Blunder',
        MoveQuality.miss => 'Miss',
        MoveQuality.forced => 'Forced',
      };

  String get plainExplanation => switch (quality) {
        MoveQuality.brilliant =>
          'A brilliant sacrifice! The engine initially evaluates this as losing, but deeper analysis reveals it wins.',
        MoveQuality.great =>
          'An excellent move — nearly the best option available.',
        MoveQuality.best => "The engine's top choice for this position.",
        MoveQuality.good => 'A solid move that maintains the position.',
        MoveQuality.book => 'A well-known opening theory move.',
        MoveQuality.inaccuracy =>
          'A slight inaccuracy. There was a better option available.',
        MoveQuality.mistake =>
          'A mistake that gives the opponent a meaningful advantage.',
        MoveQuality.blunder =>
          'A serious blunder! This move significantly worsens the position.',
        MoveQuality.miss =>
          'A missed winning opportunity. The position was winning before this move.',
        MoveQuality.forced => 'The only legal or reasonable move here.',
      };
}

class EngineLineResult {
  const EngineLineResult({
    required this.moves,
    required this.eval,
    required this.depth,
    this.isMate = false,
    this.mateIn,
  });

  final List<String> moves;
  final double eval;
  final int depth;
  final bool isMate;
  final int? mateIn;

  String get evalDisplay {
    if (isMate && mateIn != null) return 'M$mateIn';
    final sign = eval >= 0 ? '+' : '';
    return '$sign${(eval / 100).toStringAsFixed(2)}';
  }
}

/// Classifies a move based on centipawn loss and position context.
abstract final class MoveClassifier {
  /// Main classification entry point.
  static MoveClassification classify({
    required double evalBefore,
    required double evalAfter,
    required bool isBook,
    required bool isForcedMove,
    required bool isSacrifice,
    required double shallowEval,
    required List<EngineLineResult> engineLines,
    String? bestMove,
    String? playedMove,
  }) {
    // 1. Book move
    if (isBook) {
      return MoveClassification(
        quality: MoveQuality.book,
        cpl: 0,
        evalBefore: evalBefore,
        evalAfter: evalAfter,
        bestMove: bestMove,
        engineLines: engineLines,
      );
    }

    // 2. Forced move (only legal move)
    if (isForcedMove) {
      return MoveClassification(
        quality: MoveQuality.forced,
        cpl: 0,
        evalBefore: evalBefore,
        evalAfter: evalAfter,
        bestMove: bestMove,
        engineLines: engineLines,
      );
    }

    final cpl = (evalBefore - evalAfter).round().clamp(0, 9999);

    // 3. Brilliant: best move + sacrifice + shallow eval negative + deep eval winning
    if (cpl == 0 && isSacrifice && shallowEval < -50 && evalAfter > 50) {
      return MoveClassification(
        quality: MoveQuality.brilliant,
        cpl: cpl,
        evalBefore: evalBefore,
        evalAfter: evalAfter,
        bestMove: bestMove,
        engineLines: engineLines,
      );
    }

    // 4. Missed win: position was winning, now it's not
    if (evalBefore > 300 && evalAfter < 100) {
      return MoveClassification(
        quality: MoveQuality.miss,
        cpl: cpl,
        evalBefore: evalBefore,
        evalAfter: evalAfter,
        bestMove: bestMove,
        engineLines: engineLines,
      );
    }

    // 5. Context modifier: if already losing, lower thresholds
    final isAlreadyLosing = evalBefore < -300;
    final quality = isAlreadyLosing
        ? _classifyLosing(cpl)
        : _classifyNormal(cpl);

    return MoveClassification(
      quality: quality,
      cpl: cpl,
      evalBefore: evalBefore,
      evalAfter: evalAfter,
      bestMove: bestMove,
      engineLines: engineLines,
    );
  }

  static MoveQuality _classifyNormal(int cpl) {
    if (cpl == 0) return MoveQuality.best;
    if (cpl <= 5) return MoveQuality.great;
    if (cpl <= 15) return MoveQuality.good;
    if (cpl <= 50) return MoveQuality.inaccuracy;
    if (cpl <= 150) return MoveQuality.mistake;
    return MoveQuality.blunder;
  }

  static MoveQuality _classifyLosing(int cpl) {
    if (cpl == 0) return MoveQuality.best;
    if (cpl <= 10) return MoveQuality.great;
    if (cpl <= 30) return MoveQuality.good;
    if (cpl <= 80) return MoveQuality.inaccuracy;
    if (cpl <= 200) return MoveQuality.mistake;
    return MoveQuality.blunder;
  }

  /// Convert centipawns to win probability (sigmoid function).
  static double winProbability(double evalCp) {
    return 1.0 / (1.0 + math.exp(-evalCp / 400.0));
  }
}
