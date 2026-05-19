import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../services/api_client.dart';
import '../services/api_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final ApiClient apiClient;
  final ApiService _apiService;

  AuthStatus _status = AuthStatus.unknown;
  User? _user;

  AuthProvider(this.apiClient) : _apiService = ApiService(apiClient) {
    apiClient.onUnauthorized = _handleUnauthorized;
    _tryAutoLogin();
  }

  AuthStatus get status => _status;
  User? get user => _user;

  Future<void> _tryAutoLogin() async {
    final token = await apiClient.readToken();
    if (token != null) {
      final userJson = await apiClient.readUserJson();
      if (userJson != null) {
        try {
          _user = User.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
        } catch (_) {}
      }
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final result = await _apiService.login(email, password);
    await apiClient.saveToken(result.token);
    await apiClient.saveUserJson(jsonEncode({
      'id': result.user.id,
      'name': result.user.name,
      'email': result.user.email,
    }));
    _user = result.user;
    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      await _apiService.logout();
    } finally {
      await apiClient.clearCredentials();
      _user = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  void _handleUnauthorized() {
    apiClient.clearCredentials();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
