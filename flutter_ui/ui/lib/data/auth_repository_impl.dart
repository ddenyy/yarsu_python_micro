import '../core/api_client.dart';
import '../domain/auth_repository.dart';
import '../domain/models/user.dart';
import 'dart:convert';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient api;

  AuthRepositoryImpl(this.api);

  @override
  Future<User> login(String email, String password) async {
    final response = await api.post('/login',
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}));
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Ошибка входа');
    }
  }

  @override
  Future<User> register(String email, String password) async {
    final response = await api.post('/register',
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}));
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Ошибка регистрации');
    }
  }
}