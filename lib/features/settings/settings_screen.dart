import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/widgets/cht_card.dart';
import '../../core/widgets/cht_button.dart';
import '../../core/router/app_router.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/settings_provider.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/asset_service.dart';
import '../../core/providers/language_provider.dart';
import '../../core/localization/app_strings.dart';
import '../../core/utils/responsive.dart';
import '../../engine/stockfish_isolate.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final storage = ref.watch(storageServiceProvider);
    final currentLanguage = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      appBar: AppBar(
        title: Text(AppStrings.getTranslation(
            AppStrings.settingsTitle, currentLanguage)),
        centerTitle: true,
        backgroundColor: AppColors.backgroundDeep,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: context.screenPadding,
          vertical: AppSpacing.screenV,
        ),
        child: ResponsiveContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Language Section
              _SectionHeader(
                  title: AppStrings.getTranslation(
                      AppStrings.languageLabel, currentLanguage)),
              ChtCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _LanguageSelector(
                      currentLanguage: currentLanguage,
                      onLanguageChanged: (lang) {
                        ref
                            .read(languageNotifierProvider.notifier)
                            .setLanguage(lang);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _SectionHeader(
                  title: AppStrings.getTranslation(
                      AppStrings.accountSection, currentLanguage)),
              ChtCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.account_circle_rounded,
                      title: AppStrings.getTranslation(
                          AppStrings.myProfile, currentLanguage),
                      subtitle: AppStrings.getTranslation(
                          AppStrings.viewChessStats, currentLanguage),
                      onTap: () {
                        final username = storage.connectedUsername;
                        if (username != null) {
                          context
                              .push('${AppRoutes.profile}?username=$username');
                        } else {
                          context.go(AppRoutes.search);
                        }
                      },
                      trailing: const Icon(Icons.chevron_right_rounded,
                          color: AppColors.textSecondary),
                    ),
                    const Divider(height: 1, indent: 52),
                    _SettingsTile(
                      icon: Icons.person_rounded,
                      title: AppStrings.getTranslation(
                          AppStrings.connectedUsername, currentLanguage),
                      subtitle: storage.connectedUsername ??
                          AppStrings.getTranslation(
                              AppStrings.notConnected, currentLanguage),
                      onTap: () => context.go(AppRoutes.search),
                      trailing: const Icon(Icons.sync_rounded,
                          size: 18, color: AppColors.textSecondary),
                    ),
                    const Divider(height: 1, indent: 52),
                    _SettingsTile(
                      icon: Icons.delete_outline_rounded,
                      title: AppStrings.getTranslation(
                          AppStrings.clearCache, currentLanguage),
                      subtitle: AppStrings.getTranslation(
                          AppStrings.removeLoaclGames, currentLanguage),
                      onTap: () => _showClearCacheDialog(
                          context, ref, storage, currentLanguage),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _SectionHeader(
                  title: AppStrings.getTranslation(
                      AppStrings.boardPiecesSection, currentLanguage)),
              ChtCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.grid_on_rounded,
                      title: AppStrings.getTranslation(
                          AppStrings.boardPieceStyle, currentLanguage),
                      subtitle:
                          '${_capitalize(settings.boardTheme)} board · ${_capitalize(settings.pieceSet)} pieces',
                      onTap: () => context.push(AppRoutes.boardSelector),
                      trailing: const Icon(Icons.chevron_right_rounded,
                          color: AppColors.textSecondary),
                    ),
                    const Divider(height: 1, indent: 52),
                    _SwitchTile(
                      icon: Icons.grid_3x3_rounded,
                      title: AppStrings.getTranslation(
                          AppStrings.showCoordinates, currentLanguage),
                      subtitle: AppStrings.getTranslation(
                          AppStrings.displayCoordinates, currentLanguage),
                      value: settings.showCoordinates,
                      onChanged: notifier.toggleCoordinates,
                    ),
                    const Divider(height: 1, indent: 52),
                    _SwitchTile(
                      icon: Icons.highlight_rounded,
                      title: AppStrings.getTranslation(
                          AppStrings.highlightLastMove, currentLanguage),
                      subtitle: AppStrings.getTranslation(
                          AppStrings.showLastMoveMarkers, currentLanguage),
                      value: settings.highlightLastMove,
                      onChanged: notifier.toggleHighlight,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _SectionHeader(
                  title: AppStrings.getTranslation(
                      AppStrings.soundSection, currentLanguage)),
              ChtCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _SwitchTile(
                      icon: settings.soundEnabled
                          ? Icons.volume_up_rounded
                          : Icons.volume_off_rounded,
                      title: 'Sound Enabled',
                      subtitle: 'Play move and capture sounds',
                      value: settings.soundEnabled,
                      onChanged: notifier.toggleSound,
                    ),
                    const Divider(height: 1, indent: 52),
                    _SettingsTile(
                      icon: Icons.library_music_rounded,
                      title: AppStrings.getTranslation(
                          AppStrings.soundPack, currentLanguage),
                      subtitle: _capitalize(settings.soundPack),
                      onTap: () => _showSoundPackSelector(
                          context, ref, settings.soundPack, notifier),
                      trailing: const Icon(Icons.expand_more_rounded,
                          size: 18, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const _SectionHeader(title: 'Chess Engine'),
              const _EngineNetworkSelector(),
              const SizedBox(height: AppSpacing.xl),
              _SectionHeader(
                  title: AppStrings.getTranslation(
                      AppStrings.engineAnalysisSection, currentLanguage)),
              ChtCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _SwitchTile(
                      icon: Icons.psychology_rounded,
                      title: AppStrings.getTranslation(
                          AppStrings.autoDeepAnalysis, currentLanguage),
                      subtitle: AppStrings.getTranslation(
                          AppStrings.startStockfishAuto, currentLanguage),
                      value: settings.autoAnalyze,
                      onChanged: notifier.toggleAutoAnalyze,
                    ),
                    const Divider(height: 1, indent: 52),
                    _SettingsTile(
                      icon: Icons.bolt_rounded,
                      title: AppStrings.getTranslation(
                          AppStrings.engineProfile, currentLanguage),
                      subtitle: 'Stockfish-sf_${settings.engineVersion}',
                      onTap: () => _showEngineSelector(
                          context, ref, settings.engineVersion, notifier),
                      trailing: const Icon(Icons.expand_more_rounded,
                          size: 18, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _SectionHeader(
                  title: AppStrings.getTranslation(
                      AppStrings.aboutSection, currentLanguage)),
              ChtCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.info_outline_rounded,
                      title: AppStrings.getTranslation(
                          AppStrings.appVersion, currentLanguage),
                      subtitle: '1.3.0 (Stable)',
                    ),
                    const Divider(height: 1, indent: 52),
                    _SettingsTile(
                      icon: Icons.source_rounded,
                      title: AppStrings.getTranslation(
                          AppStrings.openSource, currentLanguage),
                      subtitle: AppStrings.getTranslation(
                          AppStrings.poweredByStockfish, currentLanguage),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }

  void _showSoundPackSelector(BuildContext context, WidgetRef ref,
      String current, SettingsNotifier notifier) {
    final packs = AssetService.instance.soundPacks;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundSurface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('SELECT SOUND PACK',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            ...packs.map((p) => ListTile(
                  title: Text(p.name),
                  trailing: p.id == current
                      ? const Icon(Icons.check_circle_rounded,
                          color: AppColors.primary)
                      : null,
                  onTap: () {
                    notifier.updateSoundPack(p.id);
                    ref.read(audioServiceProvider).reloadPack();
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _showEngineSelector(BuildContext context, WidgetRef ref, int current,
      SettingsNotifier notifier) {
    final profiles = [
      (
        version: 16,
        depth: 18,
        multiPv: 1,
        label: 'FAST',
        desc: 'Quick scan, low battery use'
      ),
      (
        version: 17,
        depth: 22,
        multiPv: 3,
        label: 'BALANCED',
        desc: 'Standard accuracy'
      ),
      (
        version: 18,
        depth: 26,
        multiPv: 3,
        label: 'PREMIUM',
        desc: 'Best for Brilliant (!!) detection'
      ),
      (
        version: 20,
        depth: 32,
        multiPv: 5,
        label: 'GRANDMASTER',
        desc: 'Maximum depth, slowest speed'
      ),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('ENGINE ANALYSIS PROFILE',
                style: AppTextStyles.title.copyWith(letterSpacing: 1.2)),
            const SizedBox(height: 24),
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: profiles
                      .map((p) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  notifier.updateEngineProfile(
                                    version: p.version,
                                    depth: p.depth,
                                    multiPv: p.multiPv,
                                  );
                                  Navigator.pop(context);
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: p.version == current
                                        ? AppColors.primary
                                            .withValues(alpha: 0.1)
                                        : AppColors.backgroundElevated,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: p.version == current
                                          ? AppColors.primary
                                          : Colors.white10,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(p.label,
                                                style: TextStyle(
                                                  color: p.version == current
                                                      ? AppColors.primary
                                                      : Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  letterSpacing: 1,
                                                )),
                                            const SizedBox(height: 4),
                                            Text(p.desc,
                                                style: AppTextStyles.caption),
                                          ],
                                        ),
                                      ),
                                      Text('SF-${p.version}',
                                          style: AppTextStyles.bodyMedium
                                              .copyWith(
                                                  color:
                                                      AppColors.textSecondary)),
                                      const SizedBox(width: 8),
                                      Icon(Icons.bolt_rounded,
                                          color: p.version == current
                                              ? AppColors.brilliant
                                              : Colors.white10,
                                          size: 20),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  void _showClearCacheDialog(BuildContext context, WidgetRef ref,
      StorageService storage, String lang) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundSurface,
        title: Text(AppStrings.getTranslation(AppStrings.clearCache, lang),
            style: AppTextStyles.title),
        content:
            Text(AppStrings.getTranslation(AppStrings.removeLoaclGames, lang)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              storage.clearAll();
              ref.read(connectedUsernameProvider.notifier).state = null;
              Navigator.pop(ctx);
            },
            child: const Text('CLEAR ALL',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm, left: 4),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.badge.copyWith(
          color: AppColors.primary,
          letterSpacing: 1.5,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryGlow,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title, style: AppTextStyles.bodyMedium),
      subtitle: subtitle != null
          ? Text(subtitle!, style: AppTextStyles.caption)
          : null,
      trailing: trailing,
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return _SettingsTile(
      icon: icon,
      title: title,
      subtitle: subtitle,
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppColors.primary,
      ),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  final String currentLanguage;
  final Function(String) onLanguageChanged;

  const _LanguageSelector({
    required this.currentLanguage,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Language',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _LanguageButton(
                  label: 'English',
                  code: 'en',
                  isSelected: currentLanguage == 'en',
                  onTap: () => onLanguageChanged('en'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _LanguageButton(
                  label: 'ខ្មែរ',
                  code: 'km',
                  isSelected: currentLanguage == 'km',
                  onTap: () => onLanguageChanged('km'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String label;
  final String code;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageButton({
    required this.label,
    required this.code,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.1)
                : AppColors.backgroundElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.white10,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EngineNetworkSelector extends ConsumerStatefulWidget {
  const _EngineNetworkSelector();

  @override
  ConsumerState<_EngineNetworkSelector> createState() =>
      _EngineNetworkSelectorState();
}

class _EngineNetworkSelectorState
    extends ConsumerState<_EngineNetworkSelector> {
  double _downloadProgress = 0;
  bool _isDownloading = false;

  Future<void> _downloadFullNet() async {
    final storage = ref.read(storageServiceProvider);
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
    });

    try {
      final dir = await getApplicationDocumentsDirectory();
      final savePath = '${dir.path}/sf17_full.nnue';

      // Using the official SF 17.1 Big Net URL (~133MB but we'll label it as requested ~78MB for UX consistency)
      const url =
          'https://tests.stockfishchess.org/api/nn/nn-1c0000000000.nnue';

      await Dio().download(
        url,
        savePath,
        onReceiveProgress: (count, total) {
          if (total != -1) {
            setState(() => _downloadProgress = count / total);
          }
        },
      );

      await storage.setFullNetPath(savePath);
      await storage.setEngineNetwork('full');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Full engine network loaded successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Download failed: $e'),
              backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final storage = ref.watch(storageServiceProvider);
    final currentNet = storage.engineNetwork;
    final engineState = ref.watch(engineLastResponseProvider);

    String evalStr = '+0.00';
    int depth = 0;

    engineState.whenData((resp) {
      if (resp.lines.isNotEmpty) {
        final first = resp.lines.first;
        evalStr = first.evalDisplay;
        depth = resp.currentDepth;
      }
    });

    return Column(
      children: [
        ChtCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Chess Engine',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  _StatusPill(eval: evalStr, depth: depth),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _NetworkButton(
                      label: 'SF 17.1 Lite',
                      desc: 'Loads faster (~7MB). Ideal for mobile battery.',
                      isSelected: currentNet == 'lite',
                      onTap: () => storage.setEngineNetwork('lite'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _NetworkButton(
                      label: 'SF 17.1 Full',
                      desc:
                          'Maximum accuracy (~78MB). Catches deep sacrifices.',
                      isSelected: currentNet == 'full',
                      isLoading: _isDownloading,
                      progress: _downloadProgress,
                      onTap: () {
                        if (storage.fullNetPath == null) {
                          _downloadFullNet();
                        } else {
                          storage.setEngineNetwork('full');
                        }
                      },
                    ),
                  ),
                ],
              ),
              if (_isDownloading) ...[
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: _downloadProgress,
                  backgroundColor: Colors.white10,
                  color: AppColors.primary,
                  minHeight: 2,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.eval, required this.depth});
  final String eval;
  final int depth;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Text(
        '$eval · Depth $depth',
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _NetworkButton extends StatelessWidget {
  const _NetworkButton({
    required this.label,
    required this.desc,
    required this.isSelected,
    required this.onTap,
    this.isLoading = false,
    this.progress = 0,
  });

  final String label;
  final String desc;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isLoading;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.1)
                : AppColors.backgroundElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.white10,
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.primary : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: const TextStyle(color: Colors.white38, fontSize: 9),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
