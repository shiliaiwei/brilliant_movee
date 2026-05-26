import 'package:flutter/material.dart';

class EngineProfile {
  final int version;
  final String label;
  final String description;
  final int depth;
  final int multiPv;
  final IconData icon;
  final bool requiresFullNet;
  final String technicalImpact;

  const EngineProfile({
    required this.version,
    required this.label,
    required this.description,
    required this.depth,
    this.multiPv = 3,
    required this.icon,
    this.requiresFullNet = false,
    required this.technicalImpact,
  });

  static const List<EngineProfile> availableProfiles = [
    EngineProfile(
      version: 18,
      label: 'SF-18 Neural Pro',
      description: 'Deep neural evaluation with tactical sacrifice detection.',
      depth: 40,
      multiPv: 5,
      icon: Icons.psychology_rounded,
      requiresFullNet: true,
      technicalImpact:
          'Utilizes correction history and parallel data flow (Text/Raw/Heap/Stack) for exponential strength increase.',
    ),
    EngineProfile(
      version: 17,
      label: 'SF-17 Balanced',
      description: 'Optimized for mobile with strong positional vision.',
      depth: 26,
      multiPv: 3,
      icon: Icons.scale_rounded,
      technicalImpact: 'Standard NNUE evaluation with LMR refinements.',
    ),
    EngineProfile(
      version: 14,
      label: 'SF-14 Fast',
      description: 'Lightweight analysis for quick tactical verification.',
      depth: 18,
      multiPv: 1,
      icon: Icons.flash_on_rounded,
      technicalImpact: 'Classical evaluation with limited search horizons.',
    ),
  ];

  static EngineProfile getByVersion(int version) {
    return availableProfiles.firstWhere((p) => p.version == version,
        orElse: () => availableProfiles[1]);
  }
}
