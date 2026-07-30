import '../models/favorite_model.dart';
import '../models/tasbih_model.dart';
import '../services/storage_service.dart';

class FavoritesRepository {
  static const _key = 'favorite_items';

  List<FavoriteItem> getAll() {
    try {
      final raw = StorageService.favoritesBox.get(_key, defaultValue: <dynamic>[]) as List;

      return raw
          .map((e) => FavoriteItem.fromJsonSafe(e))
          .toList();
    } catch (e) {
      print('Error loading favorites: $e');
      return [];
    }
  }

  Future<void> add(FavoriteItem item) async {
    final items = getAll();
    if (items.any((i) => i.id == item.id && i.type == item.type)) return;
    items.add(item);
    await _save(items);
  }

  Future<void> remove(String id, FavoriteType type) async {
    final items = getAll()
      ..removeWhere((i) => i.id == id && i.type == type);
    await _save(items);
  }

  bool isFavorite(String id, FavoriteType type) {
    return getAll().any((i) => i.id == id && i.type == type);
  }

  List<FavoriteItem> getByType(FavoriteType type) {
    return getAll().where((i) => i.type == type).toList();
  }

  Future<void> _save(List<FavoriteItem> items) async {
    await StorageService.favoritesBox.put(
      _key,
      items.map((e) => e.toJson()).toList(),
    );
  }
}

class TasbihRepository {
  static const _historyKey = 'tasbih_history';
  static const _countKey = 'tasbih_current_count';
  static const _dhikrKey = 'tasbih_current_dhikr';

  int getCurrentCount() =>
      StorageService.tasbihBox.get(_countKey, defaultValue: 0) as int;

  Future<void> setCurrentCount(int count) async {
    await StorageService.tasbihBox.put(_countKey, count);
  }

  String getCurrentDhikr() =>
      StorageService.tasbihBox.get(_dhikrKey, defaultValue: 'SubhanAllah') as String;

  Future<void> setCurrentDhikr(String dhikr) async {
    await StorageService.tasbihBox.put(_dhikrKey, dhikr);
  }

  List<TasbihSession> getHistory() {
    try {
      final raw = StorageService.tasbihBox.get(_historyKey, defaultValue: <dynamic>[]) as List;
      return raw
          .map((e) => TasbihSession.fromJsonSafe(e))
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      print('Error loading tasbih history: $e');
      return [];
    }
  }

  Future<void> saveSession(TasbihSession session) async {
    final history = getHistory()..insert(0, session);
    if (history.length > 50) history.removeRange(50, history.length);
    await StorageService.tasbihBox.put(
      _historyKey,
      history.map((e) => e.toJson()).toList(),
    );
  }

  Future<void> resetCount() => setCurrentCount(0);
}