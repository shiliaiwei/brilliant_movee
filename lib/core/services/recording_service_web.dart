import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class RecordingService {
  RecordingService._();
  static final RecordingService instance = RecordingService._();

  bool get isRecording => false;

  Future<ui.Image?> captureFrame(GlobalKey key,
      {double pixelRatio = 1.0}) async {
    return null;
  }

  Future<void> startBackgroundMusic(String path, double volume) async {}
  Future<void> stopBackgroundMusic() async {}

  Future<String?> generateGameVideo({
    required List<ui.Image> frames,
    required double fps,
    String? musicPath,
    double musicVolume = 1.0,
    Size resolution = const Size(1080, 1080),
  }) async {
    return null;
  }
}
