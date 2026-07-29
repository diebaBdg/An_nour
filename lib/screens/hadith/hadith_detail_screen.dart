import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/extensions.dart';
import '../../core/widgets/arabic_text.dart';
import '../../models/favorite_model.dart';
import '../../models/hadith_model.dart';
import '../../providers/favorites_provider.dart';

class HadithDetailScreen extends ConsumerWidget {
  const HadithDetailScreen({super.key, required this.hadith});

  final Hadith hadith;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider.notifier);
    final isFavorite = favorites.isFavorite(hadith.id, FavoriteType.hadith);

    return Scaffold(
      appBar: AppBar(
        title: Text(hadith.theme),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite_rounded : Icons.favorite_outline,
              color: isFavorite ? AppColors.gold : null,
            ),
            onPressed: () {
              favorites.toggle(FavoriteItem(
                id: hadith.id,
                type: FavoriteType.hadith,
                title: hadith.english,
                subtitle: hadith.reference,
              ));
            },
          ),
          IconButton(
            icon: const Icon(Icons.copy_rounded),
            onPressed: () {
              final text =
                  '${hadith.arabic}\n\n${hadith.english}\n\n— ${hadith.reference}';
              Clipboard.setData(ClipboardData(text: text));
              context.showSnack('Hadith copié');
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () {
              Share.share(
                '${hadith.english}\n\n— ${hadith.reference}',
                subject: 'Hadith - An-Nour',
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (hadith.arabic.isNotEmpty) ...[
              ArabicText(text: hadith.arabic, fontSize: 24),
              const SizedBox(height: 20),
            ],
            Text(hadith.english, style: context.textTheme.bodyLarge),
            const SizedBox(height: 16),
            Text(
              'Narrateur : ${hadith.narrator}',
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.emerald,
              ),
            ),
            const SizedBox(height: 8),
            ReferenceBadge(reference: hadith.reference),
          ],
        ),
      ),
    );
  }
}
