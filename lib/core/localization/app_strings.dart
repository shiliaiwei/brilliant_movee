/// Localization strings for Brilliant Movee
/// Supports English and Khmer
abstract class AppStrings {
  // Language names
  static const String languageEnglish = 'English';
  static const String languageKhmer = 'ភាសាខ្មែរ';

  // Navigation & Headers
  static const Map<String, String> appTitle = {
    'en': 'Brilliant Movee',
    'km': 'Brilliant Movee',
  };

  static const Map<String, String> homeTitle = {
    'en': 'Home',
    'km': 'ទំព័រដើម',
  };

  static const Map<String, String> gamesTitle = {
    'en': 'Games',
    'km': 'ហ្គេម',
  };

  static const Map<String, String> tipsTitle = {
    'en': 'Tips',
    'km': 'គន្លឹះ',
  };

  static const Map<String, String> stoicTitle = {
    'en': 'Stoic',
    'km': 'ស្តូអ៊ីក',
  };

  static const Map<String, String> settingsTitle = {
    'en': 'Settings',
    'km': 'ការកំណត់',
  };

  // Settings - Language
  static const Map<String, String> languageLabel = {
    'en': 'Language',
    'km': 'ភាសា',
  };

  static const Map<String, String> languageDescription = {
    'en': 'Choose your preferred language',
    'km': 'ជ្រើសរើសភាសាដែលអ្នកចូលចិត្ត',
  };

  // Account Settings
  static const Map<String, String> accountSection = {
    'en': 'Account',
    'km': 'គណនី',
  };

  static const Map<String, String> myProfile = {
    'en': 'My Profile',
    'km': 'ប្រវត្តិរូបខ្ញុំ',
  };

  static const Map<String, String> viewChessStats = {
    'en': 'View your chess stats and progress',
    'km': 'មើលស្ថិតិនិងការរីកចម្រើនរបស់អ្នក',
  };

  static const Map<String, String> connectedUsername = {
    'en': 'Connected Username',
    'km': 'ឈ្មោះគណនីដែលភ្ជាប់',
  };

  static const Map<String, String> notConnected = {
    'en': 'Not connected',
    'km': 'មិនទាន់ភ្ជាប់',
  };

  static const Map<String, String> clearCache = {
    'en': 'Clear Cache',
    'km': 'សម្អាតទិន្នន័យបណ្តោះអាសន្ន',
  };

  static const Map<String, String> removeLoaclGames = {
    'en': 'Remove locally stored games',
    'km': 'លុបហ្គេមដែលបានរក្សាទុកក្នុងម៉ាស៊ីន',
  };

  // Board & Pieces
  static const Map<String, String> boardPiecesSection = {
    'en': 'Board & Pieces',
    'km': 'ក្តារ និង កូនអុក',
  };

  static const Map<String, String> boardPieceStyle = {
    'en': 'Board & Piece Style',
    'km': 'រចនាប័ទ្មក្តារ និង កូនអុក',
  };

  static const Map<String, String> showCoordinates = {
    'en': 'Show Coordinates',
    'km': 'បង្ហាញកូអរដោនេ',
  };

  static const Map<String, String> displayCoordinates = {
    'en': 'Display a-h and 1-8 on edges',
    'km': 'បង្ហាញ a-h និង 1-8 នៅតាមគែម',
  };

  static const Map<String, String> highlightLastMove = {
    'en': 'Highlight Last Move',
    'km': 'បង្ហាញសញ្ញាលើចលនាចុងក្រោយ',
  };

  static const Map<String, String> showLastMoveMarkers = {
    'en': 'Show markers for last played move',
    'km': 'បង្ហាញសញ្ញាសម្គាល់សម្រាប់ចលនាចុងក្រោយ',
  };

  // Engine Settings
  static const Map<String, String> engineAnalysisSection = {
    'en': 'Engine & Analysis',
    'km': 'ម៉ាស៊ីន និង ការវិភាគ',
  };

  static const Map<String, String> autoDeepAnalysis = {
    'en': 'Auto Deep Analysis',
    'km': 'ការវិភាគស៊ីជម្រៅស្វ័យប្រវត្តិ',
  };

  static const Map<String, String> startStockfishAuto = {
    'en': 'Start Stockfish analysis automatically',
    'km': 'ចាប់ផ្តើមការវិភាគ Stockfish ដោយស្វ័យប្រវត្តិ',
  };

  static const Map<String, String> engineVersion = {
    'en': 'Engine Version',
    'km': 'កំណែម៉ាស៊ីន',
  };

  static const Map<String, String> aboutSection = {
    'en': 'About',
    'km': 'អំពី',
  };

  static const Map<String, String> appVersion = {
    'en': 'App Version',
    'km': 'កំណែកម្មវិធី',
  };

  static const Map<String, String> openSource = {
    'en': 'Open Source',
    'km': 'ប្រភពបើកចំហ',
  };

  static const Map<String, String> poweredByStockfish = {
    'en': 'Powered by Stockfish',
    'km': 'ដំណើរការដោយ Stockfish',
  };

  // Tips Screen
  static const Map<String, String> tipsScreenTitle = {
    'en': 'Tips',
    'km': 'គន្លឹះ',
  };

  static const Map<String, String> noTipsAvailable = {
    'en': 'No tips available yet',
    'km': 'មិនទាន់មានគន្លឹះនៅឡើយទេ',
  };

  static const Map<String, String> failedToLoadTips = {
    'en': 'Failed to load tips. Please restart the app.',
    'km': 'មិនអាចទាញយកគន្លឹះបានទេ។ សូមបើកកម្មវិធីឡើងវិញ។',
  };

  static const Map<String, String> retryButton = {
    'en': 'RETRY',
    'km': 'ព្យាយាមម្តងទៀត',
  };

  // Tip Categories
  static const Map<String, String> categoryOpening = {
    'en': 'Opening',
    'km': 'ការបើក',
  };

  static const Map<String, String> categoryMiddlegame = {
    'en': 'Middlegame',
    'km': 'ពាក់កណ្តាលហ្គេម',
  };

  static const Map<String, String> categoryEndgame = {
    'en': 'Endgame',
    'km': 'ចុងហ្គេម',
  };

  static const Map<String, String> categoryTactics = {
    'en': 'Tactics',
    'km': 'យុទ្ធសាស្ត្រ',
  };

  static const Map<String, String> categoryMindset = {
    'en': 'Mindset',
    'km': 'តម្រង់ឧបាយ',
  };

  static const Map<String, String> categoryStoic = {
    'en': 'Stoic',
    'km': 'ស្តូអ៊ីក',
  };

  // New Settings Labels
  static const Map<String, String> soundSection = {
    'en': 'Sounds & Audio',
    'km': 'សំឡេង និង អូឌីយ៉ូ',
  };

  static const Map<String, String> soundPack = {
    'en': 'Sound Pack',
    'km': 'កញ្ចប់សំឡេង',
  };

  static const Map<String, String> engineProfile = {
    'en': 'Analysis Profile',
    'km': 'កម្រិតនៃការវិភាគ',
  };

  static String getTranslation(Map<String, String> translations, String lang) {
    return translations[lang] ?? translations['en'] ?? '';
  }
}
