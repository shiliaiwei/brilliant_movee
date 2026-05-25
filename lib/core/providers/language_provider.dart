import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

/// Provider for current language setting (en, km)
/// Now watches the notifier to ensure the UI updates instantly.
final languageProvider = Provider<String>((ref) {
  return ref.watch(languageNotifierProvider);
});

/// Provider for updating language
final languageNotifierProvider =
    StateNotifierProvider<LanguageNotifier, String>((ref) {
  final storage = ref.read(storageServiceProvider);
  return LanguageNotifier(storage, storage.languageCode);
});

class LanguageNotifier extends StateNotifier<String> {
  LanguageNotifier(this._storage, String initialLanguage)
      : super(initialLanguage);

  final StorageService _storage;

  Future<void> setLanguage(String languageCode) async {
    await _storage.setLanguageCode(languageCode);
    state = languageCode;
  }
}
