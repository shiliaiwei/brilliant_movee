import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../../engine/models/engine_variant.dart';
import 'storage_service.dart';

class DownloadStatus {
  final double progress;
  final bool isDownloading;
  final String? error;
  final String? filePath;

  const DownloadStatus({
    this.progress = 0.0,
    this.isDownloading = false,
    this.error,
    this.filePath,
  });
}

class EngineDownloadNotifier
    extends StateNotifier<Map<String, DownloadStatus>> {
  EngineDownloadNotifier(this._storage) : super({});

  final StorageService _storage;
  final Dio _dio = Dio();

  Future<void> downloadVariant(EngineVariant variant) async {
    if (variant.id == 'lite') return;

    state = {
      ...state,
      variant.id: const DownloadStatus(isDownloading: true),
    };

    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/${variant.id}.nnue';

      await _dio.download(
        variant.nnueUrl,
        filePath,
        onReceiveProgress: (count, total) {
          if (total != -1) {
            state = {
              ...state,
              variant.id: DownloadStatus(
                isDownloading: true,
                progress: count / total,
              ),
            };
          }
        },
      );

      state = {
        ...state,
        variant.id: DownloadStatus(
          isDownloading: false,
          progress: 1.0,
          filePath: filePath,
        ),
      };

      // Save to storage
      await _storage.setEngineNetwork(variant.id);
      await _storage.setFullNetPath(filePath);
    } catch (e) {
      state = {
        ...state,
        variant.id: DownloadStatus(
          isDownloading: false,
          error: e.toString(),
        ),
      };
    }
  }

  bool isDownloaded(String id) {
    if (id == 'lite') return true;
    final path = _storage.fullNetPath;
    if (path == null) return false;
    return File(path).existsSync() && path.contains(id);
  }
}

final engineDownloadProvider =
    StateNotifierProvider<EngineDownloadNotifier, Map<String, DownloadStatus>>(
        (ref) {
  return EngineDownloadNotifier(ref.read(storageServiceProvider));
});
