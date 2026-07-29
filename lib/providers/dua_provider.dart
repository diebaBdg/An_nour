import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/dua_model.dart';
import '../models/hadith_model.dart';
import '../repositories/dua_repository.dart';

final duaRepositoryProvider = Provider<DuaRepository>((ref) => DuaRepository());
final hadithRepositoryProvider =
    Provider<HadithRepository>((ref) => HadithRepository());
final quoteRepositoryProvider = Provider<QuoteRepository>((ref) {
  return QuoteRepository();
});

final duasProvider = FutureProvider<List<Dua>>((ref) async {
  return ref.watch(duaRepositoryProvider).getAllDuas();
});

final duasByCategoryProvider =
    FutureProvider.family<List<Dua>, DuaCategory>((ref, category) async {
  return ref.watch(duaRepositoryProvider).getDuasByCategory(category);
});

final hadithsProvider = FutureProvider<List<Hadith>>((ref) async {
  return ref.watch(hadithRepositoryProvider).getAllHadiths();
});

final hadithThemesProvider = FutureProvider<List<String>>((ref) async {
  return ref.watch(hadithRepositoryProvider).getThemes();
});

final dailyQuoteProvider = FutureProvider<DailyQuote>((ref) async {
  return ref.watch(quoteRepositoryProvider).getDailyQuote();
});

final duaSearchProvider = StateProvider<String>((ref) => '');

final hadithSearchProvider = StateProvider<String>((ref) => '');
