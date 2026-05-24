/// Stub for Stockfish class when compiling for web.
class Stockfish {
  Stream<String> get stdout => const Stream.empty();
  set stdin(String command) {}
  void dispose() {}
}
