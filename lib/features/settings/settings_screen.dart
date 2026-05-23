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
    final storage = ref.read(storageServiceProvider);

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
              _SectionHeader(title: 'Account'),
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
                      onTap: () => _showClearCacheDialog(context, storage),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _SectionHeader(title: 'Board & Pieces'),
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
              _SectionHeader(title: 'Social & Friends'),
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
              _SectionHeader(title: 'About'),
              ChtCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    const _SettingsTile(
                      icon: Icons.info_outline_rounded,
                      title: 'App Version',
                      subtitle: '1.0.0 (Stable)',
                    ),
                    const Divider(height: 1, indent: 52),
                    const _SettingsTile(
                      icon: Icons.source_rounded,
                      title: 'Open Source',
                      subtitle: 'Powered by Stockfish 16',
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

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  void _showClearCacheDialog(BuildContext context, StorageService storage) {
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
