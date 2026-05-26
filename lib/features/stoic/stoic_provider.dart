import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'stoic_model.dart';

class StoicState {
  final List<StoicLesson> lessons;
  final StoicCategory? selectedCategory;
  final bool isLoading;
  final String? error;

  StoicState({
    required this.lessons,
    this.selectedCategory,
    this.isLoading = false,
    this.error,
  });

  factory StoicState.initial() {
    return StoicState(
      lessons: [],
      isLoading: true,
    );
  }

  StoicState copyWith({
    List<StoicLesson>? lessons,
    StoicCategory? selectedCategory,
    bool? isLoading,
    String? error,
  }) {
    return StoicState(
      lessons: lessons ?? this.lessons,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  List<StoicLesson> get filteredLessons {
    if (selectedCategory == null) return lessons;
    return lessons.where((c) => c.category == selectedCategory).toList();
  }
}

class StoicNotifier extends StateNotifier<StoicState> {
  StoicNotifier() : super(StoicState.initial()) {
    loadContent();
  }

  Future<void> loadContent() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final String response =
          await rootBundle.loadString('assets/data/stoic_content.json');
      final List<dynamic> data = json.decode(response);
      final List<StoicLesson> loadedLessons =
          data.map((l) => StoicLesson.fromJson(l)).toList();

      state = state.copyWith(
        lessons: loadedLessons,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "SYSTEM ERROR: FAILED TO LOAD ARCHIVE: $e",
      );
    }
  }

  void selectCategory(StoicCategory? category) {
    state = state.copyWith(selectedCategory: category);
  }
}

final stoicProvider = StateNotifierProvider<StoicNotifier, StoicState>((ref) {
  return StoicNotifier();
});
