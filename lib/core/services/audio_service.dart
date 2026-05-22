import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'storage_service.dart';

/// Sound event types mapped to file names in each sound pack.
enum SoundEvent {
  move,      // move.mp3
  capture,   // capture.mp3
  check,     // dong.mp3  (used for check alert)
  gameEnd,   // explosion.mp3
  brilliant, // confirmation.mp3 (triumphant chime)
  error,     // error.mp3
}

/// Maps a SoundEvent to the filename inside a sound pack folder.
String _fileForEvent(SoundEvent event) => switch (event) {
      SoundEvent.move => 'move.mp3',
      SoundEvent.capture => 'capture.mp3',
      SoundEvent.check => 'dong.mp3',
      SoundEvent.gameEnd => 'explosion.mp3',
      SoundEvent.brilliant => 'confirmation.mp3',
      SoundEvent.error => 'error.mp3',
    };

/// Fallback file when the primary file doesn't exist in a pack.
String _fallbackFile(SoundEvent event) => switch (event) {
      SoundEvent.check => 'move.mp3',
      SoundEvent.brilliant => 'dong.mp3',
      SoundEvent.error => 'move.mp3',
      _ => 'move.mp3',
    };

/// Audio service — fire-and-forget playback using just_audio.
/// Uses the "standard" Lichess sound pack by default.
/// Respects sound/haptic settings from StorageService.
class AudioService {
  AudioService(this._storage);

  final StorageService _storage;

  // Pool of players for overlapping sounds (move + capture can overlap)
  final Map<SoundEvent, AudioPlayer> _players = {};
  bool _initialized = false;

  /// Initialize players for all events in the current sound pack.
  Future<void> initialize() async {
    if (kIsWeb) return; // just_audio web needs different setup
    if (_initialized) return;
    _initialized = true;
    // Pre-warm the move and capture players (most frequent)
    await _getOrCreatePlayer(SoundEvent.move);
    await _getOrCreatePlayer(SoundEvent.capture);
  }

  Future<AudioPlayer?> _getOrCreatePlayer(SoundEvent event) async {
    if (_players.containsKey(event)) return _players[event];
    try {
      final player = AudioPlayer();
      final pack = _storage.soundPack;
      final file = _fileForEvent(event);
      final path = 'assets/sounds/$pack/$file';

      // Try primary file, fall back if not found
      try {
        await player.setAsset(path);
      } catch (_) {
        final fallback = 'assets/sounds/$pack/${_fallbackFile(event)}';
        try {
          await player.setAsset(fallback);
        } catch (_) {
          // Last resort: standard pack
          await player.setAsset('assets/sounds/standard/$file');
        }
      }

      _players[event] = player;
      return player;
    } catch (_) {
      return null;
    }
  }

  /// Play a sound event. Fire-and-forget — never throws.
  Future<void> play(SoundEvent event) async {
    // Haptic always fires (even if sound is off)
    if (_storage.hapticEnabled) {
      _triggerHaptic(event);
    }

    if (!_storage.soundEnabled) return;

    if (kIsWeb) {
      // Web: just_audio works but needs AudioContext unlock on first interaction
      // For now fall through to haptic only on web
      return;
    }

    try {
      final player = await _getOrCreatePlayer(event);
      if (player == null) return;
      // Seek to start so rapid moves don't queue
      await player.seek(Duration.zero);
      await player.play();
    } catch (_) {
      // Never crash the UI for audio failures
    }
  }

  /// Reload players when sound pack changes in settings.
  Future<void> reloadPack() async {
    for (final p in _players.values) {
      await p.dispose();
    }
    _players.clear();
    _initialized = false;
    await initialize();
  }

  void _triggerHaptic(SoundEvent event) {
    switch (event) {
      case SoundEvent.move:
        HapticFeedback.selectionClick();
      case SoundEvent.capture:
        HapticFeedback.mediumImpact();
      case SoundEvent.check:
        HapticFeedback.heavyImpact();
      case SoundEvent.gameEnd:
        HapticFeedback.heavyImpact();
      case SoundEvent.brilliant:
        HapticFeedback.heavyImpact();
      case SoundEvent.error:
        HapticFeedback.vibrate();
    }
  }

  Future<void> dispose() async {
    for (final p in _players.values) {
      await p.dispose();
    }
    _players.clear();
  }
}

final audioServiceProvider = Provider<AudioService>((ref) {
  final storage = ref.read(storageServiceProvider);
  final service = AudioService(storage);
  // Initialize in background — don't block provider creation
  service.initialize();
  ref.onDispose(service.dispose);
  return service;
});
