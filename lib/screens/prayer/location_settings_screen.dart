import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/extensions.dart';
import '../../providers/prayer_provider.dart';
import '../../services/storage_service.dart';

/// Écran de sélection de localisation inspiré de Muslim Pro.
class LocationSettingsScreen extends ConsumerStatefulWidget {
  const LocationSettingsScreen({super.key});

  @override
  ConsumerState<LocationSettingsScreen> createState() =>
      _LocationSettingsScreenState();
}

class _LocationSettingsScreenState
    extends ConsumerState<LocationSettingsScreen> {
  String? _selectedCity;
  bool _useGps = true;
  String _search = '';

  static const _senegalFlag = '🇸🇳';

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final useCustom = StorageService.getBool(
      AppConstants.keyUseCustomLocation,
      defaultValue: false,
    );
    if (useCustom) {
      _useGps = false;
      _selectedCity =
          StorageService.getString(AppConstants.keyCustomCity) ?? 'Dakar';
    }
  }

  List<MapEntry<String, ({double lat, double lng})>> get _filteredCities {
    final entries = AppConstants.senegalCities.entries.toList();
    if (_search.isEmpty) return entries;
    final q = _search.toLowerCase();
    return entries
        .where((e) => e.key.toLowerCase().contains(q))
        .toList();
  }

  Future<void> _selectCity(
      String name, double lat, double lng) async {
    final repo = ref.read(prayerRepositoryProvider);
    await repo.saveCustomLocation(
        latitude: lat, longitude: lng, city: '$name, Sénégal');
    ref.invalidate(prayerTimesProvider);
    setState(() => _selectedCity = name);
    if (mounted) {
      context.showSnack('$_senegalFlag $name sélectionné');
      Navigator.pop(context);
    }
  }

  Future<void> _enableGps() async {
    final repo = ref.read(prayerRepositoryProvider);
    await repo.disableCustomLocation();
    ref.invalidate(prayerTimesProvider);
    setState(() {
      _useGps = true;
      _selectedCity = null;
    });
    if (mounted) {
      context.showSnack('GPS activé – recalcul en cours');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0D1B1A) : const Color(0xFFF0F7F4),
      appBar: AppBar(
        title: const Text('Localisation'),
        backgroundColor: AppColors.emerald,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Bannière GPS
          _GpsBanner(
            useGps: _useGps,
            onToggle: _useGps ? null : _enableGps,
          ),

          // Barre de recherche
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: 'Rechercher une ville...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () =>
                            setState(() => _search = ''),
                      )
                    : null,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                const Text('$_senegalFlag  ',
                    style: TextStyle(fontSize: 16)),
                Text(
                  'Villes du Sénégal',
                  style: context.textTheme.titleSmall?.copyWith(
                    color: AppColors.emerald,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Liste des villes
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: _filteredCities.length,
              itemBuilder: (context, index) {
                final city = _filteredCities[index];
                final isSelected =
                    !_useGps && _selectedCity == city.key;

                return _CityTile(
                  name: city.key,
                  lat: city.value.lat,
                  lng: city.value.lng,
                  isSelected: isSelected,
                  onTap: () => _selectCity(
                      city.key, city.value.lat, city.value.lng),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GpsBanner extends StatelessWidget {
  const _GpsBanner({required this.useGps, this.onToggle});

  final bool useGps;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: useGps
            ? AppColors.emerald.withValues(alpha: 0.12)
            : Colors.grey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: useGps
              ? AppColors.emerald.withValues(alpha: 0.4)
              : Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            useGps ? Icons.gps_fixed_rounded : Icons.gps_off_rounded,
            color: useGps ? AppColors.emerald : Colors.grey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              useGps
                  ? 'Position GPS activée – détection automatique'
                  : 'GPS désactivé – choisissez une ville ci-dessous',
              style: TextStyle(
                color: useGps ? AppColors.emerald : Colors.grey,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
          if (!useGps)
            TextButton(
              onPressed: onToggle,
              child: Text(
                'Activer',
                style: TextStyle(color: AppColors.emerald),
              ),
            ),
        ],
      ),
    );
  }
}

class _CityTile extends StatelessWidget {
  const _CityTile({
    required this.name,
    required this.lat,
    required this.lng,
    required this.isSelected,
    required this.onTap,
  });

  final String name;
  final double lat;
  final double lng;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.emerald.withValues(alpha: 0.1)
            : isDark
                ? const Color(0xFF1A2E28)
                : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? AppColors.emerald.withValues(alpha: 0.5)
              : isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.emerald.withValues(alpha: 0.15)
                : AppColors.emerald.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.location_on_rounded,
            color: AppColors.emerald,
            size: 18,
          ),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight:
                isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        subtitle: Text(
          'Sénégal  •  ${lat.toStringAsFixed(4)}°N, ${lng.abs().toStringAsFixed(4)}°O',
          style: context.textTheme.bodySmall,
        ),
        trailing: isSelected
            ? Icon(Icons.check_circle_rounded,
                color: AppColors.emerald)
            : const Icon(Icons.chevron_right_rounded,
                color: Colors.grey),
      ),
    );
  }
}
