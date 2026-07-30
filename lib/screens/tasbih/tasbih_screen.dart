import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/extensions.dart';
import '../../core/widgets/arabic_text.dart';
import '../../models/tasbih_model.dart';
import '../../providers/favorites_provider.dart';

class TasbihScreen extends ConsumerWidget {
  const TasbihScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tasbihCountProvider);
    final notifier = ref.read(tasbihCountProvider.notifier);
    final progress = state.count / state.dhikr.defaultTarget;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasbih'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              notifier.reset();
              context.showSnack('Compteur réinitialisé');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: DhikrType.values.map((dhikr) {
                  final selected = state.dhikr == dhikr;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(dhikr.label),
                      selected: selected,
                      onSelected: (_) => notifier.setDhikr(dhikr),
                      selectedColor: AppColors.emerald.withValues(alpha: 0.2),
                      checkmarkColor: AppColors.emerald,
                    ),
                  );
                }).toList(),
              ),
            ),

            Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  notifier.increment();
                },
                behavior: HitTestBehavior.opaque,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ArabicText(
                        text: state.dhikr.arabic,
                        fontSize: 28,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.dhikr.label,
                        style: context.textTheme.titleMedium?.copyWith(
                          color: AppColors.emerald,
                        ),
                      ),
                      const SizedBox(height: 40),

                      SizedBox(
                        width: 220,
                        height: 220,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 220,
                              height: 220,
                              child: CircularProgressIndicator(
                                value: progress.clamp(0.0, 1.0),
                                strokeWidth: 8,
                                backgroundColor: AppColors.emerald
                                    .withValues(alpha: 0.1),
                                color: AppColors.emerald,
                              ),
                            ),
                            Text(
                              '${state.count}',
                              style: context.textTheme.displayLarge?.copyWith(
                                fontSize: 64,
                                fontWeight: FontWeight.bold,
                                color: AppColors.emerald,
                              ),
                            ).animate(key: ValueKey(state.count))
                                .scale(
                              begin: const Offset(1.2, 1.2),
                              duration: 150.ms,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),
                      Text(
                        'Objectif : ${state.dhikr.defaultTarget}',
                        style: context.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Appuyez n\'importe où pour compter',
                        style: context.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),


          ],
        ),
      ),
    );
  }
}