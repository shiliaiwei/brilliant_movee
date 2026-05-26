class EngineConfig {
  final int hash;
  final int threads;
  final int multiPv;
  final int depth;
  final bool syzygyEnabled;
  final String? nnuePath;

  const EngineConfig({
    this.hash = 4096,
    this.threads = 8,
    this.multiPv = 5,
    this.depth = 40,
    this.syzygyEnabled = true,
    this.nnuePath,
  });
}
