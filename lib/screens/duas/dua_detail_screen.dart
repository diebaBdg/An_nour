import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/extensions.dart';
import '../../core/widgets/arabic_text.dart';
import '../../models/dua_model.dart';
import '../../models/favorite_model.dart';
import '../../providers/favorites_provider.dart';

/// Détail d'une invocation avec actions favori, copier et partager.
class DuaDetailScreen extends ConsumerWidget {
  const DuaDetailScreen({super.key, required this.dua});

  final Dua dua;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider.notifier);
    final isFavorite = favorites.isFavorite(dua.id, FavoriteType.dua);

    return Scaffold(
      appBar: AppBar(
        title: Text(dua.category),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite_rounded : Icons.favorite_outline,
              color: isFavorite ? AppColors.gold : null,
            ),
            onPressed: () {
              favorites.toggle(FavoriteItem(
                id: dua.id,
                type: FavoriteType.dua,
                title: dua.translation,
                subtitle: dua.reference,
                data: dua.toJson(),
              ));
            },
          ),
          IconButton(
            icon: const Icon(Icons.copy_rounded),
            onPressed: () {
              final text =
                  '${dua.arabic}\n\n${dua.transliteration}\n\n${dua.translation}\n\n— ${dua.reference}';
              Clipboard.setData(ClipboardData(text: text));
              context.showSnack('Invocation copiée');
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () {
              Share.share(
                '${dua.arabic}\n\n${dua.translation}\n\n— ${dua.reference}',
                subject: 'Invocation - An-Nour',
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
            ArabicText(text: dua.arabic, fontSize: 28),
            const SizedBox(height: 20),
            Text(
              dua.transliteration,
              style: context.textTheme.bodyLarge?.copyWith(
                fontStyle: FontStyle.italic,
                color: AppColors.emerald,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              dua.translation,
              style: context.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            ReferenceBadge(reference: dua.reference),
          ],
        ),
      ),
    );
  }
}
