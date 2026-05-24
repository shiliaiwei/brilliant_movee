# Brilliant Movee - Chess Analysis Application

Brilliant Movee is a Dart/Flutter application that connects Chess.com with advanced chess engine analysis, delivering professional tactical coaching through an elegant interface. This application bridges the gap between raw engine data and human-readable tactical analysis, providing players with comprehensive insights into their game performance.

---

## Project Overview

Brilliant Movee combines Chess.com game data with real-time engine analysis to deliver professional-grade coaching and performance metrics. The application processes game histories, analyzes move quality, and presents insights in a clean, intuitive interface designed for desktop and mobile platforms.

The platform features real-time rankings, detailed performance analytics, and automated analysis workflows that turn complex chess engine evaluations into actionable feedback for improvement.

### Core Features

- Deep Engine Analysis: Advanced chess engine integration running analysis at significant depth levels
- Performance Dashboard: Professional dashboard displaying move quality breakdowns and performance metrics
- Global Rankings: Real-time rankings across multiple game categories (Rapid, Blitz, Bullet, and more)
- Move Classification: Automatic identification and classification of significant moves with detailed analysis
- Video Export: Automated recording and export of game reviews for sharing
- Cross-Platform Support: Seamless experience across mobile devices, tablets, and web browsers
- Game Archive Integration: Access to complete game history from Chess.com
- Natural Language Analysis: AI-powered coaching and move explanations
- High-Fidelity Rendering: Professional-quality board and UI rendering

---

## Complete System Architecture Flowchart

```mermaid
graph TD
    Start([User Launches Application]) --> CheckAuth{User Authenticated}
    CheckAuth -->|No| AuthFlow[Chess.com OAuth Flow]
    AuthFlow --> StoreCredentials[Store Encrypted Credentials]
    StoreCredentials --> MainDashboard
    CheckAuth -->|Yes| MainDashboard[Display Main Dashboard]
    
    MainDashboard --> UserChoice{User Action}
    
    UserChoice -->|Browse Games| HistoryFlow[Navigate to Game History]
    UserChoice -->|View Profile| ProfileFlow[View Performance Dashboard]
    UserChoice -->|Search Player| SearchFlow[Global Leaderboard Search]
    UserChoice -->|Analyze Game| ReviewFlow[Game Analysis]
    
    HistoryFlow --> FetchGames[Fetch Game Data from Chess.com API]
    FetchGames --> ParseGames[Parse Game Metadata]
    ParseGames --> CacheGames[Store in Local Cache]
    CacheGames --> DisplayList[Display Game List with Filters]
    DisplayList --> SelectGame{User Selects Game}
    SelectGame -->|Select| ReviewFlow
    SelectGame -->|Back| MainDashboard
    
    ProfileFlow --> FetchStats[Fetch Player Statistics]
    FetchStats --> CalculateMetrics[Calculate Performance Metrics]
    CalculateMetrics --> DisplayProfile[Render Analytics Dashboard]
    DisplayProfile --> BackProfile{User Action}
    BackProfile -->|Back| MainDashboard
    BackProfile -->|View Game| HistoryFlow
    
    SearchFlow --> InputSearch[User Enters Player Name]
    InputSearch --> QueryAPI[Query Chess.com Rankings API]
    QueryAPI --> DisplayResults[Show Player Rankings]
    DisplayResults --> SelectPlayer{Select Player}
    SelectPlayer -->|View| ProfileFlow
    SelectPlayer -->|Back| MainDashboard
    
    ReviewFlow --> LoadPGN[Load Game PGN Notation]
    LoadPGN --> ParsePGN[Parse PGN into Moves]
    ParsePGN --> BuildBoardStates[Generate Board States for Each Move]
    BuildBoardStates --> InitEngine[Initialize Chess Engine]
    InitEngine --> EngineReady{Engine Ready}
    
    EngineReady -->|Ready| StartAnalysis[Begin Position Analysis]
    EngineReady -->|Error| EngineError[Display Engine Error]
    EngineError --> ReviewFlow
    
    StartAnalysis --> AnalysisLoop{Process All Moves}
    AnalysisLoop -->|Remaining Moves| GetPosition[Get Next Position]
    GetPosition --> AnalyzePosition[Analyze Position with Engine]
    AnalyzePosition --> GetEvaluation[Retrieve Engine Evaluation]
    GetEvaluation --> CalculateDepth[Analyze at Depth 22+]
    CalculateDepth --> GetBestMove[Determine Best Move]
    GetBestMove --> CompareActual[Compare with Actual Move]
    CompareActual --> ClassifyMove[Classify Move Quality]
    ClassifyMove --> StoreEvaluation[Store Position Evaluation]
    StoreEvaluation --> AnalysisLoop
    
    AnalysisLoop -->|All Done| GenerateCoaching[Generate AI Coaching Text]
    GenerateCoaching --> CreateVariations[Create Alternative Variations]
    CreateVariations --> RenderBoard[Render Interactive Analysis Board]
    RenderBoard --> DisplayAnalysis[Display Move-by-Move Analysis]
    DisplayAnalysis --> UserAnalysisChoice{User Action}
    
    UserAnalysisChoice -->|Explore Move| ExploreVariation[Show Alternative Lines]
    ExploreVariation --> DisplayAnalysis
    
    UserAnalysisChoice -->|View Stats| MoveStats[Display Move Classification Stats]
    MoveStats --> DisplayAnalysis
    
    UserAnalysisChoice -->|Export Video| VideoExport[Prepare Video Export]
    VideoExport --> RenderFrames[Render Board Frames]
    RenderFrames --> EncodeVideo[Encode Video File]
    EncodeVideo --> ExportOptions{Export Format}
    ExportOptions -->|Social Media| PrepareShare[Format for Social Media]
    ExportOptions -->|Local Save| SaveFile[Save to Device Storage]
    PrepareShare --> UploadPrompt[Prompt User to Share]
    SaveFile --> ExportComplete[Export Complete]
    UploadPrompt --> ExportComplete
    ExportComplete --> DisplayAnalysis
    
    UserAnalysisChoice -->|Back| MainDashboard
    
    MainDashboard --> End([Session End])
```

