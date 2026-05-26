import 'engine_variant.dart';

abstract final class EngineConstants {
  static const List<EngineVariant> variants = [
    EngineVariant(
      id: 'lite',
      name: 'SF-18 Lite',
      version: '18.0',
      description: 'Fast mobile-optimized neural network. Low latency.',
      sizeMb: 0.0,
      nnueUrl: '',
      minHash: 128,
      targetDepth: 22,
      estimatedElo: 3200,
      performanceScore: '7.2/10',
      capabilities: [EngineCapability.nnue, EngineCapability.multiPv],
    ),
    EngineVariant(
      id: 'balanced',
      name: 'SF-18 Balanced',
      version: '18.0',
      description: 'The standard for deep positional understanding.',
      sizeMb: 45.2,
      nnueUrl:
          'https://tests.stockfishchess.org/api/nn/nn-1119-20240102-0901.nnue',
      minHash: 1024,
      targetDepth: 32,
      estimatedElo: 3550,
      performanceScore: '8.8/10',
      capabilities: [
        EngineCapability.nnue,
        EngineCapability.multiPv,
        EngineCapability.dynamicHash
      ],
    ),
    EngineVariant(
      id: 'neural_pro',
      name: 'SF-18 Neural Pro',
      version: '18.0',
      description: 'Maximum tactical horizon. Optimized for Brilliancy.',
      sizeMb: 82.5,
      nnueUrl: 'https://tests.stockfishchess.org/api/nn/nn-b1a1-20250201.nnue',
      minHash: 4096,
      targetDepth: 50,
      estimatedElo: 3700,
      performanceScore: '9.9/10',
      capabilities: [
        EngineCapability.nnue,
        EngineCapability.multiPv,
        EngineCapability.syzygy,
        EngineCapability.infiniteAnalysis
      ],
    ),
  ];
}
