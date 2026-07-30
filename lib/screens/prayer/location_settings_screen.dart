import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/prayer_provider.dart';
import '../../providers/settings_provider.dart';

class LocationSettingsScreen extends ConsumerStatefulWidget {
  const LocationSettingsScreen({super.key});

  @override
  ConsumerState<LocationSettingsScreen> createState() => _LocationSettingsScreenState();
}

class _LocationSettingsScreenState extends ConsumerState<LocationSettingsScreen> {
  String? _selectedCity;
  bool _useGps = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final repo = ref.read(prayerRepositoryProvider);
    final customLocation = repo.getCustomLocation();
    if (customLocation != null) {
      _useGps = false;
      _selectedCity = customLocation.city;
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(prayerRepositoryProvider);
    final cities = repo.getSenegalCities();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Localisation'),
        backgroundColor: AppColors.emerald,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Option GPS
            Card(
              child: SwitchListTile(
                title: const Text('Utiliser ma position GPS'),
                subtitle: const Text('Désactivez pour choisir une ville manuellement'),
                value: _useGps,
                onChanged: (value) async {
                  setState(() {
                    _useGps = value;
                    if (value) {
                      _selectedCity = null;
                    }
                  });
                  if (value) {
                    await repo.disableCustomLocation();
                    ref.invalidate(prayerTimesProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Utilisation du GPS activée')),
                    );
                  }
                },
                activeColor: AppColors.emerald,
              ),
            ),

            const SizedBox(height: 16),

            // Liste des villes si GPS désactivé
            if (!_useGps) ...[
              const Text(
                'Choisissez votre ville',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: cities.length,
                  itemBuilder: (context, index) {
                    final city = cities[index];
                    final isSelected = _selectedCity == city.name;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: Icon(
                          isSelected ? Icons.check_circle : Icons.location_on,
                          color: isSelected ? AppColors.emerald : Colors.grey,
                        ),
                        title: Text(city.name),
                        subtitle: Text(
                          'Lat: ${city.lat.toStringAsFixed(4)}, Lng: ${city.lng.toStringAsFixed(4)}',
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check, color: AppColors.emerald)
                            : null,
                        onTap: () async {
                          setState(() {
                            _selectedCity = city.name;
                          });
                          await repo.saveCustomLocation(
                            latitude: city.lat,
                            longitude: city.lng,
                            city: city.name,
                          );
                          ref.invalidate(prayerTimesProvider);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Ville sélectionnée: ${city.name}')),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],

            // Informations
            const SizedBox(height: 16),
            Card(
              color: AppColors.emerald.withValues(alpha: 0.1),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📍 Méthode de calcul',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Les horaires sont calculés selon la méthode Muslim World League, '
                          'adaptée pour le Sénégal et l\'Afrique de l\'Ouest.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}