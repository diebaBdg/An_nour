import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../models/favorite_model.dart';
import '../../models/prayer_model.dart';
import '../../providers/prayer_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/notification_service.dart';

/// Paramètres de l'application.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        children: [
          _SectionHeader(title: 'Apparence'),
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: const Text('Mode sombre'),
            subtitle: Text(_themeLabel(settings.themeMode)),
            onTap: () => _showThemePicker(context, notifier, settings.themeMode),
          ),
          ListTile(
            leading: const Icon(Icons.text_fields_rounded),
            title: const Text('Taille du texte'),
            subtitle: Slider(
              value: settings.textScale,
              min: 0.8,
              max: 1.4,
              divisions: 6,
              activeColor: AppColors.emerald,
              onChanged: notifier.setTextScale,
            ),
          ),
          const _SectionHeader(title: 'Langue'),
          // ✅ Utiliser Radio avec un groupValue partagé
          ..._buildLanguageRadios(settings, notifier),
          const _SectionHeader(title: 'Prières'),
          ListTile(
            leading: const Icon(Icons.calculate_rounded),
            title: const Text('Méthode de calcul'),
            subtitle: Text(settings.prayerMethod.label),
            onTap: () => _showMethodPicker(context, ref, settings.prayerMethod),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active_outlined),
            title: const Text('Notifications de prière'),
            value: settings.notificationsEnabled,
            activeThumbColor: AppColors.emerald,
            onChanged: (value) async {
              if (value) await NotificationService.requestPermission();
              await notifier.setNotificationsEnabled(value);
              if (value) ref.invalidate(prayerTimesProvider);
            },
          ),
          const _SectionHeader(title: 'Audio'),
          // ✅ Utiliser Radio avec un groupValue partagé
          ..._buildReciterRadios(settings, notifier),
        ],
      ),
    );
  }

  String _themeLabel(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => 'Clair',
      ThemeMode.dark => 'Sombre',
      ThemeMode.system => 'Système',
    };
  }

  void _showThemePicker(
      BuildContext context,
      SettingsNotifier notifier,
      ThemeMode current,
      ) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThemeMode.values
              .map(
                (mode) => RadioListTile<ThemeMode>(
              title: Text(_themeLabel(mode)),
              value: mode,
              groupValue: current,
              activeColor: AppColors.emerald,
              onChanged: (value) {
                if (value != null) {
                  notifier.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
          )
              .toList(),
        ),
      ),
    );
  }

  void _showMethodPicker(
      BuildContext context,
      WidgetRef ref,
      CalculationMethodType current,
      ) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: CalculationMethodType.values
                .map(
                  (method) => RadioListTile<CalculationMethodType>(
                title: Text(method.label, style: const TextStyle(fontSize: 14)),
                value: method,
                groupValue: current,
                activeColor: AppColors.emerald,
                onChanged: (value) {
                  if (value != null) {
                    ref.read(settingsProvider.notifier).setPrayerMethod(value);
                    ref.invalidate(prayerTimesProvider);
                    Navigator.pop(context);
                  }
                },
              ),
            )
                .toList(),
          ),
        ),
      ),
    );
  }

  // ✅ Méthode pour construire les radios de langue sans dépréciation
  List<Widget> _buildLanguageRadios(AppSettings settings, SettingsNotifier notifier) {
    final languages = const [
      ('fr', 'Français'),
      ('en', 'English'),
      ('ar', 'العربية'),
    ];

    return languages.map((entry) {
      final isSelected = settings.locale.languageCode == entry.$1;
      return ListTile(
        leading: Radio<String>(
          value: entry.$1,
          groupValue: settings.locale.languageCode,
          activeColor: AppColors.emerald,
          onChanged: (value) {
            if (value != null) {
              notifier.setLocale(Locale(value));
            }
          },
        ),
        title: Text(entry.$2),
        onTap: () {
          notifier.setLocale(Locale(entry.$1));
        },
      );
    }).toList();
  }

  // ✅ Méthode pour construire les radios de récitateur sans dépréciation
  List<Widget> _buildReciterRadios(AppSettings settings, SettingsNotifier notifier) {
    return Reciter.values.map((reciter) {
      final isSelected = settings.reciter == reciter;
      return ListTile(
        leading: Radio<Reciter>(
          value: reciter,
          groupValue: settings.reciter,
          activeColor: AppColors.emerald,
          onChanged: (value) {
            if (value != null) {
              notifier.setReciter(value);
            }
          },
        ),
        title: Text(reciter.label),
        onTap: () {
          notifier.setReciter(reciter);
        },
      );
    }).toList();
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: AppColors.emerald,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}