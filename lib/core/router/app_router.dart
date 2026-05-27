import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/history/history_screen.dart';
import '../../features/review/review_screen.dart';
import '../../features/review/widgets/cyber_button_demo_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/settings/board_selector_screen.dart';
import '../../features/profile/brilliant_games_screen.dart';
import '../../features/tips/tips_screen.dart';
import '../../features/stoic/stoic_screen.dart';
import '../../features/openings/opening_explorer_screen.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../utils/responsive.dart';

import '../../features/engine_management/engine_dashboard_screen.dart';

/// All named routes for Brilliant Movee.
abstract final class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String search = '/search';
  static const String profile = '/profile';
  static const String history = '/history';
  static const String review = '/review';
  static const String settings = '/settings';
  static const String boardSelector = '/settings/board';
  static const String engineManagement = '/settings/engine';
  static const String tips = '/tips';
  static const String stoic = '/stoic';
  static const String openings = '/openings';
  static const String brilliant = '/brilliant';
  static const String cyberDemo = '/cyber-demo';
}

class _TabItem {
  const _TabItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.route,
  });
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String route;
}

const _tabs = [
  _TabItem(
    icon: Icons.home_outlined,
    selectedIcon: Icons.home_rounded,
    label: 'Home',
    route: AppRoutes.home,
  ),
  _TabItem(
    icon: Icons.sports_esports_outlined,
    selectedIcon: Icons.sports_esports_rounded,
    label: 'Analysis',
    route: AppRoutes.history,
  ),
  _TabItem(
    icon: Icons.lightbulb_outline,
    selectedIcon: Icons.lightbulb_rounded,
    label: 'Tips',
    route: AppRoutes.tips,
  ),
  _TabItem(
    icon: Icons.grid_view_outlined,
    selectedIcon: Icons.grid_view_rounded,
    label: 'Openings',
    route: AppRoutes.openings,
  ),
  _TabItem(
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings_rounded,
    label: 'Settings',
    route: AppRoutes.settings,
  ),
];

class _ShellScaffold extends StatelessWidget {
  const _ShellScaffold({required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(index,
        initialLocation: index == navigationShell.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    if (context.isDesktop) {
      return _DesktopShell(navigationShell: navigationShell, onTap: _onTap);
    }
    if (context.isTablet) {
      return _TabletShell(navigationShell: navigationShell, onTap: _onTap);
    }
    return _MobileShell(navigationShell: navigationShell, onTap: _onTap);
  }
}

class _MobileShell extends StatelessWidget {
  const _MobileShell({required this.navigationShell, required this.onTap});
  final StatefulNavigationShell navigationShell;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.backgroundDeep,
          border: Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final tab = _tabs[i];
                final isSelected = i == navigationShell.currentIndex;
                return Expanded(
                  child: InkWell(
                    onTap: () => onTap(i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isSelected ? tab.selectedIcon : tab.icon,
                          size: 22,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tab.label,
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 9,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.bold : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _DesktopShell extends StatelessWidget {
  const _DesktopShell({required this.navigationShell, required this.onTap});
  final StatefulNavigationShell navigationShell;
  final ValueChanged<int> onTap;
  @override
  Widget build(BuildContext context) => Scaffold(
          body: Row(children: [
        _SideRail(
            currentIndex: navigationShell.currentIndex,
            onTap: onTap,
            extended: true),
        const VerticalDivider(width: 1),
        Expanded(child: navigationShell)
      ]));
}

class _TabletShell extends StatelessWidget {
  const _TabletShell({required this.navigationShell, required this.onTap});
  final StatefulNavigationShell navigationShell;
  final ValueChanged<int> onTap;
  @override
  Widget build(BuildContext context) => Scaffold(
          body: Row(children: [
        _SideRail(
            currentIndex: navigationShell.currentIndex,
            onTap: onTap,
            extended: false),
        const VerticalDivider(width: 1),
        Expanded(child: navigationShell)
      ]));
}

class _SideRail extends StatelessWidget {
  const _SideRail(
      {required this.currentIndex,
      required this.onTap,
      required this.extended});
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool extended;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: extended ? 220 : 72,
      color: AppColors.backgroundDeep,
      child: Column(
        children: [
          const SizedBox(height: 32),
          _BrandLogo(),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 12),
          ...List.generate(_tabs.length, (i) {
            final tab = _tabs[i];
            final isSelected = i == currentIndex;
            return ListTile(
              leading: Icon(isSelected ? tab.selectedIcon : tab.icon,
                  color:
                      isSelected ? AppColors.primary : AppColors.textSecondary),
              title: extended
                  ? Text(tab.label,
                      style: TextStyle(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontWeight: isSelected ? FontWeight.bold : null))
                  : null,
              onTap: () => onTap(i),
            );
          }),
        ],
      ),
    );
  }
}

class _BrandLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: AppColors.divider)),
      child: ClipOval(
          child: Image.asset('assets/brand/logo.png', fit: BoxFit.cover)),
    );
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
          path: AppRoutes.splash,
          builder: (context, state) => const SplashScreen()),
      GoRoute(
          path: AppRoutes.onboarding,
          builder: (context, state) => const OnboardingScreen()),
      GoRoute(
          path: AppRoutes.search,
          builder: (context, state) => SearchScreen(
              fromOnboarding:
                  state.uri.queryParameters['from'] == 'onboarding')),
      GoRoute(
          path: AppRoutes.profile,
          builder: (context, state) => ProfileScreen(
              username: state.uri.queryParameters['username'] ?? '')),
      GoRoute(
          path: AppRoutes.review,
          builder: (context, state) => ReviewScreen(
              gameId: state.uri.queryParameters['gameId'] ?? '',
              pgn: state.extra as String? ?? '')),
      GoRoute(
          path: AppRoutes.boardSelector,
          builder: (context, state) => const BoardSelectorScreen()),
      GoRoute(
          path: AppRoutes.engineManagement,
          builder: (context, state) => const EngineDashboardScreen()),
      GoRoute(
          path: AppRoutes.brilliant,
          builder: (context, state) => const BrilliantGamesScreen()),
      GoRoute(
          path: AppRoutes.cyberDemo,
          builder: (context, state) => const CyberButtonDemoScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) =>
            _ShellScaffold(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen())
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: AppRoutes.history,
                builder: (context, state) => const HistoryScreen())
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: AppRoutes.tips,
                builder: (context, state) => const TipsScreen())
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: AppRoutes.openings,
                builder: (context, state) => const OpeningExplorerScreen())
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: AppRoutes.settings,
                builder: (context, state) => const SettingsScreen())
          ]),
        ],
      ),
    ],
  );
});
