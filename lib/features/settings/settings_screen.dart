import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/widgets/cht_card.dart';
import '../../core/router/app_router.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/settings_provider.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/asset_service.dart';
import '../../core/models/engine_profile.dart';
import '../../core/providers/language_provider.dart';
import '../../core/localization/app_strings.dart';
import '../../core/utils/responsive.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final storage = ref.watch(storageServiceProvider);
    final currentLanguage = ref.watch(languageProvider);
    final currentProfile = EngineProfile.getByVersion(settings.engineVersion);

    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      appBar: AppBar(
        title: Text(AppStrings.getTranslation(
            AppStrings.settingsTitle, currentLanguage)),
        centerTitle: true,
        backgroundColor: AppColors.backgroundDeep,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 800));
        },
        color: AppColors.primary,
        backgroundColor: AppColors.backgroundSurface,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
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
                            context.push(
                                '${AppRoutes.profile}?username=$username');
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
                ChtCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _SettingsTile(
                        icon: Icons.psychology_rounded,
                        title: currentProfile.label,
                        subtitle: currentProfile.description,
                        onTap: () => _showEngineProfileSelector(
                            context, currentProfile, notifier),
                        trailing: const Icon(Icons.expand_more_rounded,
                            size: 18, color: AppColors.textSecondary),
                      ),
                      const Divider(height: 1, indent: 52),
                      _SettingsTile(
                        icon: Icons.timeline_rounded,
                        title: 'Maximum Time / Depth',
                        subtitle:
                            '${settings.engineDepth} depth • ${settings.multiPv} lines',
                        onTap: () => _showEngineDepthSelector(
                            context, settings.engineDepth, notifier),
                        trailing: const Icon(Icons.chevron_right_rounded,
                            color: AppColors.textSecondary),
                      ),
                      const Divider(height: 1, indent: 52),
                      _SettingsTile(
                        icon: Icons.layers_rounded,
                        title: 'Engine Lines',
                        subtitle:
                            '${settings.multiPv} variation${settings.multiPv == 1 ? '' : 's'}',
                        onTap: () => _showMultiPvSelector(
                            context, settings.multiPv, notifier),
                        trailing: const Icon(Icons.expand_more_rounded,
                            size: 18, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                const _SectionHeader(title: 'Move Feedback'),
                ChtCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _SwitchTile(
                        icon: Icons.alt_route_rounded,
                        title: 'Suggestion Arrow',
                        subtitle:
                            'Show the best-move arrow on the board and in review',
                        value: settings.showBestMoveArrows,
                        onChanged: notifier.toggleBestMoveArrows,
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
                        subtitle: '1.7.0 (Neural Update)',
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

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  void _showEngineProfileSelector(BuildContext context,
      EngineProfile currentProfile, SettingsNotifier notifier) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('SELECT CHESS ENGINE',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            ...EngineProfile.availableProfiles.map((profile) {
              final selected = profile.version == currentProfile.version;
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                leading: Icon(profile.icon, color: AppColors.primary),
                title: Text(profile.label),
                subtitle: Text(profile.description),
                trailing: selected
                    ? const Icon(Icons.check_circle_rounded,
                        color: AppColors.primary)
                    : null,
                onTap: () async {
                  await notifier.updateEngineProfile(profile);
                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showEngineDepthSelector(
      BuildContext context, int currentDepth, SettingsNotifier notifier) {
    const depths = [12, 18, 22, 26, 32, 40];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('SELECT ANALYSIS DEPTH',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            ...depths.map((depth) {
              final selected = depth == currentDepth;
              return ListTile(
                title: Text('$depth plies'),
                trailing: selected
                    ? const Icon(Icons.check_circle_rounded,
                        color: AppColors.primary)
                    : null,
                onTap: () async {
                  await notifier.updateEngineDepth(depth);
                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showMultiPvSelector(
      BuildContext context, int currentLines, SettingsNotifier notifier) {
    const lines = [1, 3, 5];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('SELECT ENGINE LINES',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            ...lines.map((count) {
              final selected = count == currentLines;
              return ListTile(
                title: Text('$count line${count == 1 ? '' : 's'}'),
                trailing: selected
                    ? const Icon(Icons.check_circle_rounded,
                        color: AppColors.primary)
                    : null,
                onTap: () async {
                  await notifier.updateMultiPv(count);
                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

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
