import 'package:flutter/material.dart';
import '../../data/auth_repository_impl.dart';
import '../../core/api_client.dart';

class LoginScreen extends StatefulWidget {
  final AuthRepositoryImpl authRepo;
  const LoginScreen({required this.authRepo, super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Вход')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: passwordController, decoration: InputDecoration(labelText: 'Пароль'), obscureText: true),
            if (error != null) Text(error!, style: TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: () async {
                try {
                  final user = await widget.authRepo.login(emailController.text, passwordController.text);
                  // Перейти на профиль или сохранить токен
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Добро пожаловать, ${user.email}')));
                } catch (e) {
                  setState(() => error = e.toString());
                }
              },
              child: Text('Войти'),
            ),
            TextButton(
              onPressed: () {
                // Перейти на экран регистрации
              },
              child: Text('Нет аккаунта? Зарегистрироваться'),
            ),
          ],
        ),
      ),
    );
  }
}