import '../models/user.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient apiClient;

  AuthService(this.apiClient);

  Future<({User user, String token})> login(String email, String password) async {
    final response = await apiClient.dio.post('/login', data: {
      'email': email,
      'password': password,
    });
    final token = response.data['token'] as String;
    final user = User.fromJson(response.data['user'] as Map<String, dynamic>);
    await apiClient.saveToken(token);
    return (user: user, token: token);
  }

  Future<void> logout() async {
    try {
      await apiClient.dio.post('/logout');
    } finally {
      await apiClient.clearToken();
    }
  }
}
