import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final ApiClient apiClient;
  final AuthService _authService;

  AuthStatus _status = AuthStatus.unknown;
  User? _user;

  AuthProvider(this.apiClient) : _authService = AuthService(apiClient) {
    apiClient.onUnauthorized = _handleUnauthorized;
    _tryAutoLogin();
  }

  AuthStatus get status => _status;
  User? get user => _user;

  Future<void> _tryAutoLogin() async {
    final token = await apiClient.getToken();
    _status = token != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final result = await _authService.login(email, password);
    _user = result.user;
    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void _handleUnauthorized() {
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
