import 'package:flutter/material.dart';

enum StoicCategory {
  // Core 11
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
  emotionalControl('EMOTIONAL CONTROL', Icons.psychology),

  // Expansion to 44
  psychology('PSYCHOLOGY', Icons.psychology_alt),
  neuroscience('NEUROSCIENCE', Icons.biotech),
  stoicism('STOICISM', Icons.self_improvement),
  philosophy('PHILOSOPHY', Icons.menu_book),
  deepThinking('THINKING', Icons.lightbulb),
  mentalModels('MODELS', Icons.architecture),
  communication('COMMUNICATION', Icons.chat_bubble),
  publicSpeaking('SPEAKING', Icons.record_voice_over),
  productivity('PRODUCTIVITY', Icons.speed),
  habits('HABITS', Icons.repeat),
  learningSystems('LEARNING', Icons.school),
  intelligence('INTELLIGENCE', Icons.smart_toy),
  chessStrategy('STRATEGY', Icons.grid_view),
  programming('PROGRAMMING', Icons.code),
  flutterDev('FLUTTER', Icons.flutter_dash),
  backendEngineering('BACKEND', Icons.storage),
  systemDesign('SYSTEMS', Icons.account_tree),
  finance('FINANCE', Icons.account_balance_wallet),
  investmentBanking('INVESTMENT', Icons.trending_up),
  stockMarket('STOCKS', Icons.show_chart),
  business('BUSINESS', Icons.business),
  startupMvp('STARTUP', Icons.rocket_launch),
  personalBranding('BRANDING', Icons.person),
  artificialIntelligence('AI', Icons.memory),
  quantumComputing('QUANTUM', Icons.science),
  gameTheory('GAME THEORY', Icons.videogame_asset),
  science('SCIENCE', Icons.biotech),
  physics('PHYSICS', Icons.shutter_speed),
  history('HISTORY', Icons.history),
  culture('CULTURE', Icons.public),
  documentaries('CINEMA', Icons.movie),
  podcasts('PODCASTS', Icons.mic),
  books('BOOKS', Icons.library_books);

  final String label;
  final IconData icon;
  const StoicCategory(this.label, this.icon);

  static StoicCategory fromString(String value) {
    return StoicCategory.values.firstWhere(
      (e) =>
          e.name.toLowerCase() == value.toLowerCase() ||
          e.label.toLowerCase() == value.toLowerCase(),
      orElse: () => StoicCategory.wisdom,
    );
  }
}

class StoicSection {
  final String title;
  final String body;
  final String type; // visual, grammar, strategy, graph, data, body
  final Map<String, dynamic> metadata;
  final List<String> bulletPoints;

  StoicSection({
    required this.title,
    required this.body,
    this.type = 'body',
    this.metadata = const {},
    this.bulletPoints = const [],
  });

  factory StoicSection.fromJson(Map<String, dynamic> json) {
    return StoicSection(
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: json['type'] ?? 'body',
      metadata: json['metadata'] ?? {},
      bulletPoints: List<String>.from(json['bulletPoints'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'body': body,
        'type': type,
        'metadata': metadata,
        'bulletPoints': bulletPoints,
      };
}

class StoicLesson {
  final String id;
  final String title;
  final String content; // Still keep for backward compatibility or simple cases
  final String directive;
  final StoicCategory category;
  final int intensity;
  final List<StoicSection> sections;
  final List<String> tags;
  final bool isPremium;
  final String? videoUrl;
  final String? audioUrl;

  StoicLesson({
    required this.id,
    required this.title,
    required this.content,
    required this.directive,
    required this.category,
    this.intensity = 1,
    this.sections = const [],
    this.tags = const [],
    this.isPremium = false,
    this.videoUrl,
    this.audioUrl,
  });

  factory StoicLesson.fromJson(Map<String, dynamic> json) {
    return StoicLesson(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      directive: json['directive'] ?? '',
      category: StoicCategory.fromString(json['category'] ?? ''),
      intensity: json['intensity'] ?? 1,
      sections: (json['sections'] as List? ?? [])
          .map((s) => StoicSection.fromJson(s))
          .toList(),
      tags: List<String>.from(json['tags'] ?? []),
      isPremium: json['isPremium'] ?? false,
      videoUrl: json['videoUrl'],
      audioUrl: json['audioUrl'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'directive': directive,
        'category': category.name,
        'intensity': intensity,
        'sections': sections.map((s) => s.toJson()).toList(),
        'tags': tags,
        'isPremium': isPremium,
        'videoUrl': videoUrl,
        'audioUrl': audioUrl,
      };
}
