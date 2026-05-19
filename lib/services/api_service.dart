import 'package:dio/dio.dart';

import '../models/conversation.dart';
import '../models/message.dart';
import '../models/user.dart';
import 'api_client.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class ApiService {
  final ApiClient _client;

  ApiService(this._client);

  Future<T> _call<T>(Future<T> Function() fn) async {
    try {
      return await fn();
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] as String? ??
          e.message ??
          'Unknown error';
      throw ApiException(msg, e.response?.statusCode);
    }
  }

  Future<({String token, User user})> login(String email, String password) {
    return _call(() async {
      final response = await _client.dio.post('/login', data: {
        'email': email,
        'password': password,
      });
      final token = response.data['token'] as String;
      final user = User.fromJson(response.data['user'] as Map<String, dynamic>);
      return (token: token, user: user);
    });
  }

  Future<void> logout() {
    return _call(() => _client.dio.post('/logout'));
  }

  Future<List<Conversation>> getConversations() {
    return _call(() async {
      final response = await _client.dio.get('/conversations');
      final data = response.data as List<dynamic>;
      return data
          .map((c) => Conversation.fromJson(c as Map<String, dynamic>))
          .toList();
    });
  }

  Future<Conversation> startConversation(int userId) {
    return _call(() async {
      final response = await _client.dio.post(
        '/conversations',
        data: {'user_id': userId},
      );
      return Conversation.fromJson(response.data as Map<String, dynamic>);
    });
  }

  Future<List<Message>> getMessages(int conversationId) {
    return _call(() async {
      final response =
          await _client.dio.get('/conversations/$conversationId/messages');
      final data = response.data as List<dynamic>;
      return data
          .map((m) => Message.fromJson(m as Map<String, dynamic>))
          .toList();
    });
  }

  Future<Message> sendMessage(int conversationId, String text) {
    return _call(() async {
      final response = await _client.dio.post(
        '/conversations/$conversationId/messages',
        data: {'text': text},
      );
      return Message.fromJson(response.data as Map<String, dynamic>);
    });
  }
}
