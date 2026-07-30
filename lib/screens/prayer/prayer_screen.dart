import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/extensions.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/loading_widgets.dart';
import '../../models/prayer_model.dart';
import '../../providers/prayer_provider.dart';
import '../../providers/settings_provider.dart';

class PrayerScreen extends ConsumerWidget {
  const PrayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayerAsync = ref.watch(prayerTimesProvider);
    final countdownState = ref.watch(prayerCountdownTimerProvider);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.emerald,
          onRefresh: () async {
            ref.invalidate(prayerTimesProvider);
            await ref.read(prayerTimesProvider.future);
          },
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                title: const Text('Horaires de prière'),
                backgroundColor: AppColors.emerald,
                foregroundColor: Colors.white,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.tune_rounded),
                    onPressed: () => _showMethodPicker(context, ref, settings.prayerMethod),
                  ),
                ],
              ),
              prayerAsync.when(
                loading: () => const SliverFillRemaining(
                  child: LoadingIndicator(message: 'Calcul des horaires...'),
                ),
                error: (e, _) => SliverFillRemaining(
                  child: ErrorStateWidget(
                    message: e.toString(),
                    onRetry: () => ref.invalidate(prayerTimesProvider),
                  ),
                ),
                data: (times) {
                  final next = times.nextPrayer;

                  return SliverList(
                    delegate: SliverChildListDelegate([
                      // Carte principale
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: GradientCard(
                          child: Column(
                            children: [
                              if (times.city != null && times.city!.isNotEmpty)
                                Text(
                                  times.city!,
                                  style: context.textTheme.bodyMedium
                                      ?.copyWith(color: Colors.white70),
                                ),
                              const SizedBox(height: 8),
                              Text(
                                next?.arabicName ?? 'الفجر',
                                style: context.textTheme.displayLarge?.copyWith(
                                  color: Colors.white,
                                  fontSize: 36,
                                ),
                              ),
                              Text(
                                next?.name ?? 'Fajr',
                                style: context.textTheme.titleLarge?.copyWith(
                                  color: AppColors.gold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              countdownState.when(
                                loading: () => const SizedBox.shrink(),
                                error: (err, stack) => const SizedBox.shrink(),
                                data: (countdown) => Column(
                                  children: [
                                    const SizedBox(height: 16),
                                    Text(
                                      'Dans ${formatCountdown(countdown)}',
                                      style: context.textTheme.titleMedium?.copyWith(
                                        color: Colors.white.withValues(alpha: 0.9),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Liste des prières avec un padding
                      ...times.all.map((prayer) {
                        final isNext = prayer.name == next?.name;
                        final isPassed = prayer.isPassed;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: AppCard(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isNext
                                        ? AppColors.emerald
                                        : isPassed
                                        ? AppColors.textSecondary
                                        .withValues(alpha: 0.3)
                                        : AppColors.gold,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        prayer.name,
                                        style: context.textTheme.titleMedium
                                            ?.copyWith(
                                          fontWeight: isNext
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                      Text(
                                        prayer.arabicName,
                                        style: context.textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  prayer.formattedTime,
                                  style: context.textTheme.titleLarge?.copyWith(
                                    color: isNext ? AppColors.emerald : null,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 80), // Espace pour le bottom sheet
                    ]),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMethodPicker(
      BuildContext context,
      WidgetRef ref,
      CalculationMethodType current,
      ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.8,
          minChildSize: 0.3,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Méthode de calcul',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: CalculationMethodType.values.map(
                          (method) => RadioListTile<CalculationMethodType>(
                        title: Text(
                          method.label,
                          style: const TextStyle(fontSize: 14),
                        ),
                        value: method,
                        groupValue: current,
                        activeColor: AppColors.emerald,
                        onChanged: (value) {
                          if (value != null) {
                            ref.read(settingsProvider.notifier).setPrayerMethod(value);
                            ref.invalidate(prayerTimesProvider);
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ).toList(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

String formatCountdown(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);

  if (hours > 0) {
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}