import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/widgets/cht_button.dart';
import '../../core/widgets/cht_card.dart';
import '../../core/services/storage_service.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/responsive.dart';
import '../../data/repositories/player_repository.dart';

final _searchStateProvider =
    StateNotifierProvider.autoDispose<_SearchNotifier, _SearchState>((ref) {
  return _SearchNotifier(
    ref.read(playerRepositoryProvider),
    ref.read(storageServiceProvider),
  );
});

class _SearchState {
  const _SearchState({
    this.isLoading = false,
    this.error,
    this.username = '',
  });

  final bool isLoading;
  final String? error;
  final String username;

  _SearchState copyWith({bool? isLoading, String? error, String? username}) {
    return _SearchState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      username: username ?? this.username,
    );
  }
}

class _SearchNotifier extends StateNotifier<_SearchState> {
  _SearchNotifier(this._repo, this._storage) : super(const _SearchState());

  final PlayerRepository _repo;
  final StorageService _storage;

  void updateUsername(String value) {
    state = state.copyWith(
      username: value.toLowerCase().trim(),
      error: null,
    );
  }

  Future<bool> connect(BuildContext context) async {
    final username = state.username.trim();
    if (username.isEmpty) {
      state = state.copyWith(error: 'Please enter a username');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final isValid = await _repo.validateUsername(username);
      if (!isValid) {
        state = state.copyWith(
          isLoading: false,
          error: 'Player not found on Chess.com',
        );
        return false;
      }

      await _storage.setConnectedUsername(username);
      await _storage.addRecentUsername(username);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Connection failed. Check your internet and try again.',
      );
      return false;
    }
  }
}

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key, this.fromOnboarding = false});

  final bool fromOnboarding;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _shakeKey = GlobalKey<_ShakeWidgetState>();

  @override
  void initState() {
    super.initState();
    // Pre-fill with connected username if available
    final username = ref.read(storageServiceProvider).connectedUsername;
    if (username != null) {
      _controller.text = username;
      ref.read(_searchStateProvider.notifier).updateUsername(username);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    _focusNode.unfocus();
    final success =
        await ref.read(_searchStateProvider.notifier).connect(context);

    if (!mounted) return;

    if (success) {
      final username = ref.read(_searchStateProvider).username;
      context.push('${AppRoutes.profile}?username=$username');
    } else {
      _shakeKey.currentState?.shake();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(_searchStateProvider);
    final recentUsernames = ref.read(storageServiceProvider).recentUsernames;

    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      appBar: widget.fromOnboarding
          ? null
          : AppBar(
              title: const Text('Connect Account'),
              backgroundColor: AppColors.backgroundDeep,
            ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.heroGradient,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: context.screenPadding,
                vertical: AppSpacing.screenV,
              ),
              child: ConstrainedBox(
                // Cap form width on wide screens for readability
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (widget.fromOnboarding) ...[
                      const SizedBox(height: AppSpacing.xxxl),
                      // App logo
                      Container(
                        width: 100,
                        height: 100,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                          border:
                              Border.all(color: AppColors.divider, width: 1),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/brand/logo.png',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.sports_esports_rounded,
                              color: AppColors.primary,
                              size: 48,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        'Connect Your Account',
                        style: AppTextStyles.headline,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Enter your Chess.com username to load your games.',
                        style: AppTextStyles.bodyMuted,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xxxl),
                    ],

                    // Username field with shake animation
                    _ShakeWidget(
                      key: _shakeKey,
                      child: _UsernameField(
                        controller: _controller,
                        focusNode: _focusNode,
                        error: state.error,
                        onChanged: (v) => ref
                            .read(_searchStateProvider.notifier)
                            .updateUsername(v),
                        onSubmitted: (_) => _connect(),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // Connect button
                    ChtButton(
                      label: 'Connect',
                      onPressed: state.isLoading ? null : _connect,
                      isLoading: state.isLoading,
                      icon: Icons.link_rounded,
                    ),

                    // Recent usernames
                    if (recentUsernames.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xxl),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Recent',
                          style: AppTextStyles.labelMuted,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: recentUsernames.map((u) {
                          return ActionChip(
                            label: Text(u, style: AppTextStyles.label),
                            backgroundColor: AppColors.backgroundElevated,
                            side: const BorderSide(
                                color: AppColors.primaryBorder),
                            onPressed: () {
                              _controller.text = u;
                              ref
                                  .read(_searchStateProvider.notifier)
                                  .updateUsername(u);
                            },
                          );
                        }).toList(),
                      ),
                    ],

                    const SizedBox(height: AppSpacing.xxl),

                    // Info card
                    ChtCard(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              'Uses Chess.com public API. No password required.',
                              style: AppTextStyles.caption,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UsernameField extends StatelessWidget {
  const _UsernameField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSubmitted,
    this.error,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          autocorrect: false,
          textInputAction: TextInputAction.go,
          style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Enter chess.com username...',
            prefixIcon: const Icon(
              Icons.person_outline_rounded,
              color: AppColors.textSecondary,
            ),
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded,
                        color: AppColors.textSecondary),
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                  )
                : null,
            errorText: error,
            errorStyle: AppTextStyles.caption.copyWith(color: AppColors.error),
          ),
        ),
      ],
    );
  }
}

class _ShakeWidget extends StatefulWidget {
  const _ShakeWidget({super.key, required this.child});

  final Widget child;

  @override
  State<_ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<_ShakeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticIn),
    );
  }

  void shake() {
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final offset = _animation.value < 0.5
            ? _animation.value * 20
            : (1 - _animation.value) * 20;
        final shake = _controller.isAnimating
            ? (offset * (_animation.value > 0.25 ? -1 : 1))
            : 0.0;
        return Transform.translate(
          offset: Offset(shake, 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
