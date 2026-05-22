# Stupid Brilliant

Stupid Brilliant is a technical chess analysis platform designed to provide high-depth game reviews and move quality classification. The system integrates the Stockfish 16 engine with public chess data to deliver a premium analysis experience across mobile and web platforms.

## System Architecture

The application is built using the Flutter framework and follows a reactive state management pattern. It is divided into three primary layers.

1. Data Layer: Responsible for fetching player statistics and game history from the Chess.com public API. It handles PGN parsing and FEN string generation.
2. Engine Layer: Executes Stockfish 16 within a dedicated Dart Isolate. This ensures that heavy computational analysis does not block the main UI thread. Communication is handled via the UCI protocol.
3. UI Layer: Implements a premium design system based on a white color palette, utilizing adaptive layouts that transition between a bottom navigation bar for mobile and a sidebar navigation for desktop and tablet views.

## Game Processing Pipeline

When a user selects a game for review, the following sequence occurs.

1. PGN Parsing: The raw game text is converted into a list of moves and corresponding FEN strings representing every position in the game.
2. Static Analysis: The system checks each position against an internal opening book to identify known theoretical moves.
3. Engine Analysis: For moves not found in the opening book, the system performs a dual-pass analysis. It evaluates the position before the move and the position resulting from the move.
4. Metric Calculation: The system calculates the Centipawn Loss (CPL) and determines if a sacrifice occurred by comparing piece values between consecutive board states.

## Move Classification Algorithm

Move quality is assigned based on mathematical thresholds and contextual heuristics.

- Brilliant: Assigned when a move is the top engine choice, involves a piece sacrifice, and results in a significant evaluation turnaround after deep analysis compared to a shallow search.
- Great: Assigned to moves that are highly accurate but do not meet the sacrifice criteria of a brilliant move.
- Best: Assigned when the played move matches the engine's primary recommendation.
- Good: Moves that maintain a stable evaluation within a narrow centipawn margin.
- Inaccuracy/Mistake/Blunder: Assigned based on increasing tiers of centipawn loss relative to the current position strength.
- Miss: Assigned when a move fails to capitalize on a winning advantage, resulting in a significant drop in win probability.

## Technical Implementation Details

- State Management: Utilizing Riverpod for reactive updates and persistent settings.
- Storage: Local preferences and cached game data are managed through SharedPreferences and Hive.
- Audio: The just_audio package handles high-performance playback of the standard chess sound pack, synchronized with move navigation.
- Rendering: The chess board uses RepaintBoundary to optimize performance during rapid move navigation, redrawing only the necessary squares and pieces.
- PWA: The web version is configured as a Progressive Web App with custom manifest settings and high-resolution icons for a native-like browser experience.
