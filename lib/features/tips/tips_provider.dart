import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tip_model.dart';

class TipsState {
  final List<Tip> allTips;
  final Map<TipCategory, List<Tip>> categorizedTips;
  final bool isLoading;
  final String? errorMessage;

  TipsState({
    required this.allTips,
    required this.categorizedTips,
    required this.isLoading,
    this.errorMessage,
  });

  factory TipsState.initial() {
    return TipsState(
      allTips: [],
      categorizedTips: {},
      isLoading: true,
    );
  }

  TipsState copyWith({
    List<Tip>? allTips,
    Map<TipCategory, List<Tip>>? categorizedTips,
    bool? isLoading,
    String? errorMessage,
  }) {
    return TipsState(
      allTips: allTips ?? this.allTips,
      categorizedTips: categorizedTips ?? this.categorizedTips,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class TipsNotifier extends StateNotifier<TipsState> {
  TipsNotifier() : super(TipsState.initial()) {
    loadTips();
  }

  Future<void> loadTips() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final jsonString =
          await rootBundle.loadString('assets/data/tips_v2.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      final List<Tip> tips =
          jsonList.map((j) => Tip.fromJson(j as Map<String, dynamic>)).toList();

      final categorized = <TipCategory, List<Tip>>{};
      for (var category in TipCategory.values) {
        categorized[category] =
            tips.where((t) => t.category == category).toList();
      }

      state = state.copyWith(
        allTips: tips,
        categorizedTips: categorized,
        isLoading: false,
      );
    } catch (e) {
      debugPrint("Error loading tips: $e");
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Failed to load tips. Please restart the app.",
      );
    }
  }

  void reload() => loadTips();
}

final tipsProvider = StateNotifierProvider<TipsNotifier, TipsState>((ref) {
  return TipsNotifier();
});

final tipsByCategoryProvider =
    Provider.family<List<Tip>, TipCategory>((ref, category) {
  final state = ref.watch(tipsProvider);
  return state.categorizedTips[category] ?? [];
});
