import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/seerah_model.dart';
import '../services/local_data_service.dart';

final seerahRepositoryProvider = Provider<SeerahRepository>((ref) {
  return SeerahRepository();
});

final seerahEventsProvider =
    FutureProvider<List<SeerahEvent>>((ref) async {
  return ref.watch(seerahRepositoryProvider).getAllEvents();
});

final seerahEraFilterProvider =
    StateProvider<SeerahEra?>((ref) => null);

final filteredSeerahProvider =
    Provider<AsyncValue<List<SeerahEvent>>>((ref) {
  final eventsAsync = ref.watch(seerahEventsProvider);
  final eraFilter = ref.watch(seerahEraFilterProvider);

  return eventsAsync.whenData((events) {
    if (eraFilter == null) return events;
    return events.where((e) => e.era == eraFilter.key).toList();
  });
});

/// Repository pour la biographie du Prophète ﷺ.
class SeerahRepository {
  SeerahRepository({LocalDataService? localDataService})
      : _local = localDataService ?? LocalDataService();

  final LocalDataService _local;

  Future<List<SeerahEvent>> getAllEvents() => _local.getSeerahEvents();

  Future<List<SeerahEvent>> getByEra(SeerahEra era) async {
    final all = await getAllEvents();
    return all.where((e) => e.era == era.key).toList();
  }
}
