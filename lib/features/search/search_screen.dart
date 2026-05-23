import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/widgets/cht_button.dart';
import '../../core/services/storage_service.dart';
import '../../core/router/app_router.dart';
import '../../data/repositories/player_repository.dart';

class _SearchState {
  const _SearchState({
    this.isLoading = false,
    this.error,
    this.username = '',
  });

  final bool isLoading;
  final String? error;
  final String username;

  _SearchState copyWith({
    bool? isLoading,
    String? error,
    String? username,
  }) {
    return _SearchState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      username: username ?? this.username,
    );
  }
}

final _searchStateProvider =
    StateNotifierProvider.autoDispose<_SearchNotifier, _SearchState>((ref) {
  return _SearchNotifier(
    ref.read(playerRepositoryProvider),
    ref.read(storageServiceProvider),
    ref,
  );
});

class _SearchNotifier extends StateNotifier<_SearchState> {
  _SearchNotifier(this._repo, this._storage, this._ref)
      : super(const _SearchState());

  final PlayerRepository _repo;
  final StorageService _storage;
  final Ref _ref;

  void updateUsername(String value) {
    state = state.copyWith(
      username: value.trim(),
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

      _ref.read(connectedUsernameProvider.notifier).state = username;

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

  final List<String> _testUsernames = ['hikaru', 'shiliaiwei', 'GothamChess'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final username = ref.read(storageServiceProvider).connectedUsername;
      if (username != null && mounted) {
        _controller.text = username;
        ref.read(_searchStateProvider.notifier).updateUsername(username);
      }
    });
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
      context.go(AppRoutes.home);
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                children: [
                  // Brand Logo
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.divider, width: 1),
                    ),
                    child: ClipOval(
                      child: Image.asset('assets/brand/logo.png',
                          fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Text('Connect Your Account', style: AppTextStyles.headline),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Enter your Chess.com username',
                      style: AppTextStyles.bodyMuted),

                  const SizedBox(height: AppSpacing.xxl),

                  // Quick test users
                  Wrap(
                    spacing: 8,
                    alignment: WrapAlignment.center,
                    children: _testUsernames
                        .map((u) => ActionChip(
                              label:
                                  Text(u, style: const TextStyle(fontSize: 12)),
                              onPressed: () {
                                _controller.text = u;
                                ref
                                    .read(_searchStateProvider.notifier)
                                    .updateUsername(u);
                                _connect();
                              },
                              backgroundColor:
                                  AppColors.primary.withValues(alpha: 0.1),
                              side: const BorderSide(color: AppColors.primary),
                            ))
                        .toList(),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Username Field
                  _ShakeWidget(
                    key: _shakeKey,
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      onChanged: (v) => ref
                          .read(_searchStateProvider.notifier)
                          .updateUsername(v),
                      onSubmitted: (_) => _connect(),
                      style: AppTextStyles.body,
                      decoration: InputDecoration(
                        hintText: 'Enter username...',
                        errorText: state.error,
                        prefixIcon:
                            const Icon(Icons.person_outline_rounded, size: 20),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  ChtButton(
                    label: 'Connect',
                    onPressed: state.isLoading ? null : _connect,
                    isLoading: state.isLoading,
                    icon: Icons.link_rounded,
                  ),

                  if (recentUsernames.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xl),
                    const Divider(),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: 8,
                      children: recentUsernames
                          .map((u) => ActionChip(
                                label: Text(u,
                                    style: AppTextStyles.caption.copyWith(
                                        color: AppColors.textPrimary)),
                                backgroundColor: AppColors.backgroundSurface,
                                side:
                                    const BorderSide(color: AppColors.divider),
                                onPressed: () {
                                  _controller.text = u;
                                  ref
                                      .read(_searchStateProvider.notifier)
                                      .updateUsername(u);
                                },
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
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
        vsync: this, duration: const Duration(milliseconds: 400));
    _animation = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.elasticIn));
  }

  void shake() => _controller.forward(from: 0);

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
        return Transform.translate(offset: Offset(shake, 0), child: child);
      },
      child: widget.child,
    );
  }
}