---

## Detailed Game Analysis Process Flowchart

```mermaid
graph TD
    Start([Start Game Analysis]) --> Fetch[Fetch Game from Chess.com]
    Fetch --> Validate{Valid Game Data}
    Validate -->|Invalid| Error[Display Error Message]
    Error --> End([Analysis Failed])
    
    Validate -->|Valid| GetPGN[Download Game PGN]
    GetPGN --> ParsePGN[Parse PGN Notation]
    ParsePGN --> Extract[Extract Moves and Metadata]
    Extract --> CreateBoard[Initialize Chess Board]
    CreateBoard --> BuildStates[Generate Board State for Each Move]
    
    BuildStates --> EngineInit[Initialize Chess Engine Process]
    EngineInit --> CheckEngine{Engine Available}
    CheckEngine -->|Not Available| LoadEngine[Download Engine Binary]
    LoadEngine --> ConfigEngine[Configure Engine Settings]
    ConfigEngine --> EngineReady[Engine Ready]
    CheckEngine -->|Available| EngineReady
    
    EngineReady --> MoveAnalysis[Start Move Analysis Loop]
    MoveAnalysis --> MoveCounter[Initialize Move Counter]
    MoveCounter --> NextMove{More Moves to Analyze}
    
    NextMove -->|Yes| FetchPosition[Get Next Board Position]
    FetchPosition --> StockfishAnalyze[Analyze with Stockfish]
    StockfishAnalyze --> GetEval[Retrieve Position Evaluation]
    GetEval --> BestMove[Calculate Best Move]
    BestMove --> ActualMove[Get Actual Move Played]
    
    ActualMove --> Comparison{Compare Best vs Actual}
    Comparison -->|Same Move| Rating1[Excellent Move]
    Comparison -->|Within 0.5| Rating2[Good Move]
    Comparison -->|Within 2.0| Rating3[Questionable Move]
    Comparison -->|Greater 2.0| Rating4[Blunder]
    
    Rating1 --> StoreRating[Store Move Classification]
    Rating2 --> StoreRating
    Rating3 --> StoreRating
    Rating4 --> StoreRating
    
    StoreRating --> GenerateNotes[Generate AI Coaching Notes]
    GenerateNotes --> CalculateVariations[Calculate Alternative Lines]
    CalculateVariations --> StoreMoveData[Store Complete Move Data]
    StoreMoveData --> IncrementCounter[Move Counter Plus One]
    IncrementCounter --> NextMove
    
    NextMove -->|No| CompileStats[Compile Game Statistics]
    CompileStats --> CalcAccuracy[Calculate Overall Accuracy]
    CalcAccuracy --> CalcStrongest[Identify Strongest Moves]
    CalcStrongest --> CalcWeakest[Identify Weakest Moves]
    CalcWeakest --> CreateSummary[Create Game Summary Report]
    CreateSummary --> RenderDisplay[Render Analysis Display]
    RenderDisplay --> Success([Analysis Complete])
```

