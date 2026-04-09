import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class ChatService {
  final String baseUrl = 'http://127.0.0.1:8000/api';

  Future<List<Message>> fetchMessages() async {
    final res = await http.get(Uri.parse('$baseUrl/messages'));

    final data = jsonDecode(res.body);
    return data.map<Message>((m) => Message.fromJson(m)).toList();
  }

  Future<void> sendMessage(String text) async {
    await http.post(
      Uri.parse('$baseUrl/messages'),
      body: {'text': text},
    );
  }
}