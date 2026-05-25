import 'package:flutter/material.dart';

enum EngineLevel { lite, standard, premium, elite, ultra, gm }

class EngineProfile {
  final int version;
  final EngineLevel level;
  final int depth;
  final int multiPv;
  final String label;
  final String description;
  final String technicalImpact;
  final bool requiresFullNet;
  final IconData icon;

  const EngineProfile({
    required this.version,
    required this.level,
    required this.depth,
    required this.multiPv,
    required this.label,
    required this.description,
    required this.technicalImpact,
    required this.requiresFullNet,
    required this.icon,
  });

  static const List<EngineProfile> availableProfiles = [
    EngineProfile(
      version: 16,
      level: EngineLevel.lite,
      depth: 16,
      multiPv: 1,
      label: 'SF 16 LITE',
      description: 'Maximum speed, minimum battery impact.',
      technicalImpact:
          'FASTEST. Uses minimal CPU. Best for preserving battery life during quick reviews.',
      requiresFullNet: false,
      icon: Icons.bolt_outlined,
    ),
    EngineProfile(
      version: 17,
      level: EngineLevel.standard,
      depth: 20,
      multiPv: 3,
      label: 'SF 17 STANDARD',
      description: 'Balanced performance for general use.',
      technicalImpact:
          'BALANCED. Standard reliable analysis. Good balance of speed and depth for daily study.',
      requiresFullNet: false,
      icon: Icons.bolt_rounded,
    ),
    EngineProfile(
      version: 171, // 17.1 Full
      level: EngineLevel.premium,
      depth: 24,
      multiPv: 3,
      label: 'SF 17.1 FULL',
      description: 'Precise Brilliant move detection.',
      technicalImpact:
          'PRECISE. Loads a 78MB Neural Network. Drastically improves accuracy and tactical sensitivity.',
      requiresFullNet: true,
      icon: Icons.offline_bolt_rounded,
    ),
    EngineProfile(
      version: 18,
      level: EngineLevel.elite,
      depth: 28,
      multiPv: 4,
      label: 'SF 18 ELITE',
      description: 'Deep awareness for competitive play.',
      technicalImpact:
          'PROFESSIONAL. Deeper tactical awareness. Requires more processing power but catches subtle errors.',
      requiresFullNet: true,
      icon: Icons.psychology_rounded,
    ),
    EngineProfile(
      version: 19,
      level: EngineLevel.ultra,
      depth: 32,
      multiPv: 5,
      label: 'SF 19 ULTRA',
      description: 'Ultra-deep search for complex lines.',
      technicalImpact:
          'EXTREME. For deep theoretical study. Slowest speed, but finds moves that other versions miss.',
      requiresFullNet: true,
      icon: Icons.auto_awesome_rounded,
    ),
    EngineProfile(
      version: 20,
      level: EngineLevel.gm,
      depth: 38,
      multiPv: 6,
      label: 'SF 20 GRANDMASTER',
      description: 'The absolute chess truth.',
      technicalImpact:
          'ULTIMATE. Peak performance. Infinite analysis logic for the absolute truth of the position.',
      requiresFullNet: true,
      icon: Icons.workspace_premium_rounded,
    ),
  ];

  static EngineProfile getByVersion(int version) {
    return availableProfiles.firstWhere(
      (p) => p.version == version,
      orElse: () => availableProfiles[1],
    );
  }
}
