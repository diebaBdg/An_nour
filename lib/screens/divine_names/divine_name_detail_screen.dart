import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/extensions.dart';
import '../../core/widgets/arabic_text.dart';
import '../../models/divine_name_model.dart';

/// Détail d'un des 99 Noms d'Allah avec sa signification complète.
class DivineNameDetailScreen extends ConsumerWidget {
  const DivineNameDetailScreen({super.key, required this.name});

  final DivineName name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name.transliteration),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_rounded),
            onPressed: () {
              final text =
                  '${name.number}. ${name.transliteration}\n${name.arabic}\n\n${name.translation}\n\n${name.meaning}';
              Clipboard.setData(ClipboardData(text: text));
              context.showSnack('Nom copié');
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () {
              Share.share(
                '${name.transliteration} (${name.arabic})\n${name.translation}\n\n${name.meaning}',
                subject: '99 Noms d\'Allah - An-Nour',
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${name.number}',
                    style: context.textTheme.headlineLarge?.copyWith(
                      color: AppColors.goldDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ArabicText(
              text: name.arabic,
              fontSize: 40,
              textAlign: TextAlign.center,
              color: AppColors.emerald,
            ),
            const SizedBox(height: 12),
            Text(
              name.transliteration,
              style: context.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              name.translation,
              style: context.textTheme.titleMedium?.copyWith(
                color: AppColors.emerald,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Signification',
              style: context.textTheme.titleMedium?.copyWith(
                color: AppColors.goldDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name.meaning,
              style: context.textTheme.bodyLarge?.copyWith(height: 1.7),
            ),
          ],
        ),
      ),
    );
  }
}