---

## Engine Analysis Deep Dive Flowchart

```mermaid
graph TD
    Start([Engine Analysis Request]) --> IsEngine{Engine Running}
    IsEngine -->|No| StartEngine[Start Engine Process]
    StartEngine --> ConfigEngine[Configure Depth and Time]
    ConfigEngine --> EngineRunning[Engine Process Running]
    IsEngine -->|Yes| EngineRunning
    
    EngineRunning --> Setup[Setup Analysis Parameters]
    Setup --> SetDepth[Set Analysis Depth 22+]
    SetDepth --> SetTime[Set Max Time Allocation]
    SetTime --> SetThreads[Configure Thread Count]
    SetThreads --> SendPosition[Send Position to Engine]
    
    SendPosition --> Engine[Chess Engine Processing]
    Engine --> Analyze[Begin Position Evaluation]
    Analyze --> TreeSearch[Search Move Tree]
    TreeSearch --> CalculateEvals[Calculate Position Evaluations]
    CalculateEvals --> FindBest[Find Best Move Line]
    FindBest --> GetVariations[Extract Top 3-5 Variations]
    GetVariations --> ProcessingComplete[Processing Complete]
    
    ProcessingComplete --> Results[Retrieve Results]
    Results --> Evaluation[Get Primary Evaluation]
    Evaluation --> BestMoveLine[Get Best Move Line]
    BestMoveLine --> Variations[Get Alternative Variations]
    Variations --> CheckMate{Check for Checkmate}
    
    CheckMate -->|Mate Found| MateInfo[Extract Mate in N]
    MateInfo --> ReturnMate[Return Mate Information]
    CheckMate -->|No Mate| ReturnEval[Return Normal Evaluation]
    
    ReturnMate --> Cache[Cache Results]
    ReturnEval --> Cache
    Cache --> Return[Return to Analysis Module]
    Return --> End([Analysis Complete])
```

---

## Data Flow Architecture

```mermaid
graph LR
    User[User Input] --> UI[Flutter UI Layer]
    UI --> StateMan[State Management Layer]
    StateMan --> BizLogic[Business Logic Layer]
    BizLogic --> Repo[Repository Pattern]
    
    Repo --> LocalCache[(Local Cache Database)]
    Repo --> ChessAPI[Chess.com API Service]
    Repo --> EngineService[Engine Service]
    
    ChessAPI --> ChessNet[Network Layer]
    ChessNet --> ChessServer[Chess.com Servers]
    
    EngineService --> PGNParser[PGN Parser]
    EngineService --> BoardState[Board State Manager]
    EngineService --> Stockfish[Stockfish Engine]
    
    LocalCache --> StoredData[(Persistent Storage)]
    
    PGNParser --> Moves[Move Sequence]
    BoardState --> Positions[Board Positions]
    Moves --> Engine[Engine Input]
    Positions --> Engine
    Stockfish --> Analysis[Analysis Results]
    
    Analysis --> Classifier[Move Classifier]
    Classifier --> NLP[Natural Language Generator]
    NLP --> UI
    StoredData --> UI
```

---

## User Authentication and Session Management Flowchart

