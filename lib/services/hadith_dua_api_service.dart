import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Service API pour les hadiths (fawazahmed0) et les douas (Hisn al-Muslim).
///
/// Hadiths: https://github.com/fawazahmed0/hadith-api
/// Douas: https://github.com/fawazahmed0/hisnulmuslim
class HadithDuaApiService {
  HadithDuaApiService() {
    _hadithDio = Dio(BaseOptions(
      baseUrl: 'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Accept': 'application/json'},
    ));
    _duaDio = Dio(BaseOptions(
      baseUrl: 'https://cdn.jsdelivr.net/gh/fawazahmed0/hisnulmuslim@1',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Accept': 'application/json'},
    ));
    if (kDebugMode) {
      _hadithDio.interceptors
          .add(LogInterceptor(requestBody: false, responseBody: false));
      _duaDio.interceptors
          .add(LogInterceptor(requestBody: false, responseBody: false));
    }
  }

  late final Dio _hadithDio;
  late final Dio _duaDio;

  // ===== Hadiths =====

  /// Récupère les métadonnées d'une collection (liste des livres/chapitres).
  Future<Map<String, dynamic>> getCollectionMetadata(String collection) async {
    final response = await _hadithDio.get('/editions/ara-$collection.json');
    final data = response.data as Map<String, dynamic>;
    final metadata = data['metadata'] as Map<String, dynamic>? ?? {};
    return metadata;
  }

  /// Récupère la liste des livres (chapitres) d'une collection.
  Future<List<Map<String, dynamic>>> getBooks(String collection) async {
    final metadata = await getCollectionMetadata(collection);
    final sections = metadata['sections'] as Map<String, dynamic>? ?? {};
    final result = <Map<String, dynamic>>[];
    sections.forEach((key, value) {
      result.add({
        'bookNumber': int.tryParse(key) ?? 0,
        'bookName': value.toString(),
      });
    });
    return result;
  }

  /// Récupère les hadiths d'un livre spécifique, avec texte arabe + traduction française.
  /// Retourne une liste de hadiths fusionnés.
  Future<List<Map<String, dynamic>>> getHadithsByBook({
    required String collection,
    required int bookNumber,
  }) async {
    // Fetch Arabic edition
    final arabicResponse =
        await _hadithDio.get('/editions/ara-$collection/$bookNumber.json');
    final arabicData = arabicResponse.data as Map<String, dynamic>;
    final arabicHadiths = arabicData['hadiths'] as List<dynamic>? ?? [];

    // Fetch French edition (fallback to English)
    List<dynamic> translationHadiths = [];
    try {
      final fraResponse =
          await _hadithDio.get('/editions/fra-$collection/$bookNumber.json');
      translationHadiths =
          (fraResponse.data as Map<String, dynamic>)['hadiths'] as List<dynamic>? ?? [];
    } catch (_) {
      try {
        final engResponse =
            await _hadithDio.get('/editions/eng-$collection/$bookNumber.json');
        translationHadiths =
            (engResponse.data as Map<String, dynamic>)['hadiths'] as List<dynamic>? ?? [];
      } catch (_) {
        // No translation available
      }
    }

    // Build translation map by hadithNumber
    final translationMap = <int, String>{};
    for (final t in translationHadiths) {
      final th = t as Map<String, dynamic>;
      final num = th['hadithNumber'] as int? ?? 0;
      translationMap[num] = th['text'] as String? ?? '';
    }

    final metadata = arabicData['metadata'] as Map<String, dynamic>? ?? {};
    final sectionNames = metadata['sections'] as Map<String, dynamic>? ?? {};

    final result = <Map<String, dynamic>>[];
    for (final h in arabicHadiths) {
      final hadith = h as Map<String, dynamic>;
      final hNum = hadith['hadithNumber'] as int? ?? 0;
      final bNum = hadith['bookNumber'] as int? ?? bookNumber;
      result.add({
        'id': '${collection}_$bNum}_$hNum',
        'collection': _collectionDisplayName(collection),
        'bookNumber': bNum,
        'hadithNumber': hNum,
        'arabic': hadith['text'] as String? ?? '',
        'english': translationMap[hNum] ?? '',
        'narrator': '',
        'theme': sectionNames[bNum.toString()] as String? ?? 'Général',
      });
    }
    return result;
  }

  // ===== Douas (Hisn al-Muslim) =====

  /// Récupère toutes les catégories de douas.
  Future<List<Map<String, dynamic>>> getDuaCategories() async {
    final response = await _duaDio.get('/en/hisnul.json');
    final data = response.data as Map<String, dynamic>;
    final categories = data['categories'] as List<dynamic>? ?? [];
    return categories.map((c) {
      final cat = c as Map<String, dynamic>;
      return {
        'id': cat['id'] as int? ?? 0,
        'name': cat['name'] as String? ?? '',
        'icon': cat['icon'] as String? ?? '',
      };
    }).toList();
  }

  /// Récupère tous les douas d'une catégorie.
  Future<List<Map<String, dynamic>>> getDuasByCategoryId(int categoryId) async {
    final response = await _duaDio.get('/en/hisnul.json');
    final data = response.data as Map<String, dynamic>;
    final categories = data['categories'] as List<dynamic>? ?? [];

    for (final c in categories) {
      final cat = c as Map<String, dynamic>;
      if ((cat['id'] as int?) == categoryId) {
        final duas = cat['content'] as List<dynamic>? ?? [];
        return duas.asMap().entries.map((e) {
          final d = e.value as Map<String, dynamic>;
          return {
            'id': 'dua_${categoryId}_${e.key}',
            'category': cat['name'] as String? ?? 'Divers',
            'arabic': d['arabic'] as String? ?? '',
            'transliteration': d['transliteration'] as String? ?? '',
            'translation': d['translation'] as String? ?? '',
            'reference': d['reference'] as String? ?? '',
          };
        }).toList();
      }
    }
    return [];
  }

  String _collectionDisplayName(String collection) {
    return switch (collection) {
      'bukhari' => 'Sahih Bukhari',
      'muslim' => 'Sahih Muslim',
      _ => collection,
    };
  }
}
