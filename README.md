# Brilliant Movee

Brilliant Movee is a high-performance, premium chess analysis application built with Flutter. It integrates world-class technology with an industrial-grade "Obsidian" design system to provide chess players with an unvarnished, high-impact environment for study and evolution.

## Vision

Brilliant Movee is not just a replay tool. It is a structured wisdom system. By combining live Stockfish engine metrics, seamless Chess.com data integration, and a curated philosophical manual, the application aims to shift the user's tactical and psychological mindset.

## Core Pillars

### 1. High-Performance Analysis
- Integrated Stockfish Bridge: Real-time evaluation via high-level engine profiles (Stockfish 16 through 20).
- Advanced Move Classification: Automated detection of Brilliant (!!), Great, Best, and Book moves using proprietary sensitivity logic.
- Deep Neural Networks: Support for full NNUE networks (~78MB) for Grandmaster-level accuracy on mobile and desktop.
- Multi-Line Evaluation: Dynamic Multi-PV analysis to explore complex tactical branches simultaneously.

### 2. Seamless Data Integration
- Chess.com Synchronization: Direct import of game history using public APIs.
- PGN Processing: Robust parser for importing external games and managing metadata.
- Game Persistence: Local storage of reviewed games for offline study and comparison.

### 3. The Restricted Manual (Stoic Wisdom)
- Philosophical Directives: A curated database of ~100 high-intensity lessons categorized into industrial pillars (Dominance, Unshakeable, The Void, etc.).
- Psychological Fortification: Content designed to challenge the user's current mindset and build an "Inner Citadel."
- HD Visuals: 4K visual covers and active data engines for financial and character-driven lessons.

### 4. Technical Strategy (Openings & Tips)
- Opening Explorer: Detailed breakdown of the top 50 chess openings with black-and-white illustrator-style visuals.
- Author Profiles: Historical context for each line, featuring the grandmasters and theorists who pioneered them.
- Tactical Encyclopedia: Categorized tips for opening concepts, middle-game positioning, and endgame conversion.

## Technical Architecture

The project is built on a "Feature-First" modular architecture, ensuring scalability and clean state management.

- Framework: Flutter 3.22+
- State Management: Flutter Riverpod (StateNotifier and Provider families)
- Navigation: GoRouter with StatefulShellRoute (IndexedStack) for immersive tab transitions.
- Storage: SharedPreferences for settings and Hive/JSON for local content databases.
- Theme: Material 3 implementation of the "Obsidian" high-contrast system (Pure Black #000000 / Arctic White #FFFFFF).
- Fonts: Consolidated StackSansNotch (English) and GoogleSans (Khmer).

## Implementation Details

### Engine Profiles
Brilliant Movee uses a unified 6-tier engine hierarchy:
- SF 16 LITE: Speed-optimized for battery conservation.
- SF 17 STANDARD: Standard reliable analysis.
- SF 17.1 FULL: Deep NNUE for precise tactical detection.
- SF 18 ELITE: High-precision competitive analysis.
- SF 19 ULTRA: Ultra-deep search for complex positions.
- SF 20 GRANDMASTER: Infinite depth logic for the absolute chess truth.

### Industrial UI Standards
- Zero-Radius Edges: Sharp, unforgiving edges for a professional industrial feel.
- Global Pull-to-Refresh: Consistent data synchronization across all primary modules.
- Responsive Design: Optimized for Mobile, Tablet, and Desktop viewports using a custom Adaptive Shell.

## Build and Deployment

### Requirements
- Flutter SDK 3.22 or higher.
- Dart SDK 3.4 or higher.

### Installation
1. Clone the repository.
2. Run `flutter pub get` to fetch dependencies.
3. If modifying data models, run `dart run build_runner build`.

### Release Commands
- Android: `flutter build apk --release --split-per-abi`
- Web: `flutter build web --release --base-href /`
- Desktop: `flutter build macos` / `flutter build windows`

## Disclaimer

Brilliant Movee is an independent analysis tool and is not officially affiliated with Chess.com. It utilizes publicly available APIs and the open-source Stockfish engine.

---
© 2026 Brilliant Movee. All rights reserved.