```mermaid
graph TD
    Launch([App Launch]) --> CheckSession{Active Session}
    CheckSession -->|Yes| ValidateToken[Validate Token]
    ValidateToken --> IsValid{Token Valid}
    IsValid -->|Yes| LoadUser[Load User Data]
    IsValid -->|No| ClearSession[Clear Old Session]
    CheckSession -->|No| ClearSession
    
    ClearSession --> LoginScreen[Display Login Screen]
    LoginScreen --> UserChoice{User Action}
    UserChoice -->|Login| ChessOAuth[Initiate Chess.com OAuth]
    UserChoice -->|Register| RegisterFlow[New User Registration]
    UserChoice -->|Guest| GuestMode[Load Guest Session]
    
    ChessOAuth --> OpenBrowser[Open Chess.com Login Page]
    OpenBrowser --> UserAuth[User Authenticates]
    UserAuth --> ReceiveCode[Receive Auth Code]
    ReceiveCode --> ExchangeToken[Exchange Code for Token]
    ExchangeToken --> ValidateAuth{Authentication Success}
    
    ValidateAuth -->|Success| GetProfile[Fetch User Profile]
    ValidateAuth -->|Failed| AuthError[Display Auth Error]
    AuthError --> LoginScreen
    
    GetProfile --> StoreToken[Store Encrypted Token]
    StoreToken --> SaveProfile[Save Profile Locally]
    SaveProfile --> LoadUser
    
    RegisterFlow --> EnterData[User Enters Username]
    EnterData --> ValidateUsername{Username Valid}
    ValidateUsername -->|No| EnterData
    ValidateUsername -->|Yes| CreateLocal[Create Local Profile]
    CreateLocal --> LoadUser
    
    GuestMode --> LoadGuest[Load Guest Features]
    LoadGuest --> LoadUser
    
    LoadUser --> RefreshData[Refresh User Data]
    RefreshData --> CacheData[Cache User Information]
    CacheData --> MainApp[Launch Main Application]
    MainApp --> Session[Session Active]
    Session --> End([Ready for Use])
```

---

## Video Export and Rendering Pipeline Flowchart

```mermaid
graph TD
    Start([Initiate Video Export]) --> CheckSpace{Disk Space Available}
    CheckSpace -->|No| DiskError[Display Storage Error]
    DiskError --> End1([Export Failed])
    CheckSpace -->|Yes| GetConfig[Get Export Configuration]
    
    GetConfig --> SelectFormat{Video Format}
    SelectFormat -->|4:3| Set43[Set 4:3 Aspect Ratio]
    SelectFormat -->|16:9| Set169[Set 16:9 Aspect Ratio]
    SelectFormat -->|9:16| Set916[Set 9:16 Portrait]
    
    Set43 --> SetCodec[Set Codec Parameters]
    Set169 --> SetCodec
    Set916 --> SetCodec
    
    SetCodec --> SetResolution[Set Output Resolution]
    SetResolution --> SetFPS[Set Frame Rate 30 FPS]
    SetFPS --> SetBitrate[Set Bitrate 5 Mbps]
    SetBitrate --> CreateTemp[Create Temporary Directory]
    
    CreateTemp --> GetMoves[Get Analysis Moves]
    GetMoves --> MoveFrames[Render Move Display Frames]
    MoveFrames --> EvalFrames[Render Evaluation Frames]
    EvalFrames --> BoardFrames[Render Board State Frames]
    BoardFrames --> AddAnnotations[Add Move Annotations]
    AddAnnotations --> FrameQueue[Queue Frames for Encoding]
    
    FrameQueue --> EncodeStart[Start Video Encoding]
    EncodeStart --> ProcessFrames{Process All Frames}
    ProcessFrames -->|More Frames| EncodeFrame[Encode Frame]
    EncodeFrame --> WriteFrame[Write to Video File]
    WriteFrame --> ProcessFrames
    
    ProcessFrames -->|Complete| AddAudio[Add Audio Commentary]
    AddAudio --> AddSubtitles[Add Move Notation Subtitles]
    AddSubtitles --> Finalize[Finalize Video File]
    Finalize --> MoveToOutput[Move to Output Directory]
    
    MoveToOutput --> SelectDest{Select Destination}
    SelectDest -->|Device| SaveDevice[Save to Device Storage]
    SelectDest -->|Share| ShareOptions[Show Share Options]
    SelectDest -->|Social| PrepareShare[Format for Social Media]
    
    SaveDevice --> Success[Video Saved]
    ShareOptions --> Launch[Launch Share Dialog]
    Launch --> Success
    PrepareShare --> Social[Prepare for Upload]
    Social --> Success
    
    Success --> End2([Export Complete])
```

---

## Error Handling and Recovery Flowchart

