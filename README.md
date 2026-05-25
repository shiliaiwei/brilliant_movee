# Brilliant Movee

Brilliant Movee is a premium Flutter chess analysis application designed for deep game review and tactical evolution. It combines Chess.com public data integration with a local Stockfish engine bridge to provide high-performance analysis on mobile and desktop platforms.

## Core Features

- Deep Analysis: Integrated Stockfish engine for real-time move evaluation and classification.
- Game Import: Seamless import of games from Chess.com using public APIs.
- Polished UI: A high-contrast "Obsidian" design system optimized for long study sessions.
- Multi-Language Support: Full support for English and Khmer (using Google Sans for native script).
- Stoic Wisdom: A curated database of philosophical and psychological directives for mental fortification.
- Tactical Tips: Categorized opening, middlegame, and endgame strategies.

## Technical Stack

- Framework: Flutter 3.22+
- State Management: Flutter Riverpod
- Engine: Stockfish Bridge (via FFI)
- Navigation: GoRouter
- Theme: Material 3 (Pure Black / Obsidian)
- Fonts: StackSansNotch (English), GoogleSans (Khmer)

## Installation and Build

### Development Setup
1. Ensure Flutter SDK is installed.
2. Run `flutter pub get` to fetch dependencies.
3. Run `dart run build_runner build` if necessary for code generation.

### Build Commands
- Android APK: `flutter build apk --release`
- Web: `flutter build web`
- iOS: `flutter build ios`

## Project Architecture

The project follows a feature-first organization:
- `lib/core`: Global constants, themes, and shared utilities.
- `lib/features`: Feature-specific logic (Analysis, Tips, Stoic, etc.).
- `lib/engine`: Chess logic, PGN parsing, and Stockfish integration.
- `lib/data`: Repositories and API abstractions.

## License

This project is proprietary. All rights reserved.
