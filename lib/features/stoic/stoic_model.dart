import 'package:flutter/material.dart';

enum StoicCategory {
  dominance('DOMINANCE', Icons.bolt),
  unshakeable('UNSHAKEABLE', Icons.shield),
  theVoid('THE VOID', Icons.volume_off),
  pragmatism('PRAGMATISM', Icons.payments),
  humanNature('HUMAN NATURE', Icons.favorite),
  asceticism('ASCETICISM', Icons.psychology),
  wisdom('WISDOM', Icons.visibility),
  technology('TECHNOLOGY', Icons.terminal),
  modernSociety('MODERN SOCIETY', Icons.security),
  purpose('PURPOSE', Icons.track_changes),
  emotionalControl('EMOTIONAL CONTROL', Icons.psychology);

  final String label;
  final IconData icon;
  const StoicCategory(this.label, this.icon);

  static StoicCategory fromString(String value) {
    return StoicCategory.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase() || e.label == value,
      orElse: () => StoicCategory.wisdom,
    );
  }
}

class StoicLesson {
  final String id;
  final String title;
  final String content;
  final String directive;
  final StoicCategory category;
  final int intensity;
  final String iconName;

  StoicLesson({
    required this.id,
    required this.title,
    required this.content,
    required this.directive,
    required this.category,
    required this.intensity,
    required this.iconName,
  });

  factory StoicLesson.fromJson(Map<String, dynamic> json) {
    return StoicLesson(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      directive: json['directive'] as String,
      category: StoicCategory.fromString(json['category'] as String),
      intensity: json['intensity'] as int,
      iconName: json['icon'] as String,
    );
  }

  IconData get icon {
    switch (iconName) {
      case 'bolt':
        return Icons.bolt;
      case 'shield':
        return Icons.shield;
      case 'volume_off':
        return Icons.volume_off;
      case 'payments':
        return Icons.payments;
      case 'favorite':
        return Icons.favorite;
      case 'psychology':
        return Icons.psychology;
      case 'trending_up':
        return Icons.trending_up;
      case 'visibility':
        return Icons.visibility;
      case 'explore':
        return Icons.explore;
      case 'account_balance':
        return Icons.account_balance;
      case 'security':
        return Icons.security;
      case 'track_changes':
        return Icons.track_changes;
      case 'terminal':
        return Icons.terminal;
      default:
        return Icons.self_improvement;
    }
  }
}
