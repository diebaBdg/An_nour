import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/extensions.dart';
import '../../core/widgets/loading_widgets.dart';

/// Écran boussole Qibla utilisant le capteur magnétique.
class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  double? _qiblaDirection;
  String? _error;

  // Coordonnées de La Mecque
  static const _makkahLat = 21.4225;
  static const _makkahLng = 39.8262;

  @override
  void initState() {
    super.initState();
    _initQibla();
  }

  Future<void> _initQibla() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      final qibla = _calculateQiblaDirection(
        position.latitude,
        position.longitude,
      );
      setState(() => _qiblaDirection = qibla);
    } catch (e) {
      setState(() => _error = 'Impossible d\'obtenir la localisation');
    }
  }

  double _calculateQiblaDirection(double lat, double lng) {
    final lat1 = lat * math.pi / 180;
    final lat2 = _makkahLat * math.pi / 180;
    final dLng = (_makkahLng - lng) * math.pi / 180;

    final y = math.sin(dLng) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLng);

    return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Direction Qibla')),
      body: _error != null
          ? ErrorStateWidget(message: _error!, onRetry: _initQibla)
          : _qiblaDirection == null
              ? const LoadingIndicator(message: 'Calibrage de la boussole...')
              : StreamBuilder<CompassEvent>(
                  stream: FlutterCompass.events,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const ErrorStateWidget(
                        message: 'Capteur de boussole indisponible',
                      );
                    }

                    final heading = snapshot.data?.heading;
                    if (heading == null) {
                      return const LoadingIndicator(
                        message: 'Attente du capteur...',
                      );
                    }

                    final qiblaAngle = (_qiblaDirection! - heading + 360) % 360;

                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${_qiblaDirection!.toStringAsFixed(1)}°',
                            style: context.textTheme.headlineLarge?.copyWith(
                              color: AppColors.emerald,
                            ),
                          ),
                          Text(
                            'Angle Qibla depuis le Nord',
                            style: context.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 40),
                          SizedBox(
                            width: 280,
                            height: 280,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Cercle externe
                                Container(
                                  width: 280,
                                  height: 280,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.emerald
                                          .withValues(alpha: 0.3),
                                      width: 3,
                                    ),
                                  ),
                                ),
                                // Aiguille Qibla
                                Transform.rotate(
                                  angle: qiblaAngle * math.pi / 180,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.navigation_rounded,
                                        size: 48,
                                        color: AppColors.gold,
                                      ),
                                      Container(
                                        width: 4,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              AppColors.gold,
                                              AppColors.emerald,
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(2),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Centre Kaaba
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors.emerald,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.emerald
                                            .withValues(alpha: 0.4),
                                        blurRadius: 12,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.mosque_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'Tournez votre téléphone jusqu\'à ce que\nl\'aiguille dorée pointe vers le haut',
                            textAlign: TextAlign.center,
                            style: context.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
