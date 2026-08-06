import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/errors/app_exceptions.dart';

/// Rôle d'un message dans la conversation.
enum ChatRole { user, assistant }

/// Un message du chat IA.
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

/// Service qui appelle l'edge function Supabase `ai-chat` (proxy OpenAI).
class AiChatService {
  AiChatService() {
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

  static const _supabaseUrl =
      'https://gacfvryayuteekdecydd.supabase.co';
  static const _anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdhY2Z2cnlheXV0ZWVrZGVjeWRkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODYwMjg3MzYsImV4cCI6MjEwMTYwNDczNn0.1VY0UlT37uGXE4LqYGN5Wv4_2sKYKfmKXfDqKtP_ZDA';

  String get _functionUrl => '$_supabaseUrl/functions/v1/ai-chat';

  /// Envoie l'historique des messages et retourne la réponse de l'IA.
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
