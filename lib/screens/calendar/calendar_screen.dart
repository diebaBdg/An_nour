import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/extensions.dart';
import '../../core/widgets/app_card.dart';
import '../../models/calendar_model.dart';

/// Calendrier islamique avec date hijri et événements importants.
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();

  static const _events = [
    IslamicEvent(
      name: 'Nouvel An Hijri',
      hijriMonth: 1,
      hijriDay: 1,
      description: 'Début de l\'année islamique',
    ),
    IslamicEvent(
      name: 'Achoura',
      hijriMonth: 1,
      hijriDay: 10,
      description: 'Jour du 10 Muharram',
    ),
    IslamicEvent(
      name: 'Mawlid an-Nabi',
      hijriMonth: 3,
      hijriDay: 12,
      description: 'Naissance du Prophète ﷺ',
    ),
    IslamicEvent(
      name: 'Laylat al-Mi\'raj',
      hijriMonth: 7,
      hijriDay: 27,
      description: 'Nuit du voyage nocturne',
    ),
    IslamicEvent(
      name: 'Laylat al-Qadr',
      hijriMonth: 9,
      hijriDay: 27,
      description: 'Nuit du Destin',
    ),
    IslamicEvent(
      name: 'Aïd al-Fitr',
      hijriMonth: 10,
      hijriDay: 1,
      description: 'Fête de la rupture du jeûne',
    ),
    IslamicEvent(
      name: 'Aïd al-Adha',
      hijriMonth: 12,
      hijriDay: 10,
      description: 'Fête du sacrifice',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final hijri = HijriCalendar.fromDate(_selectedDate);
    final gregorian = DateFormat('EEEE d MMMM yyyy', 'fr').format(_selectedDate);

    return Scaffold(
      appBar: AppBar(title: const Text('Calendrier islamique')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GradientCard(
              child: Column(
                children: [
                  Text(
                    hijri.toFormat('dd MMMM yyyy'),
                    style: context.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    gregorian,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Conversion', style: context.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  CalendarDatePicker(
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2035),
                    onDateChanged: (date) =>
                        setState(() => _selectedDate = date),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('Événements islamiques', style: context.textTheme.titleLarge),
            const SizedBox(height: 12),
            ..._events.map(
              (event) => AppCard(
                margin: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '${event.hijriDay}',
                          style: context.textTheme.titleMedium?.copyWith(
                            color: AppColors.goldDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(event.name, style: context.textTheme.titleMedium),
                          Text(
                            event.description,
                            style: context.textTheme.bodySmall,
                          ),
                        ],
                      ),
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
