# Brilliant Movee - Chess Analysis Application

Brilliant Movee is a premium Dart/Flutter application that connects Chess.com with advanced UCI chess engine analysis, delivering professional tactical coaching through an elegant Futuristic User Interface (FUI). This application brings the power of deep position analysis to chess players of all levels, transforming raw engine evaluations into actionable coaching insights.

---

## 🚀 Version 1.3.0 - The Engine Upgrade

The latest release brings **Stockfish 17.1** directly into the application with professional-grade analysis profiles and a high-fidelity redesign.

### Key Upgrades

- **Real UCI Stockfish Wiring**: Direct communication with Stockfish 17.1 (not simulated) for accurate evaluations.
- **Dual-Net System**: Switch between **Lite** (~7MB) for speed/battery and **Full** (~133MB) for maximum grandmaster-level strength.
- **Analysis Profiles**:
  - **Fast**: Quick scan, low battery usage.
  - **Balanced**: Standard mobile accuracy.
  - **Premium (Depth 26)**: Industry standard for Brilliant (!!) detection.
  - **Grandmaster (Depth 32)**: Ultimate precision for deep sacrifices and positional mastery.
- **Brilliant Move Detection (!!)**: Refined heuristics that identify sacrifices and game-changing moves using high-depth validation.
- **FUI Aesthetic**: A complete visual overhaul featuring 45-degree clipped corners, technical scanning animations, and real-time progress indicators.

---

## Project Overview

Brilliant Movee combines Chess.com game data with real-time engine analysis to deliver professional-grade coaching and performance metrics. The application processes game histories, analyzes move quality, and generates natural language coaching feedback that helps players understand their strengths and weaknesses.

The platform features real-time rankings, detailed performance analytics, and automated analysis workflows that turn complex chess engine evaluations into actionable feedback for improvement.

### Core Features

- **Deep Engine Analysis**: Advanced chess engine integration running analysis at significant depth levels (up to Depth 32).
- **Performance Dashboard**: Professional dashboard displaying move quality breakdowns and performance metrics.
- **Global Rankings**: Real-time rankings across multiple game categories (Rapid, Blitz, Bullet, and more).
- **Move Classification**: Automatic identification and classification of significant moves (Brilliant, Great, Best, etc.) with detailed analysis.
- **Tips & Tricks**: A curated library of instructional content categorized for Opening, Middlegame, Endgame, Tactics, and Mindset.
- **Video Export**: Automated recording and export of game reviews for sharing on social media.
- **Cross-Platform Support**: Seamless experience across mobile devices, tablets, and web browsers.
- **Game Archive Integration**: Access to complete game history from Chess.com.

---

## System Architecture Flowcharts

For detailed system architecture and workflow diagrams, see **[FLOWCHARTS.md](./FLOWCHARTS.md)** which contains:

1. **Complete System Architecture Flowchart** - Full user journey covering authentication, dashboard navigation, game history, player profiles, leaderboard search, game review, and video export.
2. **Detailed Game Analysis Process** - Step-by-step flow for game data fetching, PGN parsing, board state generation, engine initialization, and move-by-move analysis.
3. **Engine Analysis Deep Dive** - In-depth view of engine startup, position setup, move tree search, best move calculation, and result caching.
4. **Data Flow Architecture** - System data movement from UI layer through state management, business logic, repositories to external services.
5. **Authentication and Session Management** - Complete flow for session validation, OAuth authorization, token management, and user profile loading.
6. **Video Export and Rendering Pipeline** - Full process including format selection, frame rendering, video encoding, audio/subtitles, and export destinations.
7. **Error Handling and Recovery** - Comprehensive error management for network, authentication, engine, storage, and parsing errors with recovery strategies.
8. **Performance Metrics Monitoring** - Continuous monitoring of memory usage, CPU performance, network activity, and automatic optimization triggers.

---

## Project Structure

