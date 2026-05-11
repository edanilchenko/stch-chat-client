import 'package:flutter/foundation.dart';
import '../models/message.dart';
import '../services/chat_service.dart';

class MessageProvider extends ChangeNotifier {
  final ChatService _chatService;

  List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;

  MessageProvider(this._chatService);

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMessages() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _messages = await _chatService.fetchMessages();
    } catch (_) {
      _error = 'Failed to load messages';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String content) async {
    try {
      final message = await _chatService.sendMessage(content);
      _messages.add(message);
      notifyListeners();
    } catch (_) {
      _error = 'Failed to send message';
      notifyListeners();
    }
  }
}
