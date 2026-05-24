import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'storage_service.dart';

class SettingsState {
  const SettingsState({
    required this.boardTheme,
    required this.pieceSet,
    required this.showCoordinates,
    required this.highlightLastMove,
    required this.autoAnalyze,
  });

  final String boardTheme;
  final String pieceSet;
  final bool showCoordinates;
  final bool highlightLastMove;
  final bool autoAnalyze;

  SettingsState copyWith({
    String? boardTheme,
    String? pieceSet,
    bool? showCoordinates,
    bool? highlightLastMove,
    bool? autoAnalyze,
  }) {
    return SettingsState(
      boardTheme: boardTheme ?? this.boardTheme,
      pieceSet: pieceSet ?? this.pieceSet,
      showCoordinates: showCoordinates ?? this.showCoordinates,
      highlightLastMove: highlightLastMove ?? this.highlightLastMove,
      autoAnalyze: autoAnalyze ?? this.autoAnalyze,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier(this._storage)
      : super(SettingsState(
          boardTheme: _storage.boardTheme,
          pieceSet: _storage.pieceSet,
          showCoordinates: _storage.showCoordinates,
          highlightLastMove: _storage.highlightLastMove,
          autoAnalyze: _storage.autoAnalyze,
        ));

  final StorageService _storage;

  Future<void> updateBoardTheme(String theme) async {
    await _storage.setBoardTheme(theme);
    state = state.copyWith(boardTheme: theme);
  }

  Future<void> updatePieceSet(String set) async {
    await _storage.setPieceSet(set);
    state = state.copyWith(pieceSet: set);
  }

  Future<void> toggleCoordinates(bool value) async {
    await _storage.setShowCoordinates(value);
    state = state.copyWith(showCoordinates: value);
  }

  Future<void> toggleHighlight(bool value) async {
    await _storage.setHighlightLastMove(value);
    state = state.copyWith(highlightLastMove: value);
  }

  Future<void> toggleAutoAnalyze(bool value) async {
    await _storage.setAutoAnalyze(value);
    state = state.copyWith(autoAnalyze: value);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier(ref.read(storageServiceProvider));
});
