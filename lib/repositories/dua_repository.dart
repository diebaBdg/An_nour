import '../models/dua_model.dart';
import '../models/hadith_model.dart';
import '../services/local_data_service.dart';

class DuaRepository {
  DuaRepository({LocalDataService? localDataService})
      : _local = localDataService ?? LocalDataService();

  final LocalDataService _local;

  Future<List<Dua>> getAllDuas() => _local.getDuas();

  Future<List<Dua>> getDuasByCategory(DuaCategory category) =>
      _local.getDuasByCategory(category.key);

  Future<List<Dua>> searchDuas(String query) async {
    final all = await getAllDuas();
    final q = query.toLowerCase();
    return all
        .where((d) =>
            d.translation.toLowerCase().contains(q) ||
            d.transliteration.toLowerCase().contains(q) ||
            d.arabic.contains(q),)
        .toList();
  }
}

class HadithRepository {
  HadithRepository({LocalDataService? localDataService})
      : _local = localDataService ?? LocalDataService();

  final LocalDataService _local;

  Future<List<Hadith>> getAllHadiths() => _local.getHadiths();

  Future<List<Hadith>> searchHadiths(String query) async {
    final all = await getAllHadiths();
    final q = query.toLowerCase();
    return all
        .where((h) =>
            h.english.toLowerCase().contains(q) ||
            h.theme.toLowerCase().contains(q) ||
            h.narrator.toLowerCase().contains(q),)
        .toList();
  }

  Future<List<Hadith>> getByTheme(String theme) async {
    final all = await getAllHadiths();
    return all.where((h) => h.theme == theme).toList();
  }

  Future<List<String>> getThemes() async {
    final all = await getAllHadiths();
    return all.map((h) => h.theme).toSet().toList()..sort();
  }
}

class QuoteRepository {
  QuoteRepository({LocalDataService? localDataService})
      : _local = localDataService ?? LocalDataService();

  final LocalDataService _local;

  Future<DailyQuote> getDailyQuote() => _local.getRandomQuote();
}
