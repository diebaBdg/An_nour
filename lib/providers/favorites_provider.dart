import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/favorite_model.dart';
import '../models/tasbih_model.dart';
import '../repositories/favorites_repository.dart';

final favoritesRepositoryProvider =
    Provider<FavoritesRepository>((ref) => FavoritesRepository());

final tasbihRepositoryProvider =
    Provider<TasbihRepository>((ref) => TasbihRepository());

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, List<FavoriteItem>>((ref) {
  return FavoritesNotifier(ref.watch(favoritesRepositoryProvider));
});

class FavoritesNotifier extends StateNotifier<List<FavoriteItem>> {
  FavoritesNotifier(this._repo) : super(_repo.getAll());

  final FavoritesRepository _repo;

  Future<void> toggle(FavoriteItem item) async {
    if (_repo.isFavorite(item.id, item.type)) {
      await _repo.remove(item.id, item.type);
    } else {
      await _repo.add(item);
    }
    state = _repo.getAll();
  }

  bool isFavorite(String id, FavoriteType type) =>
      _repo.isFavorite(id, type);

  List<FavoriteItem> byType(FavoriteType type) => _repo.getByType(type);
}

final tasbihCountProvider =
    StateNotifierProvider<TasbihNotifier, TasbihState>((ref) {
  return TasbihNotifier(ref.watch(tasbihRepositoryProvider));
});

class TasbihState {
  const TasbihState({
    this.count = 0,
    this.dhikr = DhikrType.subhanAllah,
    this.history = const [],
  });

  final int count;
  final DhikrType dhikr;
  final List<TasbihSession> history;

  TasbihState copyWith({
    int? count,
    DhikrType? dhikr,
    List<TasbihSession>? history,
  }) {
    return TasbihState(
      count: count ?? this.count,
      dhikr: dhikr ?? this.dhikr,
      history: history ?? this.history,
    );
  }
}

class TasbihNotifier extends StateNotifier<TasbihState> {
  TasbihNotifier(this._repo)
      : super(TasbihState(
          count: _repo.getCurrentCount(),
          history: _repo.getHistory(),
        ));

  final TasbihRepository _repo;

  Future<void> increment() async {
    final newCount = state.count + 1;
    await _repo.setCurrentCount(newCount);
    state = state.copyWith(count: newCount);

    if (newCount >= state.dhikr.defaultTarget) {
      await _repo.saveSession(TasbihSession(
        dhikr: state.dhikr.label,
        count: newCount,
        target: state.dhikr.defaultTarget,
        timestamp: DateTime.now(),
      ));
    }
  }

  Future<void> reset() async {
    await _repo.resetCount();
    state = state.copyWith(count: 0);
  }

  Future<void> setDhikr(DhikrType dhikr) async {
    await _repo.setCurrentDhikr(dhikr.label);
    await _repo.resetCount();
    state = TasbihState(
      dhikr: dhikr,
      history: _repo.getHistory(),
    );
  }
}
