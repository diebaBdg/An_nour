import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import '../models/dua_model.dart';
import '../models/hadith_model.dart';

/// Charge les données JSON locales (douas, hadiths, citations).
class LocalDataService {
  List<Dua>? _duas;
  List<Hadith>? _hadiths;
  List<Map<String, String>>? _quotes;

  Future<List<Dua>> getDuas() async {
    if (_duas != null) return _duas!;
    final jsonString = await rootBundle.loadString('assets/data/duas.json');
    final list = json.decode(jsonString) as List<dynamic>;
    _duas = list.map((e) => Dua.fromJson(e as Map<String, dynamic>)).toList();
    return _duas!;
  }

  Future<List<Dua>> getDuasByCategory(String category) async {
    final all = await getDuas();
    return all.where((d) => d.category == category).toList();
  }

  Future<List<Hadith>> getHadiths() async {
    if (_hadiths != null) return _hadiths!;
    final jsonString = await rootBundle.loadString('assets/data/hadiths.json');
    final list = json.decode(jsonString) as List<dynamic>;
    _hadiths =
        list.map((e) => Hadith.fromJson(e as Map<String, dynamic>)).toList();
    return _hadiths!;
  }

  Future<DailyQuote> getRandomQuote() async {
    if (_quotes == null) {
      final jsonString =
          await rootBundle.loadString('assets/data/quotes.json');
      final list = json.decode(jsonString) as List<dynamic>;
      _quotes = list
          .map((e) => Map<String, String>.from(e as Map))
          .toList();
    }

    final quote = _quotes![Random().nextInt(_quotes!.length)];
    return DailyQuote(
      text: quote['text']!,
      reference: quote['reference']!,
      type: quote['type'] == 'hadith' ? QuoteType.hadith : QuoteType.quran,
      arabic: quote['arabic'],
    );
  }
}
