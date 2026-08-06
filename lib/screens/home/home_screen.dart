import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/extensions.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/arabic_text.dart';
import '../../core/widgets/loading_widgets.dart';
import '../../core/widgets/quick_action_button.dart';
import '../../providers/dua_provider.dart';
import '../../providers/prayer_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quoteAsync = ref.watch(dailyQuoteProvider);
    final prayerAsync = ref.watch(prayerTimesProvider);
    final countdownState = ref.watch(prayerCountdownTimerProvider);
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Assalamu Alaykum',
                    style: context.textTheme.headlineMedium,
                  ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
                  const SizedBox(height: 4),
                  Text(
                    AppConstants.appTagline,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: AppColors.emerald,
                    ),
                  ).animate().fadeIn(delay: 100.ms),
                ],
              ),
            ),
          ),

          // Carte prochaine priere
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: prayerAsync.when(
                loading: () => const GradientCard(
                  child: SizedBox(
                    height: 120,
                    child: LoadingIndicator(),
                  ),
                ),
                error: (e, _) => GradientCard(
                  child: Text('Erreur: $e'),
                ),
                data: (times) {
                  final next = times.nextPrayer;

                  return GradientCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.mosque_rounded,
                                color: AppColors.gold, size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Prochaine priere',
                                    style: context.textTheme.bodyMedium
                                        ?.copyWith(color: Colors.white70),
                                  ),
                                  Text(
                                    next?.name ?? 'Fajr',
                                    style: context.textTheme.headlineMedium
                                        ?.copyWith(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                            if (next != null)
                              Text(
                                next.formattedTime,
                                style: context.textTheme.headlineLarge
                                    ?.copyWith(
                                  color: AppColors.gold,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
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
                        if (times.city != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            times.city!,
                            style: context.textTheme.bodySmall
                                ?.copyWith(color: Colors.white60),
                          ),
                        ],
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms).scale(
                    begin: const Offset(0.95, 0.95),
                  );
                },
              ),
            ),
          ),

          // Citation du jour
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: quoteAsync.when(
                loading: () => const AppCard(
                  child: SizedBox(height: 100, child: LoadingIndicator()),
                ),
                error: (_, __) => const SizedBox.shrink(),
                data: (quote) => AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            quote.type.name == 'quran'
                                ? Icons.menu_book_rounded
                                : Icons.format_quote_rounded,
                            color: AppColors.emerald,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            quote.type.name == 'quran' ? 'Coran' : 'Hadith',
                            style: context.textTheme.titleMedium?.copyWith(
                              color: AppColors.emerald,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (quote.arabic != null) ...[
                        ArabicText(
                          text: quote.arabic!,
                          fontSize: 20,
                        ),
                        const SizedBox(height: 12),
                      ],
                      Text(
                        quote.text,
                        style: context.textTheme.bodyLarge?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ReferenceBadge(reference: quote.reference),
                    ],
                  ),
                ).animate().fadeIn(delay: 300.ms),
              ),
            ),
          ),

          // Acces rapide
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Acces rapide', style: context.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 4,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.85,
                    children: [
                      QuickActionButton(
                        icon: Icons.explore_rounded,
                        label: 'Qibla',
                        onTap: () => context.push('/qibla'),
                      ),
                      QuickActionButton(
                        icon: Icons.touch_app_rounded,
                        label: 'Tasbih',
                        onTap: () => context.push('/tasbih'),
                      ),
                      QuickActionButton(
                        icon: Icons.calendar_month_rounded,
                        label: 'Calendrier',
                        onTap: () => context.push('/calendar'),
                      ),
                      QuickActionButton(
                        icon: Icons.auto_stories_rounded,
                        label: 'Hadiths',
                        onTap: () => context.push('/hadiths'),
                      ),
                      QuickActionButton(
                        icon: Icons.history_edu_rounded,
                        label: 'Seerah',
                        onTap: () => context.push('/seerah'),
                      ),
                      QuickActionButton(
                        icon: Icons.fingerprint_rounded,
                        label: '99 Noms',
                        onTap: () => context.push('/divine-names'),
                      ),
                      QuickActionButton(
                        icon: Icons.auto_awesome_rounded,
                        label: 'Assistant IA',
                        onTap: () => context.push('/ai-chat'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Horaires du jour (apercu)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: prayerAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (times) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Horaires du jour',
                      style: context.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    ...times.obligatory.map(
                          (p) => AppCard(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Text(
                              p.arabicName,
                              style: context.textTheme.titleMedium,
                            ),
                            const Spacer(),
                            Text(
                              p.name,
                              style: context.textTheme.bodyMedium,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              p.formattedTime,
                              style: context.textTheme.titleMedium?.copyWith(
                                color: AppColors.emerald,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}