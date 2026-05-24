import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'storage_service.dart';

class SettingsState {
  const SettingsState({
    required this.boardTheme,
    required this.pieceSet,
    required this.showCoordinates,
    required this.highlightLastMove,
    required this.autoAnalyze,
    required this.engineVersion,
    required this.engineDepth,
    required this.multiPv,
  });

  final String boardTheme;
  final String pieceSet;
  final bool showCoordinates;
  final bool highlightLastMove;
  final bool autoAnalyze;
  final int engineVersion;
  final int engineDepth;
  final int multiPv;

  SettingsState copyWith({
    String? boardTheme,
    String? pieceSet,
    bool? showCoordinates,
    bool? highlightLastMove,
    bool? autoAnalyze,
    int? engineVersion,
    int? engineDepth,
    int? multiPv,
  }) {
    return SettingsState(
      boardTheme: boardTheme ?? this.boardTheme,
      pieceSet: pieceSet ?? this.pieceSet,
      showCoordinates: showCoordinates ?? this.showCoordinates,
      highlightLastMove: highlightLastMove ?? this.highlightLastMove,
      autoAnalyze: autoAnalyze ?? this.autoAnalyze,
      engineVersion: engineVersion ?? this.engineVersion,
      engineDepth: engineDepth ?? this.engineDepth,
      multiPv: multiPv ?? this.multiPv,
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
          engineVersion: _storage.engineVersion,
          engineDepth: _storage.engineDepth,
          multiPv: _storage.multiPv,
        ));

  final StorageService _storage;

  Future<void> updateEngineProfile(
      {required int version, required int depth, required int multiPv}) async {
    await _storage.setEngineVersion(version);
    await _storage.setEngineDepth(depth);
    await _storage.setMultiPv(multiPv);
    state = state.copyWith(
      engineVersion: version,
      engineDepth: depth,
      multiPv: multiPv,
    );
  }

  Future<void> updateEngineVersion(int version) async {
    await _storage.setEngineVersion(version);
    state = state.copyWith(engineVersion: version);
  }

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
