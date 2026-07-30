import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/extensions.dart';
import '../../core/widgets/arabic_text.dart';
import '../../models/seerah_model.dart';

class SeerahDetailScreen extends ConsumerWidget {
  const SeerahDetailScreen({super.key, required this.event});

  final SeerahEvent event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                event.title,
                style: const TextStyle(fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.emerald, AppColors.emeraldDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),
                      ArabicText(
                        text: event.arabic,
                        fontSize: 28,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.copy_rounded),
                onPressed: () {
                  final text =
                      '${event.title}\n${event.arabic}\n\n${event.summary}\n\n${event.description}\n\nLieu: ${event.location} (${event.year})';
                  Clipboard.setData(ClipboardData(text: text));
                  context.showSnack('Événement copié');
                },
              ),
              IconButton(
                icon: const Icon(Icons.share_rounded),
                onPressed: () {
                  Share.share(
                    '${event.title} (${event.year})\n\n${event.summary}\n\n${event.description}',
                    subject: 'Biographie du Prophète ﷺ - An-Nour',
                  );
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.gold.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          '${event.year}',
                          style: context.textTheme.titleMedium?.copyWith(
                            color: AppColors.goldDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (event.location.isNotEmpty)
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(
                                Icons.place_rounded,
                                size: 18,
                                color: AppColors.emerald,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  event.location,
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.emerald,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    event.summary,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: AppColors.emerald,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    event.description,
                    style: context.textTheme.bodyLarge?.copyWith(
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ReferenceBadge(
                    reference:
                        _eraLabel(event.era),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _eraLabel(String era) {
    return switch (era) {
      'pre-prophethood' => 'Avant la prophétie',
      'meccan' => 'Période mecquoise',
      'medinan' => 'Période médinoise',
      _ => era,
    };
  }
}
