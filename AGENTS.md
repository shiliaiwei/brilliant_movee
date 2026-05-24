# Agent guidance for Brilliant Movee

- **What this is:** a Flutter chess-analysis app that combines Chess.com public data, a local Stockfish bridge, and a polished review/export UI.
- **Start here:** `lib/main.dart` initializes `SharedPreferences`, `AssetService`, and overrides `storageServiceProvider`; `lib/app.dart` wires `MaterialApp.router` + `AppTheme.darkTheme`.
- **Navigation:** `lib/core/router/app_router.dart` uses `go_router` with a `StatefulShellRoute.indexedStack` for the main tabs (`Home`, `Games`, `Tips`, `Settings`) and standalone routes for `Search`, `Profile`, `Review`, `Onboarding`, `Splash`, `BoardSelector`, and `Brilliant`.
- **Data flow:** screens talk to repositories, repositories talk to `ChessComApi`; keep API access behind `lib/data/repositories/*` and avoid calling `Dio` directly from UI.
- **State pattern:** the codebase favors `flutter_riverpod` with private `FutureProvider.autoDispose` / `StateNotifierProvider.autoDispose` near the screen that uses them (see `home`, `history`, `profile`, `search`, `review`).
- **Local source of truth:** `lib/core/services/storage_service.dart` owns onboarding, connected username, recent usernames, board/theme/sound/engine settings, and the “brilliant games” list.
- **Review pipeline:** `lib/features/review/analysis/review_notifier.dart` parses PGN, builds board states, queries `StockfishIsolate`, classifies moves, persists brilliant games, and drives video export.
- **Engine rule:** `lib/engine/stockfish_isolate.dart` keeps analysis off the UI thread; on web it falls back to simulated async analysis, so don’t assume a real native engine is present there.
- **Chess-specific logic:** move quality lives in `lib/engine/move_classifier.dart`; PGN parsing is in `lib/engine/pgn_parser.dart`; opening lookups use `lib/engine/opening_book.dart`.
- **Generated asset data:** `lib/engine/opening_book.dart` is auto-generated and explicitly says not to edit manually; regenerate with `python3 assets_prepare/gen_openings.py`.
- **Assets are local-only:** `AssetService` loads `assets/data/asset_manifest.json` and resolves bundled piece sets, board themes, and sound packs from `assets/`.
- **UI conventions:** prefer the shared design system (`AppColors`, `AppTextStyles`, `AppSpacing`, `ChtButton`, `ChtCard`, `ChtErrorState`, `ChtShimmer`) rather than ad hoc styling.
- **Responsive layout:** use `context.isMobile/isTablet/isDesktop` and `ResponsiveContainer` from `lib/core/utils/responsive.dart`; the router shell already switches between mobile bottom-nav and tablet/desktop side rail.
- **Feature structure:** code is organized by feature folder under `lib/features/*`; keep new review/history/profile/search/settings work in the matching feature rather than adding cross-cutting screens elsewhere.
- **Existing tests:** `test/widget_test.dart` covers `MoveClassifier` and `OpeningBook`; extend that file or add focused tests when changing engine classification or opening data.
- **Working commands:** `flutter pub get`, `flutter analyze`, `flutter test`, `flutter run`, and the documented builds in `README.md` (`flutter build apk`, `flutter build web`, etc.).
- **Codegen note:** `README.md` documents `dart run build_runner build`; use it only when touching codegen-backed files, and verify whether the target actually has generated parts before relying on it.
- **Platform caveats:** `main.dart` locks portrait mode only off-web, `audio_service.dart` disables full playback on web, and `recording_service.dart` depends on FFmpeg/`dart:io` so it is mobile/desktop-oriented.

