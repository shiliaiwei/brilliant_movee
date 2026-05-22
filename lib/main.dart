import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'core/services/storage_service.dart';
import 'core/services/asset_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait on Android only — web supports all orientations
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  // Transparent status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF080C10),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final storageService = StorageService(prefs);

  // Initialize asset service
  await AssetService.instance.initialize();

  runApp(
    ProviderScope(
      overrides: [
        // Override the storage service with the initialized instance
        storageServiceProvider.overrideWithValue(storageService),
      ],
      child: const BrilliantMoveeApp(),
    ),
  );
}
