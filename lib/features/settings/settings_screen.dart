import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/widgets/cht_card.dart';
import '../../core/router/app_router.dart';
import '../../core/services/storage_service.dart';
import '../../core/utils/responsive.dart';

// Settings state provider
final _settingsProvider =
    StateNotifierProvider<_SettingsNotifier, _SettingsState>((ref) {
  final storage = ref.read(storageServiceProvider);
  return _SettingsNotifier(storage);
});

class _SettingsState {
  const _SettingsState({
    required this.engineDepth,
    required this.multiPv,
    required this.autoAnalyze,
    required this.showBestMoveArrows,
    required this.soundEnabled,
    required this.hapticEnabled,
    required this.showCoordinates,
    required this.highlightLastMove,
    required this.moveAnimationSpeed,
    required this.brilliantSensitivity,
    required this.boardTheme,
    required this.pieceSet,
  });

  final int engineDepth;
  final int multiPv;
  final bool autoAnalyze;
  final bool showBestMoveArrows;
  final bool soundEnabled;
  final bool hapticEnabled;
  final bool showCoordinates;
  final bool highlightLastMove;
  final String moveAnimationSpeed;
  final String brilliantSensitivity;
  final String boardTheme;
  final String pieceSet;
}

class _SettingsNotifier extends StateNotifier<_SettingsState> {
  _SettingsNotifier(this._storage)
      : super(_SettingsState(
          engineDepth: _storage.engineDepth,
          multiPv: _storage.multiPv,
          autoAnalyze: _storage.autoAnalyze,
          showBestMoveArrows: _storage.showBestMoveArrows,
          soundEnabled: _storage.soundEnabled,
          hapticEnabled: _storage.hapticEnabled,
          showCoordinates: _storage.showCoordinates,
          highlightLastMove: _storage.highlightLastMove,
          moveAnimationSpeed: _storage.moveAnimationSpeed,
          brilliantSensitivity: _storage.brilliantSensitivity,
          boardTheme: _storage.boardTheme,
          pieceSet: _storage.pieceSet,
        ));

  final StorageService _storage;

  void setEngineDepth(int v) {
    _storage.setEngineDepth(v);
    state = _SettingsState(
      engineDepth: v,
      multiPv: state.multiPv,
      autoAnalyze: state.autoAnalyze,
      showBestMoveArrows: state.showBestMoveArrows,
      soundEnabled: state.soundEnabled,
      hapticEnabled: state.hapticEnabled,
      showCoordinates: state.showCoordinates,
      highlightLastMove: state.highlightLastMove,
      moveAnimationSpeed: state.moveAnimationSpeed,
      brilliantSensitivity: state.brilliantSensitivity,
      boardTheme: state.boardTheme,
      pieceSet: state.pieceSet,
    );
  }

  void setMultiPv(int v) {
    _storage.setMultiPv(v);
    state = state._copyWith(multiPv: v);
  }

  void setAutoAnalyze(bool v) {
    _storage.setAutoAnalyze(v);
    state = state._copyWith(autoAnalyze: v);
  }

  void setShowBestMoveArrows(bool v) {
    _storage.setShowBestMoveArrows(v);
    state = state._copyWith(showBestMoveArrows: v);
  }

  void setSoundEnabled(bool v) {
    _storage.setSoundEnabled(v);
    state = state._copyWith(soundEnabled: v);
  }

  void setHapticEnabled(bool v) {
    _storage.setHapticEnabled(v);
    state = state._copyWith(hapticEnabled: v);
  }

  void setShowCoordinates(bool v) {
    _storage.setShowCoordinates(v);
    state = state._copyWith(showCoordinates: v);
  }

  void setHighlightLastMove(bool v) {
    _storage.setHighlightLastMove(v);
    state = state._copyWith(highlightLastMove: v);
  }

  void setMoveAnimationSpeed(String v) {
    _storage.setMoveAnimationSpeed(v);
    state = state._copyWith(moveAnimationSpeed: v);
  }

