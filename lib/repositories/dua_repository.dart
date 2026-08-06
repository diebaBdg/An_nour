import '../models/dua_model.dart';
import '../models/hadith_model.dart';
import '../services/hadith_dua_api_service.dart';
import '../services/local_data_service.dart';

class DuaRepository {
  DuaRepository({HadithDuaApiService? api, LocalDataService? localDataService})
      : _api = api ?? HadithDuaApiService(),
        _local = localDataService ?? LocalDataService();

  final HadithDuaApiService _api;
  final LocalDataService _local;
  List<DuaCategory>? _categories;
  final Map<int, List<Dua>> _duasByCategory = {};

  /// Récupère toutes les catégories de douas depuis l'API Hisn al-Muslim.
  Future<List<DuaCategory>> getCategories() async {
    if (_categories != null) return _categories!;
    final raw = await _api.getDuaCategories();
    _categories = raw.map((c) => DuaCategory.fromJson(c)).toList();
    return _categories!;
  }

  /// Récupère les douas d'une catégorie depuis l'API.
  Future<List<Dua>> getDuasByCategoryId(int categoryId) async {
    if (_duasByCategory.containsKey(categoryId)) {
      return _duasByCategory[categoryId]!;
    }
    final raw = await _api.getDuasByCategoryId(categoryId);
    final duas = raw.map((d) => Dua.fromJson(d)).toList();
    _duasByCategory[categoryId] = duas;
    return duas;
  }

  /// Fallback: douas locaux (si l'API échoue).
  Future<List<Dua>> getLocalDuas() => _local.getDuas();

  Future<List<Dua>> searchDuas(String query) async {
    final all = await getLocalDuas();
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
  HadithRepository({HadithDuaApiService? api, LocalDataService? localDataService})
      : _api = api ?? HadithDuaApiService(),
        _local = localDataService ?? LocalDataService();

  final HadithDuaApiService _api;
  final LocalDataService _local;

  final Map<String, List<Map<String, dynamic>>> _booksCache = {};
  final Map<String, Map<int, List<Hadith>>> _hadithsByBookCache = {};

  /// Récupère la liste des livres (chapitres) d'une collection.
  Future<List<Map<String, dynamic>>> getBooks(String collection) async {
    if (_booksCache.containsKey(collection)) {
      return _booksCache[collection]!;
    }
    final books = await _api.getBooks(collection);
    _booksCache[collection] = books;
    return books;
  }

  /// Récupère les hadiths d'un livre spécifique.
  Future<List<Hadith>> getHadithsByBook({
    required String collection,
    required int bookNumber,
  }) async {
    final key = '${collection}_$bookNumber';
    if (_hadithsByBookCache.containsKey(key)) {
      return _hadithsByBookCache[key]!;
    }
    final raw = await _api.getHadithsByBook(
      collection: collection,
      bookNumber: bookNumber,
    );
    final hadiths = raw.map((h) => Hadith.fromJson(h)).toList();
    _hadithsByBookCache[key] = hadiths;
    return hadiths;
  }

  /// Fallback: hadiths locaux.
  Future<List<Hadith>> getLocalHadiths() => _local.getHadiths();

  Future<List<String>> getThemes() async {
    final all = await _local.getHadiths();
    return all.map((h) => h.theme).toSet().toList()..sort();
  }
}

class QuoteRepository {
  QuoteRepository({LocalDataService? localDataService})
      : _local = localDataService ?? LocalDataService();

  final LocalDataService _local;

  Future<DailyQuote> getDailyQuote() => _local.getRandomQuote();
}
