import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant_movee/engine/move_classifier.dart';

void main() {
  group('MoveClassifier Refined Detection', () {
    test('Should detect Brilliant Move (!!) for a valid sacrifice at depth 20',
        () {
      final classification = MoveClassifier.classify(
        evalBefore: 150.0,
        evalAfter: 145.0,
        isBook: false,
        isForcedMove: false,
        isSacrifice: true,
        shallowEval: 150.0,
        engineLines: [
          const EngineLineResult(moves: ['e2e4'], eval: 145.0, depth: 20),
        ],
        playedMove: 'e2e4',
      );

      expect(classification.quality, MoveQuality.brilliant);
      expect(classification.qualityLabel, '!! Brilliant');
    });

    test('Should NOT detect Brilliant Move (!!) if depth is too low', () {
      final classification = MoveClassifier.classify(
        evalBefore: 150.0,
        evalAfter: 145.0,
        isBook: false,
        isForcedMove: false,
        isSacrifice: true,
        shallowEval: 150.0,
        engineLines: [
          const EngineLineResult(moves: ['e2e4'], eval: 145.0, depth: 10),
        ],
        playedMove: 'e2e4',
      );

      expect(classification.quality, isNot(MoveQuality.brilliant));
    });

    test('Should detect Great Move (!) for an eval swing', () {
      final classification = MoveClassifier.classify(
        evalBefore: 50.0,
        evalAfter: 50.0,
        isBook: false,
        isForcedMove: false,
        isSacrifice: false,
        shallowEval: 50.0,
        engineLines: [
          const EngineLineResult(moves: ['Nf3'], eval: 50.0, depth: 20),
          const EngineLineResult(moves: ['e4'], eval: -150.0, depth: 20),
        ],
        playedMove: 'Nf3',
      );

      expect(classification.quality, MoveQuality.great);
      expect(classification.qualityLabel, '! Great');
    });

    test('Should detect Missed Win when eval drops significantly', () {
      final classification = MoveClassifier.classify(
        evalBefore: 400.0,
        evalAfter: 50.0,
        isBook: false,
        isForcedMove: false,
        isSacrifice: false,
        shallowEval: 400.0,
        engineLines: [
          const EngineLineResult(moves: ['d4'], eval: 50.0, depth: 20),
        ],
        playedMove: 'd4',
      );

      expect(classification.quality, MoveQuality.miss);
    });
  });
}
