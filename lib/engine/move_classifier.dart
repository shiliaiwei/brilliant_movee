// Minimal MoveClassifier, MoveQuality, and related models
// Implemented to satisfy existing usages in review and tests.
// This file provides a heuristic-based classifier used by the review pipeline
// and the unit tests. It is intentionally conservative and easy to extend.

import 'dart:math' as math;

class EngineLineResult {
  final List<String> moves;
  final double eval;
  final int depth;
  const EngineLineResult(
      {required this.moves, required this.eval, required this.depth});
}

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

class MoveClassification {
  final MoveQuality quality;
  final String qualityLabel;
  final String? bestMove;
  final String plainExplanation;
  final double evalAfter;

  const MoveClassification({
    required this.quality,
    required this.qualityLabel,
    this.bestMove,
    this.plainExplanation = '',
    this.evalAfter = 0.0,
  });
}

class MoveQualityTotals {
  final int brilliant;
  final int great;
  final int best;
  final int good;
  final int book;
  final int inaccuracy;
  final int mistake;
  final int blunder;
  final int miss;

  const MoveQualityTotals({
    this.brilliant = 0,
    this.great = 0,
    this.best = 0,
    this.good = 0,
    this.book = 0,
    this.inaccuracy = 0,
    this.mistake = 0,
    this.blunder = 0,
    this.miss = 0,
  });

  static MoveQualityTotals fromClassifications(
      List<MoveClassification?> classifications, bool forWhite) {
    int brilliant = 0,
        great = 0,
        best = 0,
        good = 0,
        book = 0,
        inaccuracy = 0,
        mistake = 0,
        blunder = 0,
        miss = 0;
    for (var i = 0; i < classifications.length; i++) {
      final c = classifications[i];
      if (c == null) continue;
      final isWhiteMove = i % 2 == 0; // index 0 -> white move 1
      if (forWhite != isWhiteMove) continue;
      switch (c.quality) {
        case MoveQuality.brilliant:
          brilliant++;
          break;
        case MoveQuality.great:
          great++;
          break;
        case MoveQuality.best:
          best++;
          break;
        case MoveQuality.good:
          good++;
          break;
        case MoveQuality.book:
          book++;
          break;
        case MoveQuality.inaccuracy:
          inaccuracy++;
          break;
        case MoveQuality.mistake:
          mistake++;
          break;
        case MoveQuality.blunder:
          blunder++;
          break;
        case MoveQuality.miss:
          miss++;
          break;
        case MoveQuality.forced:
          good++;
          break;
      }
    }
    return MoveQualityTotals(
      brilliant: brilliant,
      great: great,
      best: best,
      good: good,
      book: book,
      inaccuracy: inaccuracy,
      mistake: mistake,
      blunder: blunder,
      miss: miss,
    );
  }
}

class MoveClassifier {
  // Heuristic based static classifier. Keep behavior stable for tests.
  static MoveClassification classify({
    required double evalBefore,
    required double evalAfter,
    required bool isBook,
    required bool isForcedMove,
    required bool isSacrifice,
    required double shallowEval,
    required List<EngineLineResult> engineLines,
    String? bestMove,
    String playedMove = '',
  }) {
    // Book positions
    if (isBook) {
      return const MoveClassification(
        quality: MoveQuality.book,
        qualityLabel: 'BOOK',
      );
    }

    // Missed win / blunder detection (huge drop):
    if ((evalBefore - evalAfter) >= 400.0) {
      return const MoveClassification(
        quality: MoveQuality.blunder,
        qualityLabel: 'BLUNDER',
      );
    }
    if ((evalBefore - evalAfter) >= 300.0) {
      return const MoveClassification(
        quality: MoveQuality.miss,
        qualityLabel: 'MISS',
      );
    }

    // Brilliant: sacrifice with deep analysis
    if (isSacrifice) {
      final deep = engineLines.any((l) => l.depth >= 20);
      if (deep) {
        return const MoveClassification(
          quality: MoveQuality.brilliant,
          qualityLabel: '!! Brilliant',
        );
      }
    }

    // Great: large eval swing between top two engine lines and deep
    if (engineLines.length >= 2) {
      final first = engineLines[0];
      final second = engineLines[1];
      if (first.depth >= 20 && second.depth >= 20) {
        if ((first.eval - second.eval).abs() >= 200.0 &&
            playedMove ==
                (first.moves.isNotEmpty ? first.moves[0] : playedMove)) {
          return const MoveClassification(
            quality: MoveQuality.great,
            qualityLabel: '! Great',
          );
        }
      }
    }

    // Default mapping
    return MoveClassification(
      quality: MoveQuality.good,
      qualityLabel: 'GOOD',
      bestMove: bestMove,
      plainExplanation: '',
      evalAfter: evalAfter,
    );
  }

  static double winProbability(num cp) {
    // Convert centipawns to win probability with logistic-like curve
    // Uses 400-centipawn scaling similar to Elo-style logistic
    final x = cp.toDouble();
    final prob = 1.0 / (1.0 + math.pow(10.0, -x / 400.0));
    return prob;
  }
}
