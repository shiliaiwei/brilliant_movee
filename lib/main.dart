import 'dart:async';
import 'dart:developer' as developer;

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
  developer.log('main: entered', name: 'BrilliantMovee.startup');

  // Lock to portrait on Android only — web supports all orientations
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  // Transparent status bar for black theme (immersive)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize SharedPreferences
  developer.log('main: loading shared preferences',
      name: 'BrilliantMovee.startup');
  final prefs = await SharedPreferences.getInstance();
  developer.log('main: shared preferences ready',
      name: 'BrilliantMovee.startup');
  final storageService = StorageService(prefs);

  // Start asset initialization in background to avoid blocking first frame.
  developer.log('main: kicking off asset initialization',
      name: 'BrilliantMovee.startup');
  unawaited(AssetService.instance.initialize());

  developer.log('main: calling runApp', name: 'BrilliantMovee.startup');
  runApp(
    ProviderScope(
      overrides: [
        // Override the storage service with the initialized instance
        storageServiceProvider.overrideWithValue(storageService),
      ],
      child: const BrilliantMoveeApp(),
    ),
  );
  developer.log('main: runApp returned', name: 'BrilliantMovee.startup');
}
