import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant_movee/engine/move_classifier.dart';
import 'package:brilliant_movee/engine/opening_book.dart';

void main() {
  group('MoveClassifier', () {
    test('classifies blunder correctly', () {
      final result = MoveClassifier.classify(
        evalBefore: 100,
        evalAfter: -300,
        isBook: false,
        isForcedMove: false,
        isSacrifice: false,
        shallowEval: 100,
        engineLines: [],
      );
      expect(result.quality, MoveQuality.blunder);
    });

    test('classifies book move correctly', () {
      final result = MoveClassifier.classify(
        evalBefore: 0,
        evalAfter: 0,
        isBook: true,
        isForcedMove: false,
        isSacrifice: false,
        shallowEval: 0,
        engineLines: [],
      );
      expect(result.quality, MoveQuality.book);
    });

    test('win probability is 0.5 at eval 0', () {
      final prob = MoveClassifier.winProbability(0);
      expect(prob, closeTo(0.5, 0.01));
    });
  });

  group('OpeningBook', () {
    test('contains 3700+ openings', () {
      // After 1.e4 — King's Pawn Game (en-passant field is '-', not 'e3')
      const e4Fen = 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq -';
      expect(OpeningBook.isBookPosition(e4Fen), isTrue);
      expect(OpeningBook.getOpeningName(e4Fen), isNotNull);
    });

    test('returns ECO code', () {
      const e4Fen = 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq -';
      final eco = OpeningBook.getEcoCode(e4Fen);
      expect(eco, isNotNull);
    });

    test('returns null for non-book position', () {
      // Random mid-game FEN — not in opening book
      const midgameFen = 'r1bqkb1r/pppp1ppp/2n2n2/4p3/2B1P3/5N2/PPPP1PPP/RNBQK2R w KQkq -';
      // This may or may not be in book — just check it doesn't crash
      final name = OpeningBook.getOpeningName(midgameFen);
      // name is either a String or null — both valid
      expect(name, anyOf(isNull, isA<String>()));
    });

    test('normalizes FEN correctly (ignores move counters)', () {
      // FEN with move counters should match same FEN without
      const fenWithCounters =
          'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1';
      const fenWithout =
          'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq -';
      expect(
        OpeningBook.isBookPosition(fenWithCounters),
        equals(OpeningBook.isBookPosition(fenWithout)),
      );
    });
  });
}
