import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/extensions.dart';
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
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0D1B1A) : const Color(0xFFF0F7F4),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.emerald,
          onRefresh: () async {
            ref.invalidate(prayerTimesProvider);
            await ref.read(prayerTimesProvider.future);
          },
          child: prayerAsync.when(
            loading: () => const Center(
              child: LoadingIndicator(message: 'Calcul des horaires...'),
            ),
            error: (e, _) => Center(
              child: ErrorStateWidget(
                message: e.toString(),
                onRetry: () => ref.invalidate(prayerTimesProvider),
              ),
            ),
            data: (times) {
              final next = times.nextPrayer;
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _Header(
                      times: times,
                      next: next,
                      countdown: countdownState,
                      method: settings.prayerMethod,
                      onMethodTap: () =>
                          _showMethodPicker(context, ref, settings.prayerMethod),
                      onLocationTap: () => context.push('/prayer/location'),
                    ),
                  ),
                  SliverPadding(
                    padding:
                        const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final prayer = times.all[index];
                          final isNext = prayer.name == next?.name;
                          final isPassed = prayer.isPassed;
                          return _PrayerTile(
                            prayer: prayer,
                            isNext: isNext,
                            isPassed: isPassed,
                          )
                              .animate()
                              .fadeIn(
                                delay: (index * 60).ms,
                                duration: 300.ms,
                              )
                              .slideX(begin: 0.05);
                        },
                        childCount: times.all.length,
                      ),
                    ),
                  ),
                ],
              );
            },
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
      backgroundColor: Colors.transparent,
      builder: (context) => _MethodSheet(current: current, ref: ref),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Header inspiré de Muslim Pro
// ──────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  const _Header({
    required this.times,
    required this.next,
    required this.countdown,
    required this.method,
    required this.onMethodTap,
    required this.onLocationTap,
  });

  final DailyPrayerTimes times;
  final PrayerTime? next;
  final AsyncValue<Duration> countdown;
  final CalculationMethodType method;
  final VoidCallback onMethodTap;
  final VoidCallback onLocationTap;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF0D2B25), const Color(0xFF0A3D2E)]
              : [AppColors.emeraldDark, AppColors.emerald],
        ),
      ),
      child: Column(
        children: [
          // Barre localisation + méthode
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                // Chip localisation
                Expanded(
                  child: GestureDetector(
                    onTap: onLocationTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🇸🇳', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              times.city ?? 'Dakar, Sénégal',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.expand_more,
                              color: Colors.white70, size: 16),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Chip méthode
                GestureDetector(
                  onTap: onMethodTap,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _shortMethod(method),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.settings,
                            color: Colors.white70, size: 14),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Prochaine prière + compte à rebours
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              children: [
                Text(
                  next?.arabicName ?? 'الفجر',
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 36,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  next?.name ?? 'Fajr',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                countdown.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (d) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer_outlined,
                            color: Colors.white70, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'dans ${_formatCountdown(d)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _shortMethod(CalculationMethodType m) {
    return switch (m) {
      CalculationMethodType.muslimWorldLeague => 'MWL',
      CalculationMethodType.egyptian => 'Egyptian',
      CalculationMethodType.karachi => 'Karachi',
      CalculationMethodType.ummAlQura => 'Umm Al-Qura',
      CalculationMethodType.dubai => 'Dubai',
      CalculationMethodType.northAmerica => 'ISNA',
      CalculationMethodType.kuwait => 'Kuwait',
      CalculationMethodType.qatar => 'Qatar',
      CalculationMethodType.singapore => 'Singapore',
      CalculationMethodType.tehran => 'Tehran',
      CalculationMethodType.turkey => 'Turkey',
      CalculationMethodType.moonsightingCommittee => 'Moon',
    };
  }

  String _formatCountdown(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    if (h > 0) {
      return '${h}h ${m.toString().padLeft(2, '0')}m';
    }
    return '${m}m ${s.toString().padLeft(2, '0')}s';
  }
}

// ──────────────────────────────────────────────────────────────
// Tuile de prière
// ──────────────────────────────────────────────────────────────
class _PrayerTile extends StatelessWidget {
  const _PrayerTile({
    required this.prayer,
    required this.isNext,
    required this.isPassed,
  });

  final PrayerTime prayer;
  final bool isNext;
  final bool isPassed;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final isSunrise = prayer.name == 'Sunrise';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isNext
            ? AppColors.emerald.withValues(alpha: 0.12)
            : isDark
                ? const Color(0xFF1A2E28)
                : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: isNext
            ? Border.all(color: AppColors.emerald.withValues(alpha: 0.5))
            : Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.05),
              ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Indicateur radio circulaire (comme Muslim Pro)
            if (!isSunrise)
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isNext
                        ? AppColors.emerald
                        : isPassed
                            ? AppColors.emerald
                            : Colors.grey.withValues(alpha: 0.4),
                    width: 2,
                  ),
                  color: isPassed ? AppColors.emerald : Colors.transparent,
                ),
                child: isPassed
                    ? const Icon(Icons.check, color: Colors.white, size: 12)
                    : null,
              )
            else
              const SizedBox(width: 22),

            const SizedBox(width: 14),

            // Nom de la prière
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prayer.name,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight:
                          isNext ? FontWeight.w700 : FontWeight.w500,
                      color: isSunrise
                          ? context.textTheme.bodySmall?.color
                          : null,
                    ),
                  ),
                  Text(
                    prayer.arabicName,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 14,
                      color: isNext
                          ? AppColors.emerald
                          : context.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),

            // Badge "prochain"
            if (isNext)
              Container(
                margin: const EdgeInsets.only(right: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.emerald.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'prochain',
                  style: TextStyle(
                    color: AppColors.emerald,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

            // Heure
            Text(
              prayer.formattedTime,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isNext
                    ? AppColors.emerald
                    : isSunrise
                        ? context.textTheme.bodySmall?.color
                        : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Bottom sheet méthode de calcul
// ──────────────────────────────────────────────────────────────
class _MethodSheet extends StatelessWidget {
  const _MethodSheet({required this.current, required this.ref});

  final CalculationMethodType current;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.isDarkMode
            ? const Color(0xFF1A2E28)
            : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Méthode de calcul',
              style: context.textTheme.titleLarge,
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: CalculationMethodType.values.map((method) {
                final isSelected = method == current;
                return ListTile(
                  title: Text(method.label,
                      style: const TextStyle(fontSize: 14)),
                  trailing: isSelected
                      ? Icon(Icons.check_circle,
                          color: AppColors.emerald)
                      : null,
                  tileColor: isSelected
                      ? AppColors.emerald.withValues(alpha: 0.08)
                      : null,
                  onTap: () {
                    ref
                        .read(settingsProvider.notifier)
                        .setPrayerMethod(method);
                    ref.invalidate(prayerTimesProvider);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

String formatCountdown(Duration duration) {
  final h = duration.inHours;
  final m = duration.inMinutes % 60;
  final s = duration.inSeconds % 60;
  if (h > 0) {
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}
