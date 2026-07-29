import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/constants/app_constants.dart';
import '../core/errors/app_exceptions.dart';

/// Client HTTP Dio configuré pour les API An-Nour.
class ApiService {
  ApiService() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Accept': 'application/json'},
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(requestBody: false, responseBody: false),
      );
    }
  }

  late final Dio _dio;
  Dio get dio => _dio;

  /// GET vers l'API Coran (alquran.cloud).
  Future<Map<String, dynamic>> getQuran(String path) async {
    try {
      final response = await _dio.get('${AppConstants.quranApiBase}$path');
      if (response.data['code'] == 200) {
        return response.data['data'] as Map<String, dynamic>;
      }
      throw NetworkException('Réponse API invalide');
    } on DioException catch (e) {
      throw NetworkException(_dioErrorMessage(e));
    }
  }

  String _dioErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Délai de connexion dépassé';
      case DioExceptionType.connectionError:
        return 'Pas de connexion internet';
      default:
        return 'Erreur réseau : ${e.message}';
    }
  }
}
