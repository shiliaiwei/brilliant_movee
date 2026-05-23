/// PGN parser for Brilliant Movee.
/// Extracts moves, headers, and FEN positions from PGN strings.
library;

class PgnGame {
  const PgnGame({
    required this.headers,
    required this.moves,
    required this.result,
  });

  final Map<String, String> headers;
  final List<PgnMove> moves;
  final String result;

  String? get white => headers['White'];
  String? get black => headers['Black'];
  String? get event => headers['Event'];
  String? get date => headers['Date'];
  String? get opening => headers['Opening'];
  String? get eco => headers['ECO'];
  String? get timeControl => headers['TimeControl'];
  String? get termination => headers['Termination'];
}

class PgnMove {
  const PgnMove({
    required this.moveNumber,
    required this.san,
    required this.isWhite,
    this.comment,
    this.nag,
  });

  final int moveNumber;
  final String san; // Standard Algebraic Notation e.g. 'e4', 'Nf3', 'O-O'
  final bool isWhite;
  final String? comment;
  final String? nag; // Numeric Annotation Glyph e.g. '!', '?', '!!'

  String get fullNotation {
    if (isWhite) return '$moveNumber. $san';
    return '$moveNumber... $san';
  }
}

/// Parses a PGN string into a PgnGame object.
abstract final class PgnParser {
  static PgnGame parse(String pgn) {
    final headers = <String, String>{};
    final moves = <PgnMove>[];
    String result = '*';

    // Split into header section and moves section
    final lines = pgn.split('\n');
    final headerLines = <String>[];
    final moveLines = <String>[];
    bool inMoves = false;

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        if (headerLines.isNotEmpty) inMoves = true;
        continue;
      }
      if (trimmed.startsWith('[') && !inMoves) {
        headerLines.add(trimmed);
      } else {
        moveLines.add(trimmed);
        inMoves = true;
      }
    }

    // Parse headers
    for (final line in headerLines) {
      final match = RegExp(r'\[(\w+)\s+"([^"]*)"\]').firstMatch(line);
      if (match != null) {
        headers[match.group(1)!] = match.group(2)!;
      }
    }

    // Parse moves
    final movesText = moveLines.join(' ');
    result = headers['Result'] ?? '*';

    final moveTokens = _tokenizeMoves(movesText);
    int moveNumber = 1;
    bool isWhite = true;

    for (final token in moveTokens) {
      if (token == result || token == '*') break;

      // Move number indicator (e.g., "1." or "1...")
      if (RegExp(r'^\d+\.+$').hasMatch(token)) {
        final num = int.tryParse(token.replaceAll('.', ''));
        if (num != null) moveNumber = num;
        isWhite = !token.contains('...');
        continue;
      }

      // Skip result tokens
      if (token == '1-0' || token == '0-1' || token == '1/2-1/2') {
        result = token;
        break;
      }

      // Skip NAG tokens (e.g., $1, $2)
      if (token.startsWith(r'$')) continue;

      // Valid SAN move
      if (_isValidSan(token)) {
        moves.add(PgnMove(
          moveNumber: moveNumber,
          san: token,
          isWhite: isWhite,
        ));
        if (!isWhite) moveNumber++;
        isWhite = !isWhite;
      }
    }

    return PgnGame(headers: headers, moves: moves, result: result);
  }

  static List<String> _tokenizeMoves(String movesText) {
    // Remove comments in braces
    final noComments = movesText.replaceAll(RegExp(r'\{[^}]*\}'), '');
    // Remove variations in parentheses
    final noVariations = noComments.replaceAll(RegExp(r'\([^)]*\)'), '');
    // Separate move numbers from moves (e.g., "1.e4" -> "1. e4")
    final separated = noVariations.replaceAllMapped(
      RegExp(r'(\d+\.+)([^\s\.].*)'),
      (match) => '${match.group(1)} ${match.group(2)}',
    );
    // Split on whitespace
    return separated.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
  }

  static bool _isValidSan(String token) {
    // Basic SAN validation
    if (token.isEmpty) return false;
    if (token == 'O-O' || token == 'O-O-O') return true;
    // Piece moves: Nf3, Bxe5, Qd8+, etc.
    return RegExp(r'^[KQRBN]?[a-h]?[1-8]?x?[a-h][1-8][+#=QRBN]?[+#]?$')
        .hasMatch(token);
  }
}