  void setBrilliantSensitivity(String v) {
    _storage.setBrilliantSensitivity(v);
    state = state._copyWith(brilliantSensitivity: v);
  }
}

extension on _SettingsState {
  _SettingsState _copyWith({
    int? engineDepth,
    int? multiPv,
    bool? autoAnalyze,
    bool? showBestMoveArrows,
    bool? soundEnabled,
    bool? hapticEnabled,
    bool? showCoordinates,
    bool? highlightLastMove,
    String? moveAnimationSpeed,
    String? brilliantSensitivity,
    String? boardTheme,
    String? pieceSet,
  }) {
    return _SettingsState(
      engineDepth: engineDepth ?? this.engineDepth,
      multiPv: multiPv ?? this.multiPv,
      autoAnalyze: autoAnalyze ?? this.autoAnalyze,
      showBestMoveArrows: showBestMoveArrows ?? this.showBestMoveArrows,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
      showCoordinates: showCoordinates ?? this.showCoordinates,
      highlightLastMove: highlightLastMove ?? this.highlightLastMove,
      moveAnimationSpeed: moveAnimationSpeed ?? this.moveAnimationSpeed,
      brilliantSensitivity: brilliantSensitivity ?? this.brilliantSensitivity,
      boardTheme: boardTheme ?? this.boardTheme,
      pieceSet: pieceSet ?? this.pieceSet,
    );
  }
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(_settingsProvider);
    final notifier = ref.read(_settingsProvider.notifier);
    final storage = ref.read(storageServiceProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.backgroundDeep,
      ),
      body: context.isWide
          ? _WideSettingsLayout(
              settings: settings,
              notifier: notifier,
              storage: storage,
              context: context,
            )
          : _NarrowSettingsList(
              settings: settings,
              notifier: notifier,
              storage: storage,
            ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  void _showClearCacheDialog(BuildContext context, StorageService storage) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundElevated,
        title: Text('Clear Cache', style: AppTextStyles.title),
        content: Text(
          'This will remove all locally stored games. You can re-fetch them from Chess.com.',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              storage.clearAll();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared')),
              );
            },
            child: Text('Clear',
                style: AppTextStyles.body.copyWith(color: AppColors.error)),
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
      padding: const EdgeInsets.only(
        bottom: AppSpacing.sm,
        left: AppSpacing.xs,
      ),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.caption.copyWith(
          color: AppColors.primary,
          letterSpacing: 1.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      color: AppColors.divider,
      indent: 52,
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.bodyMedium),
                    if (subtitle != null)
                      Text(subtitle!, style: AppTextStyles.caption),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
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
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

class _SliderTile extends StatelessWidget {
  const _SliderTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: AppTextStyles.bodyMedium),
                    Text(
                      '${value.round()}',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                Text(subtitle, style: AppTextStyles.caption),
                Slider(
                  value: value,
                  min: min,
                  max: max,
                  divisions: divisions,
                  onChanged: onChanged,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentTile extends StatelessWidget {
  const _SegmentTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyMedium),
                Text(subtitle, style: AppTextStyles.caption),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: options.map((opt) {
                    final isSelected = opt == selected;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: GestureDetector(
                          onTap: () => onSelect(opt),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 32,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryGlow
                                  : AppColors.backgroundElevated,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.chip),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.primaryBorder,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                opt,
                                style: AppTextStyles.label.copyWith(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared settings sections builder ─────────────────────────────────────────

List<Widget> _buildAccountSection(
  BuildContext context,
  StorageService storage,
) {
  return [
    _SectionHeader(title: 'Account'),
    ChtCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _SettingsTile(
            icon: Icons.person_rounded,
            title: 'Connected Username',
            subtitle: storage.connectedUsername ?? 'Not connected',
            onTap: () => context.go(AppRoutes.search),
            trailing: const Icon(Icons.chevron_right_rounded,
                color: AppColors.textSecondary),
          ),
          _Divider(),
          _SettingsTile(
            icon: Icons.delete_outline_rounded,
            title: 'Clear Cache',
            subtitle: 'Remove locally stored games',
            onTap: () => _showClearCacheDialog(context, storage),
          ),
        ],
      ),
    ),
  ];
}

List<Widget> _buildAnalysisSection(
  _SettingsState settings,
  _SettingsNotifier notifier,
) {
  return [
    _SectionHeader(title: 'Analysis'),
    ChtCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _SliderTile(
            icon: Icons.psychology_rounded,
            title: 'Engine Depth',
            subtitle: 'Higher = stronger but slower',
            value: settings.engineDepth.toDouble(),
            min: 10,
            max: 22,
            divisions: 12,
            onChanged: (v) => notifier.setEngineDepth(v.round()),
          ),
          _Divider(),
          _SegmentTile(
            icon: Icons.format_list_numbered_rounded,
            title: 'Analysis Lines',
            subtitle: 'Number of engine lines shown',
            options: const ['1', '2', '3'],
            selected: '${settings.multiPv}',
            onSelect: (v) => notifier.setMultiPv(int.parse(v)),
          ),
          _Divider(),
          _SwitchTile(
            icon: Icons.auto_awesome_rounded,
            title: 'Auto-Analyze',
            subtitle: 'Analyze game automatically on open',
            value: settings.autoAnalyze,
            onChanged: notifier.setAutoAnalyze,
          ),
          _Divider(),
          _SwitchTile(
            icon: Icons.arrow_forward_rounded,
            title: 'Show Best Move Arrows',
            subtitle: 'Display engine best move on board',
            value: settings.showBestMoveArrows,
            onChanged: notifier.setShowBestMoveArrows,
          ),
          _Divider(),
          _SegmentTile(
            icon: Icons.star_rounded,
            title: 'Brilliant Sensitivity',
            subtitle: 'How strictly brilliant moves are detected',
            options: const ['Low', 'Medium', 'High'],
            selected: _capitalizeStr(settings.brilliantSensitivity),
            onSelect: (v) => notifier.setBrilliantSensitivity(v.toLowerCase()),
          ),
        ],
      ),
    ),
  ];
}

