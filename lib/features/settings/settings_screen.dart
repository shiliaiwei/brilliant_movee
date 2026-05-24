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
import '../../core/utils/responsive.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final storage = ref.watch(storageServiceProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      appBar: AppBar(
        title: const Text('Settings'),
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
              const _SectionHeader(title: 'Account'),
              ChtCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.account_circle_rounded,
                      title: 'My Profile',
                      subtitle: 'View your chess stats and progress',
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
                      title: 'Connected Username',
                      subtitle: storage.connectedUsername ?? 'Not connected',
                      onTap: () => context.go(AppRoutes.search),
                      trailing: const Icon(Icons.sync_rounded,
                          size: 18, color: AppColors.textSecondary),
                    ),
                    const Divider(height: 1, indent: 52),
                    _SettingsTile(
                      icon: Icons.delete_outline_rounded,
                      title: 'Clear Cache',
                      subtitle: 'Remove locally stored games',
                      onTap: () => _showClearCacheDialog(context, ref, storage),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const _SectionHeader(title: 'Board & Pieces'),
              ChtCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.grid_on_rounded,
                      title: 'Board & Piece Style',
                      subtitle:
                          '${_capitalize(settings.boardTheme)} board · ${_capitalize(settings.pieceSet)} pieces',
                      onTap: () => context.push(AppRoutes.boardSelector),
                      trailing: const Icon(Icons.chevron_right_rounded,
                          color: AppColors.textSecondary),
                    ),
                    const Divider(height: 1, indent: 52),
                    _SwitchTile(
                      icon: Icons.grid_3x3_rounded,
                      title: 'Show Coordinates',
                      subtitle: 'Display a-h and 1-8 on edges',
                      value: settings.showCoordinates,
                      onChanged: notifier.toggleCoordinates,
                    ),
                    const Divider(height: 1, indent: 52),
                    _SwitchTile(
                      icon: Icons.highlight_rounded,
                      title: 'Highlight Last Move',
                      subtitle: 'Show markers for last played move',
                      value: settings.highlightLastMove,
                      onChanged: notifier.toggleHighlight,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const _SectionHeader(title: 'Engine & Analysis'),
              ChtCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _SwitchTile(
                      icon: Icons.psychology_rounded,
                      title: 'Auto Deep Analysis',
                      subtitle: 'Start Stockfish analysis automatically',
                      value: settings.autoAnalyze,
                      onChanged: notifier.toggleAutoAnalyze,
                    ),
                    const Divider(height: 1, indent: 52),
                    _SettingsTile(
                      icon: Icons.bolt_rounded,
                      title: 'Engine Version',
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
              const _SectionHeader(title: 'Social & Friends'),
              ChtCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.people_outline_rounded,
                      title: 'Following & Friends',
                      subtitle: 'Sync your Chess.com social data',
                      onTap: () {},
                      trailing: const Icon(Icons.lock_outline_rounded,
                          size: 18, color: AppColors.textDisabled),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const _SectionHeader(title: 'About'),
              const ChtCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.info_outline_rounded,
                      title: 'App Version',
                      subtitle: '1.0.0 (Stable)',
                    ),
                    Divider(height: 1, indent: 52),
                    _SettingsTile(
                      icon: Icons.source_rounded,
                      title: 'Open Source',
                      subtitle: 'Powered by Stockfish-sf_18',
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

  void _showClearCacheDialog(
      BuildContext context, WidgetRef ref, StorageService storage) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Clear Cache?', style: AppTextStyles.title),
        content: const Text(
            'This will remove all locally stored games. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              storage.clearAll();
              ref.read(connectedUsernameProvider.notifier).state = null;
              Navigator.pop(ctx);
            },
            child: Text('Clear All',
                style:
                    AppTextStyles.bodyMedium.copyWith(color: AppColors.error)),
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
