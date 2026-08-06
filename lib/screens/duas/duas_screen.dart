import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/extensions.dart';
import '../../core/widgets/loading_widgets.dart';
import '../../models/dua_model.dart';
import '../../providers/dua_provider.dart';

/// Liste des invocations par catégorie (Hisn al-Muslim complet).
class DuasScreen extends ConsumerWidget {
  const DuasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(duaCategoriesProvider);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          const SliverAppBar(
            floating: true,
            title: Text('Invocations'),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: categoriesAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: SizedBox(
                  height: 300,
                  child: LoadingIndicator(message: 'Chargement des invocations...'),
                ),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: ErrorStateWidget(
                  message: e.toString(),
                  onRetry: () => ref.invalidate(duaCategoriesProvider),
                ),
              ),
              data: (categories) => SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final category = categories[index];
                    return _CategoryTile(category: category);
                  },
                  childCount: categories.length,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends ConsumerWidget {
  const _CategoryTile({required this.category});

  final DuaCategory category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final duasAsync =
        ref.watch(duasByApiCategoryProvider(category.id));

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.emerald.withValues(alpha: 0.12),
          child: Icon(_iconForName(category.name), color: AppColors.emerald),
        ),
        title: Text(category.name),
        subtitle: duasAsync.when(
          data: (duas) => Text('${duas.length} invocation(s)'),
          loading: () => const Text('Chargement...'),
          error: (_, __) => const Text('Erreur'),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => _openCategory(context, ref, category),
      ),
    );
  }

  void _openCategory(
    BuildContext context,
    WidgetRef ref,
    DuaCategory category,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _CategoryDuasSheet(category: category),
    );
  }

  IconData _iconForName(String name) {
    final n = name.toLowerCase();
    if (n.contains('morning') || n.contains('matin')) return Icons.wb_sunny_outlined;
    if (n.contains('evening') || n.contains('soir')) return Icons.nights_stay_outlined;
    if (n.contains('travel') || n.contains('voyage')) return Icons.flight_takeoff_rounded;
    if (n.contains('illness') || n.contains('maladie')) return Icons.healing_rounded;
    if (n.contains('food') || n.contains('repas')) return Icons.restaurant_rounded;
    if (n.contains('sleep') || n.contains('sommeil')) return Icons.bedtime_rounded;
    if (n.contains('mosque') || n.contains('mosquée')) return Icons.mosque_rounded;
    if (n.contains('protection')) return Icons.shield_rounded;
    if (n.contains('forgiveness') || n.contains('pardon')) return Icons.favorite_rounded;
    if (n.contains('prayer') || n.contains('prière')) return Icons.access_time_rounded;
    if (n.contains('anxiety') || n.contains('angoisse')) return Icons.psychology_outlined;
    if (n.contains('death') || n.contains('mort')) return Icons.hourglass_empty_rounded;
    if (n.contains('rain') || n.contains('pluie')) return Icons.water_drop_outlined;
    if (n.contains('fasting') || n.contains('jeûne')) return Icons.no_food_outlined;
    return Icons.auto_awesome_outlined;
  }
}

class _CategoryDuasSheet extends ConsumerWidget {
  const _CategoryDuasSheet({required this.category});

  final DuaCategory category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final duasAsync = ref.watch(duasByApiCategoryProvider(category.id));

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(category.name, style: context.textTheme.titleLarge),
            ),
            Expanded(
              child: duasAsync.when(
                loading: () => const LoadingIndicator(),
                error: (e, _) => ErrorStateWidget(message: e.toString()),
                data: (duas) => ListView.builder(
                  controller: scrollController,
                  itemCount: duas.length,
                  itemBuilder: (context, index) {
                    final dua = duas[index];
                    return ListTile(
                      title: Text(
                        dua.translation,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(dua.reference),
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/dua/${dua.id}', extra: dua);
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