```
lib/
  core/
    - Global theme configuration (Dark FUI)
    - Application constants (AppColors, AppSpacing)
    - Shared widgets (CyberButton, ChtCard)
    - Error handling utilities
    
  data/
    - Chess.com API models
    - Data repositories
    - API integration services
    - Local storage models (StorageService)
    - Cache management
    
  engine/
    - UCI Engine bridge (StockfishIsolate)
    - PGN notation parser
    - Board state manager
    - Move classifier (Brilliant Detection)
    - Position evaluator
    
  features/
    home/
      - Application dashboard
      - Global leaderboard display
    history/
      - Game history browser (Analysis Tab)
    tips/
      - Curated chess improvement library
    profile/
      - Performance analytics dashboard
    review/
      - Interactive analysis board
      - Real-time engine status (Depth/Eval)
      - Video export service
      
assets/
  - High-quality Board (Wood 4) and Piece (Maestro) graphics
  - FUI icons and graphics
  - Data (tips.json)
```

---

## Technology Stack

### Frontend Framework
- Dart Programming Language (83.9% of codebase)
- Flutter Framework for cross-platform UI
- HTML for web components (16.1% of codebase)

### State Management
- **Riverpod**: Reactive programming patterns and efficient state updates.
- **StorageService**: Persistent settings and game history.

### Data Storage
- Local persistence system (SharedPreferences)
- Game cache management
- On-demand NNUE file downloading (Dio)

### Integration Points
- Chess.com public API integration
- Stockfish UCI Engine support
- FFmpeg Kit for video encoding
- Platform-specific services (Isolates, FFI)

---

## Installation and Setup

### System Requirements
- Dart SDK version 3.4.0 or higher
- Flutter Framework compatible version
- Minimum 2GB RAM for engine analysis
- Internet connection for API access and "Full" Engine Network download

### Development Setup

Clone the repository:
```bash
git clone https://github.com/shiliaiwei/brilliant_movee
cd brilliant_movee
```

Install dependencies:
```bash
flutter pub get
```

Run the application:
```bash
flutter run
```

Generate code for models:
```bash
dart run build_runner build
```

### Build Instructions

Build for Android:
```bash
flutter build apk --release
```

Build for Web:
```bash
flutter build web --release
```
elease on GitHub and uploaded the APK directly from here.
The compiled artifacts will be available in the `build/` directory. For pre-built releases, check the `release/` folder.

---

## Application Workflow Details

### Game Analysis Process

1. User initiates game review through the **Analysis** interface.
2. Application loads game data from local cache or Chess.com.
3. PGN notation is parsed into individual moves and positions.
4. Engine begins position analysis from game start using the selected **Analysis Profile**.
5. Each position is evaluated with real-time UCI feedback.
6. Move quality is determined based on evaluation swings and sacrifice detection.
7. Brilliant Moves (!!) trigger immediate UI alerts and haptic feedback.
8. User can explore the game with an automatic board orientation (User always at bottom).
9. Optional export generates shareable video content with background music.

---

## Troubleshooting Guide

### Common Issues

**Engine Analysis Not Starting**
- Verify system has sufficient RAM (especially for Grandmaster mode).
- Ensure the engine process is not locked (Try restarting the Review screen).
- Check if the "Full" network has completed downloading.

**Brilliant Moves Not Detected**
- Ensure you are using **Premium** or **Grandmaster** mode.
- Brilliancy requires a minimum of **Depth 20** to be accurately verified.

**Video Export Issues**
- Verify sufficient disk space for temporary frames.
- Ensure the app has storage permissions enabled.

---

## Roadmap and Future Enhancements

### Planned Features
- Multi-engine support (Lc0, Komodo)
- Interactive puzzle solver based on your own blunders
- Tournament integration and analysis
- Real-time multiplayer analysis features
- Expanded piece and board marketplace

### Optimization Goals
- Faster NNUE loading on low-end devices
- Improved frame-rate during video encoding
- Offline-first profile caching

---

## Version Information

- **Current Version**: 1.3.0 (Grandmaster Update)
- **Last Updated**: 2026
- **Platform Support**: Flutter (Multi-platform)
- **Minimum SDK Requirements**: Flutter 3.4.0 or higher

---

## Developed by shiliaiwei