List<Widget> _buildBoardSection(
  BuildContext context,
  _SettingsState settings,
  _SettingsNotifier notifier,
) {
  return [
    _SectionHeader(title: 'Board & Pieces'),
    ChtCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _SettingsTile(
            icon: Icons.grid_on_rounded,
            title: 'Board & Piece Style',
            subtitle:
                '${_capitalizeStr(settings.boardTheme)} board · ${_capitalizeStr(settings.pieceSet)} pieces',
            onTap: () => context.go(AppRoutes.boardSelector),
            trailing: const Icon(Icons.chevron_right_rounded,
                color: AppColors.textSecondary),
          ),
          _Divider(),
          _SwitchTile(
            icon: Icons.grid_3x3_rounded,
            title: 'Show Coordinates',
            subtitle: 'Display a-h and 1-8 on board edges',
            value: settings.showCoordinates,
            onChanged: notifier.setShowCoordinates,
          ),
          _Divider(),
          _SwitchTile(
            icon: Icons.highlight_rounded,
            title: 'Highlight Last Move',
            subtitle: 'Highlight the last played move',
            value: settings.highlightLastMove,
            onChanged: notifier.setHighlightLastMove,
          ),
          _Divider(),
          _SegmentTile(
            icon: Icons.speed_rounded,
            title: 'Move Animation Speed',
            subtitle: 'Speed of piece movement animation',
            options: const ['Slow', 'Normal', 'Fast'],
            selected: _capitalizeStr(settings.moveAnimationSpeed),
            onSelect: (v) => notifier.setMoveAnimationSpeed(v.toLowerCase()),
          ),
        ],
      ),
    ),
  ];
}

