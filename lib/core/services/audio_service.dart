import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'storage_service.dart';

/// Sound event types.
enum SoundEvent { move, capture, check, gameEnd, brilliant, error }

/// Audio service — fire-and-forget playback using platform channels.
/// Respects sound/haptic settings from StorageService.
class AudioService {
  AudioService(this._storage);

  final StorageService _storage;

  Future<void> play(SoundEvent event) async {
    if (!_storage.soundEnabled) return;
    // In a full build, this would use just_audio to play bundled assets.
    // For now, we trigger haptic feedback as a placeholder.
    if (_storage.hapticEnabled) {
      await _triggerHaptic(event);
    }
  }

  Future<void> _triggerHaptic(SoundEvent event) async {
    switch (event) {
      case SoundEvent.move:
        await HapticFeedback.selectionClick();
      case SoundEvent.capture:
        await HapticFeedback.mediumImpact();
      case SoundEvent.check:
        await HapticFeedback.heavyImpact();
      case SoundEvent.gameEnd:
        await HapticFeedback.heavyImpact();
      case SoundEvent.brilliant:
        await HapticFeedback.heavyImpact();
      case SoundEvent.error:
        await HapticFeedback.vibrate();
    }
  }
}

final audioServiceProvider = Provider<AudioService>((ref) {
  final storage = ref.read(storageServiceProvider);
  return AudioService(storage);
});
