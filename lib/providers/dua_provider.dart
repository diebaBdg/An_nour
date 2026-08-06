import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/dua_model.dart';
import '../models/hadith_model.dart';
import '../repositories/dua_repository.dart';

final duaRepositoryProvider = Provider<DuaRepository>((ref) => DuaRepository());
final hadithRepositoryProvider =
    Provider<HadithRepository>((ref) => HadithRepository());
final quoteRepositoryProvider =
    Provider<QuoteRepository>((ref) => QuoteRepository());

// ===== Hadiths =====

/// Collections disponibles.
final hadithCollectionsProvider = Provider<List<HadithCollection>>((ref) {
  return [
    HadithCollection(id: 'bukhari', name: 'Sahih al-Bukhari', hadithCount: 7563),
    HadithCollection(id: 'muslim', name: 'Sahih Muslim', hadithCount: 7470),
  ];
});

/// Liste des livres (chapitres) d'une collection.
final hadithBooksProvider =
    FutureProvider.family<List<HadithBookInfo>, String>((ref, collection) async {
  final books = await ref.watch(hadithRepositoryProvider).getBooks(collection);
  return books
      .map((b) => HadithBookInfo(
            number: b['bookNumber'] as int? ?? 0,
            name: b['bookName'] as String? ?? '',
          ))
      .toList();
});

/// Hadiths d'un livre spécifique.
final hadithsByBookProvider = FutureProvider.family<
    List<Hadith>,
    ({String collection, int bookNumber})>((ref, params) async {
  return ref.watch(hadithRepositoryProvider).getHadithsByBook(
        collection: params.collection,
        bookNumber: params.bookNumber,
      );
});

// ===== Douas =====

/// Catégories de douas depuis l'API Hisn al-Muslim.
final duaCategoriesProvider =
    FutureProvider<List<DuaCategory>>((ref) async {
  return ref.watch(duaRepositoryProvider).getCategories();
});

/// Douas d'une catégorie spécifique.
final duasByApiCategoryProvider =
    FutureProvider.family<List<Dua>, int>((ref, categoryId) async {
  return ref.watch(duaRepositoryProvider).getDuasByCategoryId(categoryId);
});

// ===== Legacy (compatibilité) =====

final hadithsProvider = FutureProvider<List<Hadith>>((ref) async {
  return ref.watch(hadithRepositoryProvider).getLocalHadiths();
});

final hadithThemesProvider = FutureProvider<List<String>>((ref) async {
  return ref.watch(hadithRepositoryProvider).getThemes();
});

final dailyQuoteProvider = FutureProvider<DailyQuote>((ref) async {
  return ref.watch(quoteRepositoryProvider).getDailyQuote();
});

final duaSearchProvider = StateProvider<String>((ref) => '');
final hadithSearchProvider = StateProvider<String>((ref) => '');

/// Modèles simples pour les vues.
class HadithCollection {
  const HadithCollection({
    required this.id,
    required this.name,
    required this.hadithCount,
  });
  final String id;
  final String name;
  final int hadithCount;
}

class HadithBookInfo {
  const HadithBookInfo({required this.number, required this.name});
  final int number;
  final String name;
}