List<Widget> _buildSoundSection(
  _SettingsState settings,
  _SettingsNotifier notifier,
) {
  return [
    _SectionHeader(title: 'Sound & Haptics'),
    ChtCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _SwitchTile(
            icon: Icons.volume_up_rounded,
            title: 'Master Sound',
            subtitle: 'Enable all sound effects',
            value: settings.soundEnabled,
            onChanged: notifier.setSoundEnabled,
          ),
          _Divider(),
          _SwitchTile(
            icon: Icons.vibration_rounded,
            title: 'Haptic Feedback',
            subtitle: 'Vibrate on moves and events',
            value: settings.hapticEnabled,
            onChanged: notifier.setHapticEnabled,
          ),
        ],
      ),
    ),
  ];
}

List<Widget> _buildAboutSection() {
  return [
    _SectionHeader(title: 'About'),
    ChtCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          const _SettingsTile(
            icon: Icons.info_outline_rounded,
            title: 'App Version',
            subtitle: '1.0.0',
          ),
          _Divider(),
          const _SettingsTile(
            icon: Icons.psychology_rounded,
            title: 'Engine',
            subtitle: 'Stockfish 16 (simulation mode)',
          ),
          _Divider(),
          const _SettingsTile(
            icon: Icons.source_rounded,
            title: 'Data Sources',
            subtitle: 'Chess.com Public API · Lichess Assets',
          ),
        ],
      ),
    ),
  ];
}

String _capitalizeStr(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

void _showClearCacheDialog(BuildContext context, StorageService storage) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.backgroundElevated,
      title: Text('Clear Cache', style: AppTextStyles.title),
      content: Text(
        'This will remove all locally stored games. You can re-fetch them from Chess.com.',
        style: AppTextStyles.body,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text('Cancel',
              style: AppTextStyles.body
                  .copyWith(color: AppColors.textSecondary)),
        ),
        TextButton(
          onPressed: () {
            storage.clearAll();
            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cache cleared')),
            );
          },
          child: Text('Clear',
              style: AppTextStyles.body.copyWith(color: AppColors.error)),
        ),
      ],
    ),
  );
}

// ── Narrow (mobile) settings list ────────────────────────────────────────────

class _NarrowSettingsList extends StatelessWidget {
  const _NarrowSettingsList({
    required this.settings,
    required this.notifier,
    required this.storage,
  });

  final _SettingsState settings;
  final _SettingsNotifier notifier;
  final StorageService storage;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: context.screenPadding,
        vertical: AppSpacing.screenV,
      ),
      children: [
        ..._buildAccountSection(context, storage),
        const SizedBox(height: AppSpacing.xl),
        ..._buildAnalysisSection(settings, notifier),
        const SizedBox(height: AppSpacing.xl),
        ..._buildBoardSection(context, settings, notifier),
        const SizedBox(height: AppSpacing.xl),
        ..._buildSoundSection(settings, notifier),
        const SizedBox(height: AppSpacing.xl),
        ..._buildAboutSection(),
        const SizedBox(height: AppSpacing.xxxl),
      ],
    );
  }
}

// ── Wide (desktop/tablet) settings: two-column layout ────────────────────────

class _WideSettingsLayout extends StatelessWidget {
  const _WideSettingsLayout({
    required this.settings,
    required this.notifier,
    required this.storage,
    required this.context,
  });

  final _SettingsState settings;
  final _SettingsNotifier notifier;
  final StorageService storage;
  final BuildContext context;

  @override
  Widget build(BuildContext ctx) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: ctx.screenPadding,
        vertical: AppSpacing.screenV,
      ),
      child: ResponsiveContainer(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left column: Account + Board + Sound
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ..._buildAccountSection(ctx, storage),
                  const SizedBox(height: AppSpacing.xl),
                  ..._buildBoardSection(ctx, settings, notifier),
                  const SizedBox(height: AppSpacing.xl),
                  ..._buildSoundSection(settings, notifier),
                  const SizedBox(height: AppSpacing.xxxl),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xxl),
            // Right column: Analysis + About
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ..._buildAnalysisSection(settings, notifier),
                  const SizedBox(height: AppSpacing.xl),
                  ..._buildAboutSection(),
                  const SizedBox(height: AppSpacing.xxxl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