```mermaid
graph TD
    Operation[Execute Operation] --> TryOp{Operation Success}
    
    TryOp -->|Error| CatchError[Catch Exception]
    TryOp -->|Success| Continue[Continue Processing]
    
    CatchError --> ErrorType{Error Type}
    
    ErrorType -->|Network Error| NetError[Handle Network Failure]
    ErrorType -->|Auth Error| AuthError[Handle Authentication]
    ErrorType -->|Engine Error| EngineError[Handle Engine Crash]
    ErrorType -->|Storage Error| StorageError[Handle Storage Issues]
    ErrorType -->|Parse Error| ParseError[Handle Data Parse Failed]
    
    NetError --> Retry{Retry Possible}
    Retry -->|Yes| ShowRetry[Show Retry Button]
    Retry -->|No| ShowOffline[Show Offline Message]
    ShowRetry --> WaitRetry[Wait for User Action]
    WaitRetry --> RetryOp{User Retries}
    RetryOp -->|Yes| Operation
    RetryOp -->|No| Cancel[Cancel Operation]
    ShowOffline --> Cancel
    
    AuthError --> ClearAuth[Clear Authentication]
    ClearAuth --> ReAuth[Request Reauthorization]
    ReAuth --> Operation
    
    EngineError --> RestartEngine[Restart Engine Process]
    RestartEngine --> Retry2{Restart Success}
    Retry2 -->|Yes| Operation
    Retry2 -->|No| ShowEngineError[Show Engine Error]
    ShowEngineError --> Cancel
    
    StorageError --> ShowStorage[Display Storage Error]
    ShowStorage --> UserChoice{User Action}
    UserChoice -->|Clear Cache| ClearCache[Clear Cache Files]
    UserChoice -->|Exit| Cancel
    ClearCache --> Operation
    
    ParseError --> LogError[Log Error Details]
    LogError --> ShowParse[Show Parse Error]
    ShowParse --> Cancel
    
    Cancel --> End([Operation Cancelled])
    Continue --> End
```

---

## Performance Metrics Monitoring Flowchart

```mermaid
graph TD
    Runtime([Application Running]) --> Monitor[Continuous Monitoring]
    Monitor --> MemTrack[Track Memory Usage]
    Monitor --> CPUTrack[Track CPU Usage]
    Monitor --> NetworkTrack[Track Network Activity]
    
    MemTrack --> CheckMemory{Memory Usage High}
    CheckMemory -->|Yes| ClearCache[Clear Cache]
    CheckMemory -->|No| Continue1[Continue Normal]
    ClearCache --> Continue1
    
    CPUTrack --> CheckCPU{CPU Usage High}
    CheckCPU -->|Yes| ThrottleAnalysis[Reduce Analysis Depth]
    CheckCPU -->|No| Continue2[Continue Normal]
    ThrottleAnalysis --> Continue2
    
    NetworkTrack --> CheckBandwidth{High Data Transfer}
    CheckBandwidth -->|Yes| CompressData[Enable Data Compression]
    CheckBandwidth -->|No| Continue3[Continue Normal]
    CompressData --> Continue3
    
    Continue1 --> Analyze[Analyze Performance Metrics]
    Continue2 --> Analyze
    Continue3 --> Analyze
    
    Analyze --> CalcLatency[Calculate API Latency]
    CalcLatency --> CalcEngineSpeed[Calculate Engine Speed]
    CalcEngineSpeed --> CalcRenderTime[Calculate Render Time]
    CalcRenderTime --> Log[Log Metrics]
    
    Log --> Upload{Send to Analytics}
    Upload -->|Yes| SendMetrics[Upload Performance Data]
    Upload -->|No| LocalLog[Store Locally]
    
    SendMetrics --> Monitor
    LocalLog --> Monitor
```

---

## Project Structure

```
lib/
  core/
    - Global theme configuration
    - Application constants
    - Shared utilities and helpers
    - Style definitions
    - Error handling utilities
    
  data/
    - Chess.com API models
    - Data repositories
    - API integration services
    - Local storage models
    - Cache management
    
  engine/
    - Chess engine bridge
    - PGN notation parser
    - Board state manager
    - Move classifier
    - Position evaluator
    - Variation calculator
    
  features/
    home/
      - Application dashboard
      - Global leaderboard display
      - Player search functionality
      - Quick stats view
      
    history/
      - Game history browser
      - Archive access interface
      - Game list display
      - Filtering and sorting
      
    profile/
      - Performance analytics dashboard
      - Statistical breakdowns
      - Progress tracking
      - Achievement display
      
    review/
      - Interactive analysis board
      - Move-by-move analysis
      - AI coaching interface
      - Variation exploration
      - Export controls
      
assets/
  - Board and piece graphics
  - UI icons and graphics
  - Theme assets
  - Custom visualizations
```

---

## Technology Stack

