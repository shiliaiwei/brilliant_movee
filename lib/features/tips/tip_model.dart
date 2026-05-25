import 'package:equatable/equatable.dart';

enum TipCategory {
  opening,
  middlegame,
  endgame,
  tactics,
  mindset,
  stoic,
  openingNames
}

class Tip extends Equatable {
  final int id;
  final TipCategory category;
  final Map<String, String> titleMap;
  final Map<String, String> explanationMap;
  final String? imageUrl; // For opening images

  const Tip({
    required this.id,
    required this.category,
    required this.titleMap,
    required this.explanationMap,
    this.imageUrl,
  });

  String getTitle(String languageCode) {
    return titleMap[languageCode] ?? titleMap['en'] ?? '';
  }

  String getExplanation(String languageCode) {
    return explanationMap[languageCode] ?? explanationMap['en'] ?? '';
  }

  factory Tip.fromJson(Map<String, dynamic> json) {
    return Tip(
      id: json['id'] as int,
      category: TipCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => TipCategory.opening,
      ),
      titleMap: _parseLanguageMap(json['title']),
      explanationMap: _parseLanguageMap(json['explanation']),
      imageUrl: json['imageUrl'] as String?,
    );
  }

  static Map<String, String> _parseLanguageMap(dynamic value) {
    if (value is Map<String, String>) return value;
    if (value is Map) return Map<String, String>.from(value);
    if (value is String) return {'en': value};
    return {'en': ''};
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category.name,
      'title': titleMap,
      'explanation': explanationMap,
      'imageUrl': imageUrl,
    };
  }

  @override
  List<Object?> get props => [id, category, titleMap, explanationMap, imageUrl];
}
