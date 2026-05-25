import 'package:flutter/material.dart';

enum EngineLevel { lite, standard, premium, elite, ultra, gm }

class EngineProfile {
  final int version;
  final EngineLevel level;
  final int depth;
  final int multiPv;
  final String label;
  final String description;
  final bool requiresFullNet;
  final IconData icon;

  const EngineProfile({
    required this.version,
    required this.level,
    required this.depth,
    required this.multiPv,
    required this.label,
    required this.description,
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
      requiresFullNet: false,
      icon: Icons.bolt_outlined,
    ),
    EngineProfile(
      version: 17,
      level: EngineLevel.standard,
      depth: 20,
      multiPv: 3,
      label: 'SF 17 STANDARD',
      description: 'Standard analysis used for basic reviews.',
      requiresFullNet: false,
      icon: Icons.bolt_rounded,
    ),
    EngineProfile(
      version: 171, // Special ID for 17.1 Full
      level: EngineLevel.premium,
      depth: 24,
      multiPv: 3,
      label: 'SF 17.1 FULL',
      description: 'Deep NNUE (78MB). Precise Brilliant move detection.',
      requiresFullNet: true,
      icon: Icons.offline_bolt_rounded,
    ),
    EngineProfile(
      version: 18,
      level: EngineLevel.elite,
      depth: 28,
      multiPv: 4,
      label: 'SF 18 ELITE',
      description: 'High precision for competitive analysis.',
      requiresFullNet: true,
      icon: Icons.psychology_rounded,
    ),
    EngineProfile(
      version: 19,
      level: EngineLevel.ultra,
      depth: 32,
      multiPv: 5,
      label: 'SF 19 ULTRA',
      description: 'Ultra-deep search for complex positions.',
      requiresFullNet: true,
      icon: Icons.auto_awesome_rounded,
    ),
    EngineProfile(
      version: 20,
      level: EngineLevel.gm,
      depth: 38,
      multiPv: 6,
      label: 'SF 20 GRANDMASTER',
      description: 'The ultimate chess truth. Infinite depth logic.',
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
