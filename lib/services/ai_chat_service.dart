import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../core/errors/app_exceptions.dart';

enum ChatRole { user, assistant }

class ChatMessage {
  const ChatMessage({
    required this.role,
    required this.content,
    this.timestamp,
  });

  final ChatRole role;
  final String content;
  final DateTime? timestamp;

  Map<String, dynamic> toJson() => {
    'role': role == ChatRole.user ? 'user' : 'assistant',
    'content': content,
  };
}

class AiChatService {
  static String get _supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get _anonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  static void ensureInitialized() {
    if (_supabaseUrl.isEmpty || _anonKey.isEmpty) {
      throw Exception(
        'Supabase credentials not found. Please set SUPABASE_URL and SUPABASE_ANON_KEY in .env',
      );
    }
  }

  AiChatService() {
    ensureInitialized();

    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(requestBody: false, responseBody: false));
    }
  }

  late final Dio _dio;

  String get _functionUrl => '$_supabaseUrl/functions/v1/ai-chat';

  Future<String> sendMessage(List<ChatMessage> messages) async {
    try {
      final response = await _dio.post<dynamic>(
        _functionUrl,
        data: {
          'messages': messages.map((m) => m.toJson()).toList(),
        },
        options: Options(headers: {
          'Authorization': 'Bearer $_anonKey',
          'apikey': _anonKey,
        }),
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const NetworkException('Format de réponse inattendu');
      }

      final error = data['error'];
      if (error != null) {
        throw NetworkException(error.toString());
      }

      final reply = data['reply'] as String?;
      if (reply == null || reply.isEmpty) {
        throw const NetworkException('Réponse vide de l\'IA');
      }
      return reply;
    } on DioException catch (e) {
      if (e.response?.data case {'error': final String msg}) {
        throw NetworkException(msg);
      }
      throw NetworkException(_dioErrorMessage(e));
    } on AppException {
      rethrow;
    } catch (e) {
      if (kDebugMode) print('❌ Erreur chat IA: $e');
      throw const NetworkException('Connexion au service IA impossible');
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