### Frontend Framework
- Dart Programming Language (83.9% of codebase)
- Flutter Framework for cross-platform UI
- HTML for web components (16.1% of codebase)

### State Management
- Reactive programming patterns
- Efficient state updates
- Local state caching

### Data Storage
- Local persistence system
- Encrypted credential storage
- Game cache management

### Integration Points
- Chess.com public API integration
- External engine support
- Video encoding services
- Platform-specific services

---

## Installation and Setup

### System Requirements
- Dart SDK version 3.4.0 or higher
- Flutter Framework compatible version
- Minimum 2GB RAM for engine analysis
- Internet connection for API access

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

Build for iOS:
```bash
flutter build ios --release
```

Build for Web:
```bash
flutter build web --release
```

Build for macOS:
```bash
flutter build macos --release
```

The compiled artifacts are available in the build/ directory.

---

## Application Workflow Details

### Game Analysis Process

1. User initiates game review through the history interface
2. Application loads game data from local cache or Chess.com
3. PGN notation is parsed into individual moves and positions
4. Engine begins position analysis from game start
5. Each position is evaluated with comprehensive analysis
6. Move quality is determined based on engine evaluation
7. Coaching feedback is generated for significant moves
8. UI renders interactive board with analysis overlay
9. User can explore variations and alternative moves
10. Optional export generates shareable video content

### Performance Optimization

- Background isolate processing for engine analysis
- Incremental data loading and caching
- Lazy rendering of board positions
- Network request optimization
- Local storage for frequently accessed games

### Data Management

- Automatic cache management
- Secure credential storage
- Efficient game history caching
- Bandwidth optimization
- Storage space management

---

## Configuration

### API Configuration
- Chess.com API endpoint configuration
- Rate limiting settings
- Timeout parameters
- Connection retry policies

### Engine Configuration
- Analysis depth settings
- Time control parameters
- Multi-threaded processing options
- Memory allocation settings

### UI Configuration
- Theme customization
- Layout preferences
- Animation settings
- Accessibility options

---

## Performance Metrics

### Analysis Speed
- Real-time board evaluation
- Sub-second move classification
- Efficient position caching
- Optimized variation calculation

### Memory Usage
- Efficient data structures
- Smart cache management
- Memory pooling for common objects
- Garbage collection optimization

### Network Performance
- Minimal API requests
- Efficient data compression
- Connection pooling
- Request batching

---

## Troubleshooting Guide

### Common Issues

Engine Analysis Not Starting
- Verify system has sufficient RAM
- Check engine process initialization
- Review engine configuration settings
- Ensure no conflicting processes

Chess.com Connection Failed
- Verify internet connectivity
- Check API endpoint availability
- Review authentication credentials
- Check rate limiting status

Video Export Issues
- Verify sufficient disk space
- Check video encoding configuration
- Ensure platform has codec support
- Review file permissions

Game Data Not Loading
- Clear local cache
- Verify Chess.com account access
- Check API response status
- Review game format compatibility

---

## Development Guidelines

### Code Organization
- Feature-based folder structure
- Separation of concerns
- Clear dependency flow
- Reusable component design

### Testing
- Unit test coverage for business logic
- Widget tests for UI components
- Integration tests for workflows
- Performance benchmarks

### Naming Conventions
- Clear, descriptive variable names
- Consistent method naming patterns
- Organized import statements
- Meaningful class and file names

---

## Roadmap and Future Enhancements

### Planned Features
- Enhanced AI coaching with more detailed variations
- Advanced statistics and trend analysis
- Multiplayer game analysis features
- Tournament integration and analysis
- Advanced filtering and search capabilities
- Expanded performance metrics
- Additional export formats
- Mobile app optimizations

### Optimization Goals
- Faster engine analysis
- Improved memory efficiency
- Better offline capabilities
- Enhanced UI responsiveness
- Expanded platform support

---

## Community and Support

### Getting Help
- Documentation available in project repository
- Code comments and inline documentation
- Example implementations in features
- Common issues and solutions in documentation

### Contributing
- Code contributions welcome
- Bug reports and feature requests accepted
- Documentation improvements encouraged
- Performance optimization suggestions valued

---

## Version Information

Current Version: Active Development
Last Updated: 2026
Platform Support: Flutter (Multi-platform)
Minimum SDK Requirements: Flutter 3.4.0 or higher

---

## Developed by shiliaiwei
