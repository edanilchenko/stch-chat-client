import '../models/message.dart';
import 'api_client.dart';

class ChatService {
  final ApiClient apiClient;

  ChatService(this.apiClient);

  Future<List<Message>> fetchMessages() async {
    final response = await apiClient.dio.get('/messages');
    final data = response.data as List<dynamic>;
    return data.map((m) => Message.fromJson(m as Map<String, dynamic>)).toList();
  }

  Future<Message> sendMessage(String content) async {
    final response = await apiClient.dio.post('/messages', data: {'content': content});
    return Message.fromJson(response.data as Map<String, dynamic>);
  }
}
