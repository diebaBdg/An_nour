import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/divine_name_model.dart';
import '../services/local_data_service.dart';

final divineNamesRepositoryProvider = Provider<DivineNamesRepository>((ref) {
  return DivineNamesRepository();
});

final divineNamesProvider =
    FutureProvider<List<DivineName>>((ref) async {
  return ref.watch(divineNamesRepositoryProvider).getAllNames();
});

final divineNameSearchProvider = StateProvider<String>((ref) => '');

final filteredDivineNamesProvider =
    Provider<AsyncValue<List<DivineName>>>((ref) {
  final namesAsync = ref.watch(divineNamesProvider);
  final query = ref.watch(divineNameSearchProvider);

  return namesAsync.whenData((names) {
    if (query.isEmpty) return names;
    final q = query.toLowerCase();
    return names
        .where((n) =>
            n.transliteration.toLowerCase().contains(q) ||
            n.translation.toLowerCase().contains(q) ||
            n.arabic.contains(q),)
        .toList();
  });
});

/// Repository pour les 99 Noms d'Allah.
class DivineNamesRepository {
  DivineNamesRepository({LocalDataService? localDataService})
      : _local = localDataService ?? LocalDataService();

  final LocalDataService _local;

  Future<List<DivineName>> getAllNames() => _local.getDivineNames();
}
