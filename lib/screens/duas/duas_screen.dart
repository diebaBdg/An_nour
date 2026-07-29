import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/extensions.dart';
import '../../core/widgets/loading_widgets.dart';
import '../../models/dua_model.dart';
import '../../providers/dua_provider.dart';

/// Liste des invocations par catégorie.
class DuasScreen extends ConsumerWidget {
  const DuasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          const SliverAppBar(
            floating: true,
            title: Text('Invocations'),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final category = DuaCategory.values[index];
                  return _CategoryTile(
                    category: category,
                    onTap: () => _openCategory(context, ref, category),
                  );
                },
                childCount: DuaCategory.values.length,
              ),
            ),
          ),
        ],
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
}

class _CategoryTile extends ConsumerWidget {
  const _CategoryTile({required this.category, required this.onTap});

  final DuaCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final duasAsync = ref.watch(duasByCategoryProvider(category));

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.emerald.withValues(alpha: 0.12),
          child: Icon(_iconFor(category), color: AppColors.emerald),
        ),
        title: Text(category.label),
        subtitle: duasAsync.when(
          data: (duas) => Text('${duas.length} invocation(s)'),
          loading: () => const Text('Chargement...'),
          error: (_, __) => const Text('Erreur'),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }

  IconData _iconFor(DuaCategory category) {
    return switch (category) {
      DuaCategory.morning => Icons.wb_sunny_outlined,
      DuaCategory.evening => Icons.nights_stay_outlined,
      DuaCategory.travel => Icons.flight_takeoff_rounded,
      DuaCategory.illness => Icons.healing_rounded,
      DuaCategory.food => Icons.restaurant_rounded,
      DuaCategory.sleep => Icons.bedtime_rounded,
      DuaCategory.mosque => Icons.mosque_rounded,
      DuaCategory.protection => Icons.shield_rounded,
      DuaCategory.forgiveness => Icons.favorite_rounded,
      DuaCategory.misc => Icons.more_horiz_rounded,
    };
  }
}

class _CategoryDuasSheet extends ConsumerWidget {
  const _CategoryDuasSheet({required this.category});

  final DuaCategory category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final duasAsync = ref.watch(duasByCategoryProvider(category));

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                category.label,
                style: context.textTheme.titleLarge,
              ),
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
