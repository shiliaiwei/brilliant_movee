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
import '../../features/settings/settings_screen.dart';
import '../../features/settings/board_selector_screen.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_spacing.dart';
import '../utils/responsive.dart';

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
    icon: Icons.history_outlined,
    selectedIcon: Icons.history_rounded,
    label: 'History',
    route: AppRoutes.history,
  ),
  _TabItem(
    icon: Icons.analytics_outlined,
    selectedIcon: Icons.analytics_rounded,
    label: 'Analyze',
    route: '/analyze',
  ),
  _TabItem(
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings_rounded,
    label: 'Settings',
    route: AppRoutes.settings,
  ),
];

/// Adaptive shell — bottom nav on mobile, side nav on desktop.
class _ShellScaffold extends StatelessWidget {
  const _ShellScaffold({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (context.isDesktop) {
      return _DesktopShell(
        navigationShell: navigationShell,
        onTap: _onTap,
      );
    }
    if (context.isTablet) {
      return _TabletShell(
        navigationShell: navigationShell,
        onTap: _onTap,
      );
    }
    return _MobileShell(
      navigationShell: navigationShell,
      onTap: _onTap,
    );
  }
}

// ── Mobile Shell — bottom navigation bar ─────────────────────────────────────

class _MobileShell extends StatelessWidget {
  const _MobileShell({
    required this.navigationShell,
    required this.onTap,
  });

  final StatefulNavigationShell navigationShell;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _BottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: onTap,
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundSurface,
        border: Border(
          top: BorderSide(color: AppColors.primaryBorder, width: 1),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(_tabs.length, (i) {
              final tab = _tabs[i];
              final isSelected = i == currentIndex;
              return Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onTap(i),
                    splashColor: AppColors.primaryGlow,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryGlow
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isSelected ? tab.selectedIcon : tab.icon,
                            size: 22,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tab.label,
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 10,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ── Tablet Shell — NavigationRail (collapsed, icons only) ────────────────────

class _TabletShell extends StatelessWidget {
  const _TabletShell({
    required this.navigationShell,
    required this.onTap,
  });

  final StatefulNavigationShell navigationShell;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _SideRail(
            currentIndex: navigationShell.currentIndex,
            onTap: onTap,
            extended: false,
          ),
          const VerticalDivider(
            width: 1,
            thickness: 1,
            color: AppColors.primaryBorder,
          ),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }
}

// ── Desktop Shell — full side navigation with labels ─────────────────────────

class _DesktopShell extends StatelessWidget {
  const _DesktopShell({
    required this.navigationShell,
    required this.onTap,
  });

  final StatefulNavigationShell navigationShell;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _SideRail(
            currentIndex: navigationShell.currentIndex,
            onTap: onTap,
            extended: true,
          ),
          const VerticalDivider(
            width: 1,
            thickness: 1,
            color: AppColors.primaryBorder,
          ),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }
}

class _SideRail extends StatelessWidget {
  const _SideRail({
    required this.currentIndex,
    required this.onTap,
    required this.extended,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool extended; // true = show labels (desktop), false = icons only (tablet)

  @override
  Widget build(BuildContext context) {
    final width = extended ? Breakpoints.sideNavWidth : Breakpoints.railWidth;

    return Container(
      width: width,
      color: AppColors.backgroundSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand header
          Padding(
            padding: EdgeInsets.fromLTRB(
              extended ? 20 : 0,
              24,
              extended ? 20 : 0,
              20,
            ),
            child: extended
                ? Row(
                    children: [
                      _BrandLogo(),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'BRILLIANT',
                              style: AppTextStyles.badge.copyWith(
                                color: AppColors.primary,
                                letterSpacing: 2,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              'MOVEE',
                              style: AppTextStyles.badge.copyWith(
                                color: AppColors.textPrimary,
                                letterSpacing: 2,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Center(child: _BrandLogo()),
          ),

          const Divider(color: AppColors.primaryBorder, height: 1),
          const SizedBox(height: 8),

          // Nav items
          ...List.generate(_tabs.length, (i) {
            final tab = _tabs[i];
            final isSelected = i == currentIndex;
            return _SideNavItem(
              icon: isSelected ? tab.selectedIcon : tab.icon,
              label: tab.label,
              isSelected: isSelected,
              extended: extended,
              onTap: () => onTap(i),
            );
          }),

          const Spacer(),

          // Version at bottom
          if (extended)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text('v1.0.0', style: AppTextStyles.caption),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _BrandLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/brand/logo.png',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: AppColors.backgroundElevated,
            child: const Icon(
              Icons.sports_esports_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

class _SideNavItem extends StatelessWidget {
  const _SideNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.extended,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final bool extended;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: extended ? 12 : 8,
        vertical: 2,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          splashColor: AppColors.primaryGlow,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 48,
            padding: EdgeInsets.symmetric(
              horizontal: extended ? 12 : 0,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryGlow
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: isSelected
                  ? Border.all(color: AppColors.primaryBorder, width: 1)
                  : null,
            ),
            child: extended
                ? Row(
                    children: [
                      Icon(
                        icon,
                        size: 20,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        label,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Tooltip(
                      message: label,
                      child: Icon(
                        icon,
                        size: 22,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// GoRouter provider.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.search,
        builder: (context, state) {
          final fromOnboarding =
              state.uri.queryParameters['from'] == 'onboarding';
          return SearchScreen(fromOnboarding: fromOnboarding);
        },
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) {
          final username = state.uri.queryParameters['username'] ?? '';
          return ProfileScreen(username: username);
        },
      ),
      GoRoute(
        path: AppRoutes.review,
        builder: (context, state) {
          final gameId = state.uri.queryParameters['gameId'] ?? '';
          final pgn = state.extra as String? ?? '';
          return ReviewScreen(gameId: gameId, pgn: pgn);
        },
      ),
      GoRoute(
        path: AppRoutes.boardSelector,
        builder: (context, state) => const BoardSelectorScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) =>
            _ShellScaffold(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.history,
                builder: (context, state) => const HistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/analyze',
                builder: (context, state) => const SearchScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
