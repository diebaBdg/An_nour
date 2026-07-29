import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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

    return SafeArea(
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
              title: const Text('Horaires de priere'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.tune_rounded),
                  onPressed: () => _showMethodPicker(context, ref, settings.prayerMethod),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: prayerAsync.when(
                loading: () => const SizedBox(
                  height: 300,
                  child: LoadingIndicator(message: 'Calcul des horaires...'),
                ),
                error: (e, _) => ErrorStateWidget(
                  message: e.toString(),
                  onRetry: () => ref.invalidate(prayerTimesProvider),
                ),
                data: (times) {
                  final next = times.nextPrayer;

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: GradientCard(
                          child: Column(
                            children: [
                              if (times.city != null)
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: times.all.map((prayer) {
                            final isNext = prayer.name == next?.name;
                            final isPassed = prayer.isPassed;

                            return AppCard(
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
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
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
                                      color: isNext
                                          ? AppColors.emerald
                                          : null,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(
                              delay: (times.all.indexOf(prayer) * 50).ms,
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  );
                },
              ),
            ),
          ],
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
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Methode de calcul',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ...CalculationMethodType.values.map(
                  (method) => RadioListTile<CalculationMethodType>(
                title: Text(method.label, style: const TextStyle(fontSize: 14)),
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
            ),
          ],
        ),
      ),
    );
  }
}