import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/extensions.dart';
import '../../core/widgets/loading_widgets.dart';
import '../../models/hadith_model.dart';
import '../../providers/dua_provider.dart';

/// Écran principal des hadiths: sélection de collection (Bukhari/Muslim),
/// puis liste des livres (chapitres), puis hadiths du livre.
class HadithScreen extends ConsumerStatefulWidget {
  const HadithScreen({super.key});

  @override
  ConsumerState<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends ConsumerState<HadithScreen> {
  String? _selectedCollection;
  int? _selectedBook;

  @override
  Widget build(BuildContext context) {
    final collections = ref.watch(hadithCollectionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Hadiths')),
      body: Column(
        children: [
          // Collection selector tabs
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: collections.map((c) {
                final selected = _selectedCollection == c.id;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(c.name),
                      selected: selected,
                      onSelected: (_) => setState(() {
                        _selectedCollection = c.id;
                        _selectedBook = null;
                      }),
                      selectedColor: AppColors.emerald.withValues(alpha: 0.2),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_selectedCollection == null) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_stories_outlined, size: 72, color: AppColors.emerald),
            SizedBox(height: 16),
            Text('Choisissez une collection de hadiths'),
          ],
        ),
      );
    }

    if (_selectedBook == null) {
      return _BooksList(
        collection: _selectedCollection!,
        onBookSelected: (book) => setState(() => _selectedBook = book),
      );
    }

    return _HadithsList(
      collection: _selectedCollection!,
      bookNumber: _selectedBook!,
      onBack: () => setState(() => _selectedBook = null),
    );
  }
}

class _BooksList extends ConsumerWidget {
  const _BooksList({required this.collection, required this.onBookSelected});

  final String collection;
  final void Function(int) onBookSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(hadithBooksProvider(collection));

    return booksAsync.when(
      loading: () => const LoadingIndicator(message: 'Chargement des chapitres...'),
      error: (e, _) => ErrorStateWidget(
        message: e.toString(),
        onRetry: () => ref.invalidate(hadithBooksProvider(collection)),
      ),
      data: (books) {
        if (books.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.auto_stories_outlined,
            title: 'Aucun chapitre trouvé',
          );
        }
        return ListView.builder(
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.emerald.withValues(alpha: 0.12),
                child: Text(
                  '${book.number}',
                  style: const TextStyle(
                    color: AppColors.emerald,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(book.name, maxLines: 2, overflow: TextOverflow.ellipsis),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => onBookSelected(book.number),
            );
          },
        );
      },
    );
  }
}

class _HadithsList extends ConsumerWidget {
  const _HadithsList({
    required this.collection,
    required this.bookNumber,
    required this.onBack,
  });

  final String collection;
  final int bookNumber;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hadithsAsync = ref.watch(
        hadithsByBookProvider((collection: collection, bookNumber: bookNumber)));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: onBack,
              ),
              Expanded(
                child: Text(
                  'Chapitre $bookNumber',
                  style: context.textTheme.titleMedium,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: hadithsAsync.when(
            loading: () => const LoadingIndicator(message: 'Chargement des hadiths...'),
            error: (e, _) => ErrorStateWidget(
              message: e.toString(),
              onRetry: () => ref.invalidate(
                hadithsByBookProvider((collection: collection, bookNumber: bookNumber)),
              ),
            ),
            data: (hadiths) {
              if (hadiths.isEmpty) {
                return const EmptyStateWidget(
                  icon: Icons.auto_stories_outlined,
                  title: 'Aucun hadith dans ce chapitre',
                );
              }
              return ListView.builder(
                itemCount: hadiths.length,
                itemBuilder: (context, index) {
                  final hadith = hadiths[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.emerald.withValues(alpha: 0.12),
                      child: Text(
                        '${hadith.hadithNumber}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.emerald,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      hadith.english.isEmpty ? hadith.arabic : hadith.english,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text('${hadith.collection} ${hadith.bookNumber}:${hadith.hadithNumber}'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/hadith/${hadith.id}', extra: hadith),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
