import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../engine/models/engine_constants.dart';
import '../../engine/models/engine_variant.dart';
import '../../core/services/engine_download_service.dart';
import '../../core/services/storage_service.dart';

class EngineDashboardScreen extends ConsumerWidget {
  const EngineDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      appBar: AppBar(
        title: const Text('ENGINE SYSTEMS'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSystemStatus(),
            const SizedBox(height: 32),
            Text(
              'NEURAL NETWORKS',
              style: AppTextStyles.badge
                  .copyWith(color: AppColors.primary, letterSpacing: 2),
            ),
            const SizedBox(height: 16),
            ...EngineConstants.variants.map((variant) {
              return _EngineVariantCard(variant: variant);
            }),
            const SizedBox(height: 40),
            _buildTechnicalSpecs(),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemStatus() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.speed_rounded, color: AppColors.primary),
              const SizedBox(width: 12),
              Text('CALCULUS PERFORMANCE',
                  style: AppTextStyles.monoLarge.copyWith(fontSize: 14)),
              const Spacer(),
              Text('OPTIMAL',
                  style:
                      AppTextStyles.badge.copyWith(color: AppColors.success)),
            ],
          ),
          const SizedBox(height: 20),
          const LinearProgressIndicator(
            value: 0.85,
            backgroundColor: Colors.white10,
            color: AppColors.primary,
            minHeight: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicalSpecs() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('CORE INFRASTRUCTURE',
              style:
                  AppTextStyles.monoSmall.copyWith(color: AppColors.primary)),
          const SizedBox(height: 12),
          _specRow('Engine Version', 'Stockfish 18 NNUE'),
          _specRow(
              'Search Algorithm', 'Selective Pruning + Correction History'),
          _specRow('Neural Arch', 'SFNNv10 (Direct Threat Scope)'),
          _specRow('Parallelism', 'Text/Raw/Heap/Stack Flow Sync'),
        ],
      ),
    );
  }

  Widget _specRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white38, fontSize: 11)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _EngineVariantCard extends ConsumerWidget {
  const _EngineVariantCard({required this.variant});
  final EngineVariant variant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadState = ref.watch(engineDownloadProvider);
    final downloadNotifier = ref.read(engineDownloadProvider.notifier);
    final storage = ref.watch(storageServiceProvider);

    final status = downloadState[variant.id];
    final isDownloading = status?.isDownloading ?? false;
    final isDownloaded = downloadNotifier.isDownloaded(variant.id);
    final isActive = storage.engineNetwork == variant.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? AppColors.primary
              : Colors.white.withValues(alpha: 0.05),
          width: isActive ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: isDownloading
            ? null
            : () async {
                if (!isDownloaded) {
                  await downloadNotifier.downloadVariant(variant);
                } else {
                  await storage.setEngineNetwork(variant.id);
                }
              },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  _buildIcon(isActive),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(variant.name,
                            style: AppTextStyles.bodyMedium
                                .copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(variant.description,
                            style:
                                AppTextStyles.caption.copyWith(fontSize: 11)),
                      ],
                    ),
                  ),
                  if (isDownloaded)
                    const Icon(Icons.verified_rounded,
                        color: AppColors.success, size: 20)
                  else
                    Text('${variant.sizeMb} MB',
                        style: AppTextStyles.monoSmall.copyWith(
                            fontSize: 10, color: AppColors.secondary)),
                ],
              ),
              if (isDownloading) ...[
                const SizedBox(height: 20),
                LinearProgressIndicator(
                  value: status?.progress ?? 0,
                  backgroundColor: Colors.white10,
                  color: AppColors.primary,
                  minHeight: 3,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Downloading...',
                        style: AppTextStyles.caption.copyWith(fontSize: 10)),
                    Text('${(status!.progress * 100).toInt()}%',
                        style: AppTextStyles.monoSmall.copyWith(fontSize: 10)),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(bool isActive) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primary.withValues(alpha: 0.1)
            : Colors.white.withValues(alpha: 0.05),
        shape: BoxShape.circle,
      ),
      child: Icon(
        variant.id == 'neural_pro'
            ? Icons.psychology_rounded
            : Icons.flash_on_rounded,
        color: isActive ? AppColors.primary : Colors.white30,
        size: 20,
      ),
    );
  }
}
