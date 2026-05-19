import 'package:flutter/foundation.dart';

import '../models/conversation.dart';
import '../services/api_service.dart';

class ConversationProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<Conversation> _conversations = [];
  bool _isLoading = false;
  String? _error;

  ConversationProvider(this._apiService);

  List<Conversation> get conversations => _conversations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadConversations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _conversations = await _apiService.getConversations();
    } on Exception catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
