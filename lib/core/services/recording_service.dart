import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';
import 'package:just_audio/just_audio.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class RecordingService {
  RecordingService._();
  static final RecordingService instance = RecordingService._();

  bool _isRecording = false;
  bool get isRecording => _isRecording;

  final AudioPlayer _previewPlayer = AudioPlayer();

  /// Captures a widget to an Image
  Future<ui.Image?> captureFrame(GlobalKey key,
      {double pixelRatio = 1.0}) async {
    try {
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      return await boundary.toImage(pixelRatio: pixelRatio);
    } catch (e) {
      debugPrint('Capture error: $e');
      return null;
    }
  }

  /// Start playing background music in sync with recording
  Future<void> startBackgroundMusic(String path, double volume) async {
    try {
      await _previewPlayer.setFilePath(path);
      await _previewPlayer.setVolume(volume);
      await _previewPlayer.play();
    } catch (e) {
      debugPrint('Music play error: $e');
    }
  }

  Future<void> stopBackgroundMusic() async {
    await _previewPlayer.stop();
  }

  /// Generates video from frames using FFmpeg
  Future<String?> generateGameVideo({
    required List<ui.Image> frames,
    required double fps,
    String? musicPath,
    double musicVolume = 1.0,
    Size resolution = const Size(1080, 1080),
  }) async {
    _isRecording = true;
    const Uuid uuid = Uuid();

    try {
      final tempDir = await getTemporaryDirectory();
      final framesDir = Directory(
          '${tempDir.path}/frames_${DateTime.now().millisecondsSinceEpoch}');
      if (framesDir.existsSync()) framesDir.deleteSync(recursive: true);
      framesDir.createSync();

      // 1. Save frames to disk
      for (int i = 0; i < frames.length; i++) {
        final byteData =
            await frames[i].toByteData(format: ui.ImageByteFormat.png);
        if (byteData != null) {
          final file = File(
              '${framesDir.path}/frame_${i.toString().padLeft(4, '0')}.png');
          await file.writeAsBytes(byteData.buffer.asUint8List());
        }
      }

      // 2. Prepare output path (Downloads folder on Android)
      String outputPath;
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filename = '${timestamp}_${uuid.v4().substring(0, 8)}.mp4';

      if (Platform.isAndroid) {
        // Standard Android Downloads path
        outputPath = '/storage/emulated/0/Download/$filename';
      } else {
        final docDir = await getApplicationDocumentsDirectory();
        outputPath = '${docDir.path}/$filename';
      }

      // 3. Build FFmpeg command
      // -r: input framerate
      // -i: input pattern
      // -s: resolution (e.g. 1080x1080)
      // -vf: scale and pad to ensure even dimensions (required by some encoders)
      String videoArgs = '-r $fps -i ${framesDir.path}/frame_%04d.png '
          '-vf "scale=${resolution.width.toInt()}:${resolution.height.toInt()}:force_original_aspect_ratio=decrease,pad=${resolution.width.toInt()}:${resolution.height.toInt()}:(ow-iw)/2:(oh-ih)/2" '
          '-c:v libx264 -pix_fmt yuv420p';

      String command;
      if (musicPath != null && File(musicPath).existsSync()) {
        // Mix audio if provided
        // -i: music input
        // -filter_complex: adjust volume
        // -shortest: end video when frames end
        command = '$videoArgs -i "$musicPath" '
            '-filter_complex "[1:a]volume=$musicVolume[a]" '
            '-map 0:v -map "[a]" -shortest -y "$outputPath"';
      } else {
        command = '$videoArgs -y "$outputPath"';
      }

      debugPrint('FFmpeg executing: $command');

      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        debugPrint('Video saved successfully: $outputPath');
        // Clean up frames
        framesDir.deleteSync(recursive: true);
        return outputPath;
      } else {
        final logs = await session.getLogs();
        for (var log in logs) {
          debugPrint('FFmpeg log: ${log.getMessage()}');
        }
        return null;
      }
    } catch (e) {
      debugPrint('Recording service error: $e');
      return null;
    } finally {
      _isRecording = false;
      await stopBackgroundMusic();
    }
  }
}
