import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keys for SharedPreferences storage.
abstract final class StorageKeys {
  static const String hasSeenOnboarding = 'has_seen_onboarding';
  static const String connectedUsername = 'connected_username';
  static const String recentUsernames = 'recent_usernames';
  static const String boardTheme = 'board_theme';
  static const String pieceSet = 'piece_set';
  static const String engineDepth = 'engine_depth';
  static const String multiPv = 'multi_pv';
  static const String autoAnalyze = 'auto_analyze';
  static const String showBestMoveArrows = 'show_best_move_arrows';
  static const String soundEnabled = 'sound_enabled';
  static const String hapticEnabled = 'haptic_enabled';
  static const String showCoordinates = 'show_coordinates';
  static const String highlightLastMove = 'highlight_last_move';
  static const String moveAnimationSpeed = 'move_animation_speed';
  static const String brilliantSensitivity = 'brilliant_sensitivity';
}

/// Service for all local key-value storage operations.
/// All screens access storage through this service — never directly.
class StorageService {
  StorageService(this._prefs);

  final SharedPreferences _prefs;

  // ── Onboarding ────────────────────────────────────────────────────────────
  bool get hasSeenOnboarding =>
      _prefs.getBool(StorageKeys.hasSeenOnboarding) ?? false;

  Future<void> setHasSeenOnboarding(bool value) =>
      _prefs.setBool(StorageKeys.hasSeenOnboarding, value);

  // ── Username ──────────────────────────────────────────────────────────────
  String? get connectedUsername =>
      _prefs.getString(StorageKeys.connectedUsername);

  Future<void> setConnectedUsername(String username) =>
      _prefs.setString(StorageKeys.connectedUsername, username);

  Future<void> clearConnectedUsername() =>
      _prefs.remove(StorageKeys.connectedUsername);

  List<String> get recentUsernames =>
      _prefs.getStringList(StorageKeys.recentUsernames) ?? [];

  Future<void> addRecentUsername(String username) async {
    final list = recentUsernames.toList();
    list.remove(username);
    list.insert(0, username);
    if (list.length > 5) list.removeLast();
    await _prefs.setStringList(StorageKeys.recentUsernames, list);
  }

  // ── Board & Pieces ────────────────────────────────────────────────────────
  String get boardTheme => _prefs.getString(StorageKeys.boardTheme) ?? 'wood';
  Future<void> setBoardTheme(String theme) =>
      _prefs.setString(StorageKeys.boardTheme, theme);

  String get pieceSet => _prefs.getString(StorageKeys.pieceSet) ?? 'cburnett';
  Future<void> setPieceSet(String set) =>
      _prefs.setString(StorageKeys.pieceSet, set);

  // ── Engine ────────────────────────────────────────────────────────────────
  int get engineDepth => _prefs.getInt(StorageKeys.engineDepth) ?? 18;
  Future<void> setEngineDepth(int depth) =>
      _prefs.setInt(StorageKeys.engineDepth, depth);

  int get multiPv => _prefs.getInt(StorageKeys.multiPv) ?? 3;
  Future<void> setMultiPv(int lines) =>
      _prefs.setInt(StorageKeys.multiPv, lines);

  bool get autoAnalyze => _prefs.getBool(StorageKeys.autoAnalyze) ?? true;
  Future<void> setAutoAnalyze(bool value) =>
      _prefs.setBool(StorageKeys.autoAnalyze, value);

  bool get showBestMoveArrows =>
      _prefs.getBool(StorageKeys.showBestMoveArrows) ?? true;
  Future<void> setShowBestMoveArrows(bool value) =>
      _prefs.setBool(StorageKeys.showBestMoveArrows, value);

  // ── Sound & Haptics ───────────────────────────────────────────────────────
  bool get soundEnabled => _prefs.getBool(StorageKeys.soundEnabled) ?? true;
  Future<void> setSoundEnabled(bool value) =>
      _prefs.setBool(StorageKeys.soundEnabled, value);

  bool get hapticEnabled => _prefs.getBool(StorageKeys.hapticEnabled) ?? true;
  Future<void> setHapticEnabled(bool value) =>
      _prefs.setBool(StorageKeys.hapticEnabled, value);

  // ── Board Display ─────────────────────────────────────────────────────────
  bool get showCoordinates =>
      _prefs.getBool(StorageKeys.showCoordinates) ?? true;
  Future<void> setShowCoordinates(bool value) =>
      _prefs.setBool(StorageKeys.showCoordinates, value);

  bool get highlightLastMove =>
      _prefs.getBool(StorageKeys.highlightLastMove) ?? true;
  Future<void> setHighlightLastMove(bool value) =>
      _prefs.setBool(StorageKeys.highlightLastMove, value);

  String get moveAnimationSpeed =>
      _prefs.getString(StorageKeys.moveAnimationSpeed) ?? 'normal';
  Future<void> setMoveAnimationSpeed(String speed) =>
      _prefs.setString(StorageKeys.moveAnimationSpeed, speed);

  String get brilliantSensitivity =>
      _prefs.getString(StorageKeys.brilliantSensitivity) ?? 'medium';
  Future<void> setBrilliantSensitivity(String sensitivity) =>
      _prefs.setString(StorageKeys.brilliantSensitivity, sensitivity);

  // ── Cache management ──────────────────────────────────────────────────────
  Future<void> clearAll() => _prefs.clear();
}

/// Provider for StorageService — initialized in main.dart.
final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError('StorageService must be initialized before use');
});
