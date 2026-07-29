import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/extensions.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/loading_widgets.dart';
import '../../models/divine_name_model.dart';
import '../../providers/divine_names_provider.dart';

/// Les 99 Noms d'Allah inspiré de l'application Al-Azkar.
class DivineNamesScreen extends ConsumerWidget {
  const DivineNamesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final namesAsync = ref.watch(filteredDivineNamesProvider);
    final query = ref.watch(divineNameSearchProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('99 Noms d\'Allah'),
              titlePadding: const EdgeInsets.only(left: 48, bottom: 14),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.emerald, AppColors.emeraldDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                onChanged: (v) =>
                    ref.read(divineNameSearchProvider.notifier).state = v,
                decoration: const InputDecoration(
                  hintText: 'Rechercher un nom...',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
            ),
          ),
          namesAsync.when(
            loading: () => const SliverFillRemaining(
              child: LoadingIndicator(message: 'Chargement des noms...'),
            ),
            error: (e, _) => SliverFillRemaining(
              child: ErrorStateWidget(
                message: e.toString(),
                onRetry: () => ref.invalidate(divineNamesProvider),
              ),
            ),
            data: (names) {
              if (names.isEmpty) {
                return SliverFillRemaining(
                  child: EmptyStateWidget(
                    icon: Icons.search_off_rounded,
                    title: query.isEmpty
                        ? 'Aucun nom trouvé'
                        : 'Aucun résultat pour "$query"',
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final name = names[index];
                      return _DivineNameTile(
                        name: name,
                        onTap: () => context.push('/divine-name/${name.number}', extra: name),
                      )
                          .animate()
                          .fadeIn(delay: (index * 30).ms, duration: 250.ms);
                    },
                    childCount: names.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DivineNameTile extends StatelessWidget {
  const _DivineNameTile({required this.name, this.onTap});

  final DivineName name;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                '${name.number}',
                style: context.textTheme.titleMedium?.copyWith(
                  color: AppColors.goldDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.transliteration,
                  style: context.textTheme.titleMedium,
                ),
                Text(
                  name.translation,
                  style: context.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            name.arabic,
            style: context.textTheme.displayLarge?.copyWith(
              fontSize: 22,
              color: AppColors.emerald,
            ),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }
}
