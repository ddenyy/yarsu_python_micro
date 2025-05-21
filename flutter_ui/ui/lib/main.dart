import 'package:flutter/material.dart';
import 'core/api_client.dart';
import 'data/auth_repository_impl.dart';
import 'presentation/screens/login_screen.dart';

void main() {
  final apiClient = ApiClient('http://localhost:8080');
  final authRepo = AuthRepositoryImpl(apiClient);

  runApp(MaterialApp(
    home: LoginScreen(authRepo: authRepo),
  ));
}