import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Describes a piece set available locally.
class PieceSetInfo {
  const PieceSetInfo({required this.id, required this.name});
  final String id;
  final String name;

  String pieceAsset(String piece) => 'assets/pieces/$id/$piece.png';
}

/// Describes a board theme available locally.
class BoardThemeInfo {
  const BoardThemeInfo(
      {required this.id, required this.name, required this.file});
  final String id;
  final String name;
  final String file;
}

/// Describes a sound pack available locally.
class SoundPackInfo {
  const SoundPackInfo({required this.id, required this.name});
  final String id;
  final String name;

  String soundAsset(String sound) => 'assets/sounds/${id}_$sound.mp3';
}

/// Service for loading all local assets.
/// Never downloads from network — all assets are bundled.
class AssetService {
  AssetService._();

  static final AssetService instance = AssetService._();

  List<PieceSetInfo> _pieceSets = [];
  List<BoardThemeInfo> _boardThemes = [];
  List<SoundPackInfo> _soundPacks = [];
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      final manifestJson =
          await rootBundle.loadString('assets/data/asset_manifest.json');
      final manifest = jsonDecode(manifestJson) as Map<String, dynamic>;

      _pieceSets = (manifest['piece_sets'] as List)
          .map((e) => PieceSetInfo(id: e['id'], name: e['name']))
          .toList();

      _boardThemes = (manifest['board_themes'] as List)
          .map((e) =>
              BoardThemeInfo(id: e['id'], name: e['name'], file: e['file']))
          .toList();

      _soundPacks = (manifest['sound_packs'] as List)
          .map((e) => SoundPackInfo(id: e['id'], name: e['name']))
          .toList();

      _initialized = true;
    } catch (e) {
      // Fallback to hardcoded defaults if manifest fails
      _pieceSets = _defaultPieceSets;
      _boardThemes = _defaultBoardThemes;
      _soundPacks = _defaultSoundPacks;
      _initialized = true;
    }
  }

  List<PieceSetInfo> get pieceSets => List.unmodifiable(_pieceSets);
  List<BoardThemeInfo> get boardThemes => List.unmodifiable(_boardThemes);
  List<SoundPackInfo> get soundPacks => List.unmodifiable(_soundPacks);

  PieceSetInfo pieceSetById(String id) => _pieceSets
      .firstWhere((p) => p.id == id, orElse: () => _defaultPieceSets.first);

  BoardThemeInfo boardThemeById(String id) => _boardThemes
      .firstWhere((b) => b.id == id, orElse: () => _defaultBoardThemes.first);

  /// Returns the asset path for a piece image.
  /// piece: e.g. 'wK', 'bQ', 'wP'
  String pieceAsset(String pieceSetId, String piece) =>
      'assets/pieces/$pieceSetId/$piece.png';

  static const _defaultPieceSets = [
    PieceSetInfo(id: 'defaultP', name: 'Professional (SVG)'),
    PieceSetInfo(id: 'Merida15', name: 'Merida Vector'),
    PieceSetInfo(id: 'cburnett', name: 'CBurnett'),
    PieceSetInfo(id: 'alpha', name: 'Alpha'),
    PieceSetInfo(id: 'merida', name: 'Merida Classic'),
    PieceSetInfo(id: 'maestro', name: 'Maestro'),
    PieceSetInfo(id: 'tatiana', name: 'Tatiana'),
    PieceSetInfo(id: 'staunty', name: 'Staunty'),
    PieceSetInfo(id: 'california', name: 'California'),
    PieceSetInfo(id: 'pirouetti', name: 'Pirouetti'),
  ];

  static const _defaultBoardThemes = [
    BoardThemeInfo(
        id: '200', name: 'Classic Brown', file: 'assets/boards/200.png'),
    BoardThemeInfo(
        id: 'blue2', name: 'Ocean Blue', file: 'assets/boards/blue2.jpg'),
    BoardThemeInfo(
        id: 'grey', name: 'Industrial Grey', file: 'assets/boards/grey.jpg'),
    BoardThemeInfo(
        id: 'maple', name: 'Maple Wood', file: 'assets/boards/maple.jpg'),
    BoardThemeInfo(
        id: 'wood4', name: 'Dark Walnut', file: 'assets/boards/wood4.jpg'),
    BoardThemeInfo(
        id: 'marble', name: 'Marble', file: 'assets/boards/marble.png'),
    BoardThemeInfo(id: 'glass', name: 'Glass', file: 'assets/boards/glass.png'),
    BoardThemeInfo(
        id: 'neon', name: 'Cyber Neon', file: 'assets/boards/neon.png'),
    BoardThemeInfo(
        id: 'graffiti', name: 'Graffiti', file: 'assets/boards/graffiti.png'),
    BoardThemeInfo(
        id: '8_bit', name: '8-Bit Retro', file: 'assets/boards/8_bit.png'),
    BoardThemeInfo(
        id: 'newspaper',
        name: 'Newspaper',
        file: 'assets/boards/newspaper.png'),
    BoardThemeInfo(
        id: 'checkers', name: 'Checkers', file: 'assets/boards/checkers.png'),
    BoardThemeInfo(
        id: 'icy_sea', name: 'Icy Sea', file: 'assets/boards/icy_sea.png'),
    BoardThemeInfo(
        id: 'parchment',
        name: 'Parchment',
        file: 'assets/boards/parchment.png'),
    BoardThemeInfo(id: 'stone', name: 'Stone', file: 'assets/boards/stone.png'),
    BoardThemeInfo(
        id: 'tournament',
        name: 'Tournament',
        file: 'assets/boards/tournament.png'),
    BoardThemeInfo(
        id: 'purple', name: 'Royal Purple', file: 'assets/boards/purple.png'),
    BoardThemeInfo(
        id: 'green-plastic',
        name: 'Green Plastic',
        file: 'assets/boards/green-plastic.png'),
    BoardThemeInfo(
        id: 'walnut', name: 'Walnut', file: 'assets/boards/walnut.png'),
    BoardThemeInfo(id: 'sand', name: 'Sand', file: 'assets/boards/sand.png'),
    BoardThemeInfo(id: 'metal', name: 'Metal', file: 'assets/boards/metal.png'),
    BoardThemeInfo(id: 'olive', name: 'Olive', file: 'assets/boards/olive.jpg'),
    BoardThemeInfo(
        id: 'dark_wood',
        name: 'Dark Wood',
        file: 'assets/boards/dark_wood.png'),
  ];

  static const _defaultSoundPacks = [
    SoundPackInfo(id: 'standard', name: 'Standard'),
    SoundPackInfo(id: 'piano', name: 'Piano'),
    SoundPackInfo(id: 'nes', name: 'NES Retro'),
    SoundPackInfo(id: 'sfx', name: 'Modern SFX'),
    SoundPackInfo(id: 'futuristic', name: 'Cybernetic'),
    SoundPackInfo(id: 'lisp', name: 'Voice Cues'),
  ];
}

final assetServiceProvider = Provider<AssetService>((ref) {
  return AssetService.instance;
});
