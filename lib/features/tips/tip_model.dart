import 'package:equatable/equatable.dart';

enum TipCategory { opening, middlegame, endgame, tactics, mindset }

class Tip extends Equatable {
  final int id;
  final TipCategory category;
  final String title;
  final String explanation;
  final String? resourceUrl;

  const Tip({
    required this.id,
    required this.category,
    required this.title,
    required this.explanation,
    this.resourceUrl,
  });

  factory Tip.fromJson(Map<String, dynamic> json) {
    return Tip(
      id: json['id'] as int,
      category: TipCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => TipCategory.opening,
      ),
      title: json['title'] as String,
      explanation: json['explanation'] as String,
      resourceUrl: json['resourceUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category.name,
      'title': title,
      'explanation': explanation,
      'resourceUrl': resourceUrl,
    };
  }

  @override
  List<Object?> get props => [id, category, title, explanation, resourceUrl];
}
