import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/extensions.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/loading_widgets.dart';
import '../../models/seerah_model.dart';
import '../../providers/seerah_provider.dart';

/// Chronologie de la vie du Prophète ﷺ inspirée des applications Al-Azkar et Muslim Pro.
class SeerahScreen extends ConsumerWidget {
  const SeerahScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(filteredSeerahProvider);
    final eraFilter = ref.watch(seerahEraFilterProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: false,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Biographie du Prophète ﷺ'),
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
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: _EraFilterBar(
                selected: eraFilter,
                onSelect: (era) =>
                    ref.read(seerahEraFilterProvider.notifier).state = era,
              ),
            ),
          ),
          eventsAsync.when(
            loading: () => const SliverFillRemaining(
              child: LoadingIndicator(message: 'Chargement de la chronologie...'),
            ),
            error: (e, _) => SliverFillRemaining(
              child: ErrorStateWidget(
                message: e.toString(),
                onRetry: () => ref.invalidate(seerahEventsProvider),
              ),
            ),
            data: (events) {
              if (events.isEmpty) {
                return const SliverFillRemaining(
                  child: EmptyStateWidget(
                    icon: Icons.history_edu_rounded,
                    title: 'Aucun événement trouvé',
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final event = events[index];
                    final isLast = index == events.length - 1;
                    return _SeerahTimelineTile(
                      event: event,
                      isLast: isLast,
                      onTap: () => context.push('/seerah/${event.id}', extra: event),
                    ).animate().fadeIn(
                      delay: (index * 60).ms,
                      duration: 300.ms,
                    );
                  },
                  childCount: events.length,
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _EraFilterBar extends StatelessWidget {
  const _EraFilterBar({required this.selected, required this.onSelect});

  final SeerahEra? selected;
  final void Function(SeerahEra?) onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          FilterChip(
            label: const Text('Toutes'),
            selected: selected == null,
            onSelected: (_) => onSelect(null),
            selectedColor: AppColors.emerald.withValues(alpha: 0.2),
            checkmarkColor: AppColors.emerald,
          ),
          ...SeerahEra.values.map(
            (era) => Padding(
              padding: const EdgeInsets.only(left: 8),
              child: FilterChip(
                label: Text(era.label),
                selected: selected == era,
                onSelected: (_) => onSelect(era),
                selectedColor: AppColors.emerald.withValues(alpha: 0.2),
                checkmarkColor: AppColors.emerald,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SeerahTimelineTile extends StatelessWidget {
  const _SeerahTimelineTile({
    required this.event,
    required this.isLast,
    required this.onTap,
  });

  final SeerahEvent event;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 56,
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.emerald.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.emerald.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      _iconFor(event.icon),
                      color: AppColors.emerald,
                      size: 22,
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: AppColors.emerald.withValues(alpha: 0.2),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AppCard(
                margin: const EdgeInsets.only(bottom: 12),
                onTap: onTap,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${event.year}',
                            style: context.textTheme.labelLarge?.copyWith(
                              color: AppColors.goldDark,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (event.location.isNotEmpty)
                          Flexible(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.place_rounded,
                                  size: 14,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 2),
                                Flexible(
                                  child: Text(
                                    event.location,
                                    style: context.textTheme.bodySmall,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event.title,
                      style: context.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event.summary,
                      style: context.textTheme.bodyMedium,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      event.arabic,
                      style: context.textTheme.displayLarge?.copyWith(
                        fontSize: 18,
                        color: AppColors.emerald,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String name) {
    return switch (name) {
      'child_care' => Icons.child_care_rounded,
      'family_restroom' => Icons.family_restroom_rounded,
      'shield' => Icons.shield_rounded,
      'favorite' => Icons.favorite_rounded,
      'auto_awesome' => Icons.auto_awesome_rounded,
      'campaign' => Icons.campaign_rounded,
      'flight_takeoff' => Icons.flight_takeoff_rounded,
      'sentiment_very_dissatisfied' => Icons.sentiment_very_dissatisfied_rounded,
      'nightlight_round' => Icons.nightlight_round_rounded,
      'handshake' => Icons.handshake_rounded,
      'directions_walk' => Icons.directions_walk_rounded,
      'mosque' => Icons.mosque_rounded,
      'military_tech' => Icons.military_tech_rounded,
      'terrain' => Icons.terrain_rounded,
      'engineering' => Icons.engineering_rounded,
      'history_edu' => Icons.history_edu_rounded,
      'location_city' => Icons.location_city_rounded,
      'groups' => Icons.groups_rounded,
      'sentiment_dissatisfied' => Icons.sentiment_dissatisfied_rounded,
      _ => Icons.history_rounded,
    };
  }
}
