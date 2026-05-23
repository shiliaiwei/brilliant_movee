import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ffmpeg_kit_flutter_full/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full/return_code.dart';

class RecordingService {
  RecordingService._();
  static final RecordingService instance = RecordingService._();

  bool _isRecording = false;
  bool get isRecording => _isRecording;

  Future<String?> generateGameVideo({
    required List<ui.Image> frames,
    required double fps,
  }) async {
    _isRecording = true;
    try {
      final tempDir = await getTemporaryDirectory();
      final framesDir = Directory('${tempDir.path}/frames');
      if (framesDir.existsSync()) framesDir.deleteSync(recursive: true);
      framesDir.createSync();

      // Save frames to disk
      for (int i = 0; i < frames.length; i++) {
        final byteData =
            await frames[i].toByteData(format: ui.ImageByteFormat.png);
        if (byteData != null) {
          final file = File(
              '${framesDir.path}/frame_${i.toString().padLeft(4, '0')}.png');
          await file.writeAsBytes(byteData.buffer.asUint8List());
        }
      }

      final outputPath =
          '${tempDir.path}/chess_review_${DateTime.now().millisecondsSinceEpoch}.mp4';

      // FFmpeg command to stitch images into a video
      // -r: input framerate
      // -i: input pattern
      // -c:v libx264: video codec
      // -pix_fmt yuv420p: compatibility for most players
      final command =
          '-r $fps -i ${framesDir.path}/frame_%04d.png -c:v libx264 -pix_fmt yuv420p -y $outputPath';

      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        return outputPath;
      } else {
        debugPrint('FFmpeg failed: ${await session.getOutput()}');
        return null;
      }
    } catch (e) {
      debugPrint('Recording error: $e');
      return null;
    } finally {
      _isRecording = false;
    }
  }

  /// Capture a widget to an Image using its GlobalKey
  Future<ui.Image?> captureFrame(GlobalKey key) async {
    try {
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      return await boundary.toImage(pixelRatio: 1.0);
    } catch (e) {
      return null;
    }
  }
}
