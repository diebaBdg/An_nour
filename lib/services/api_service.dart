import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/errors/app_exceptions.dart';

class ApiService {
  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.quran.com/api/v4',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
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

  Future<Map<String, dynamic>> get(String path) async {
    try {
      final response = await _dio.get(path);

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      throw NetworkException('Erreur HTTP: ${response.statusCode}');
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