import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import 'tips_provider.dart';
import 'tip_model.dart';
import 'tip_tile.dart';

class TipsScreen extends ConsumerStatefulWidget {
  const TipsScreen({super.key});

  @override
  ConsumerState<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends ConsumerState<TipsScreen> {
  int? _expandedTipId;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tipsProvider);

    return DefaultTabController(
      length: TipCategory.values.length,
      child: Scaffold(
        backgroundColor: AppColors.backgroundDeep,
        appBar: AppBar(
          title: const Text('TIPS & TRICKS'),
          centerTitle: true,
          backgroundColor: AppColors.backgroundDeep,
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle:
                AppTextStyles.label.copyWith(fontWeight: FontWeight.bold),
            unselectedLabelStyle: AppTextStyles.label,
            tabs: TipCategory.values
                .map((c) => Tab(text: c.name.toUpperCase()))
                .toList(),
          ),
        ),
        body: state.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary))
            : state.errorMessage != null
                ? _ErrorView(message: state.errorMessage!)
                : TabBarView(
                    children: TipCategory.values.map((category) {
                      return _CategoryListView(
                        category: category,
                        expandedId: _expandedTipId,
                        onTipToggle: (id) {
                          setState(() {
                            _expandedTipId = (_expandedTipId == id) ? null : id;
                          });
                        },
                      );
                    }).toList(),
                  ),
      ),
    );
  }
}

class _CategoryListView extends ConsumerWidget {
  final TipCategory category;
  final int? expandedId;
  final ValueChanged<int> onTipToggle;

  const _CategoryListView({
    required this.category,
    required this.expandedId,
    required this.onTipToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tips = ref.watch(tipsByCategoryProvider(category));

    if (tips.isEmpty) {
      return const _EmptyView();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: tips.length,
      itemBuilder: (context, index) {
        final tip = tips[index];
        return TipTile(
          tip: tip,
          isExpanded: expandedId == tip.id,
          onToggle: () => onTipToggle(tip.id),
        );
      },
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.school_outlined, size: 64, color: Colors.white10),
          const SizedBox(height: 16),
          Text(
            "No tips available yet",
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends ConsumerWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.read(tipsProvider.notifier).reload(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text("RETRY"),
            ),
          ],
        ),
      ),
    );
  }
}
