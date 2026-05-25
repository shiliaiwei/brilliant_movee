import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/providers/language_provider.dart';

/// Root application widget for Brilliant Movee.
class BrilliantMoveeApp extends ConsumerWidget {
  const BrilliantMoveeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final languageCode = ref.watch(languageProvider);

    return MaterialApp.router(
      title: 'Brilliant Movee',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme(languageCode),
      routerConfig: router,
    );
  }
}
