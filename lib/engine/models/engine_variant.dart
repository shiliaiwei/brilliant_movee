import 'package:equatable/equatable.dart';

enum EngineCapability {
  nnue,
  multiPv,
  syzygy,
  pondering,
  infiniteAnalysis,
  dynamicHash,
}

enum DownloadState {
  notStarted,
  downloading,
  downloaded,
  verifying,
  corrupted,
}

class EngineVariant extends Equatable {
  final String id;
  final String name;
  final String version;
  final String description;
  final double sizeMb;
  final String nnueUrl;
  final String? localNnuePath;
  final int minHash;
  final int targetDepth;
  final int estimatedElo;
  final String performanceScore; // e.g., "9.8/10"
  final List<EngineCapability> capabilities;
  final DownloadState downloadState;
  final double downloadProgress;
  final String? checksum;

  const EngineVariant({
    required this.id,
    required this.name,
    required this.version,
    required this.description,
    required this.sizeMb,
    required this.nnueUrl,
    this.localNnuePath,
    required this.minHash,
    required this.targetDepth,
    required this.estimatedElo,
    required this.performanceScore,
    required this.capabilities,
    this.downloadState = DownloadState.notStarted,
    this.downloadProgress = 0.0,
    this.checksum,
  });

  EngineVariant copyWith({
    DownloadState? downloadState,
    double? downloadProgress,
    String? localNnuePath,
  }) {
    return EngineVariant(
      id: id,
      name: name,
      version: version,
      description: description,
      sizeMb: sizeMb,
      nnueUrl: nnueUrl,
      localNnuePath: localNnuePath ?? this.localNnuePath,
      minHash: minHash,
      targetDepth: targetDepth,
      estimatedElo: estimatedElo,
      performanceScore: performanceScore,
      capabilities: capabilities,
      downloadState: downloadState ?? this.downloadState,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      checksum: checksum,
    );
  }

  @override
  List<Object?> get props =>
      [id, downloadState, downloadProgress, localNnuePath];
}
