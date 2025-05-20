import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool isLogin = true;
  bool isLoading = false;
  String? errorMessage;

  Future<void> submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => errorMessage = 'Поля не должны быть пустыми');
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final url =
        Uri.parse('http://localhost:8081/${isLogin ? "login" : "register"}');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Успешно: $data');

        // Здесь логика сохранения токена, переход на другой экран и т.п.
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isLogin ? 'Успешный вход' : 'Успешная регистрация'),
        ));
      } else {
        setState(() => errorMessage = 'Ошибка: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => errorMessage = 'Ошибка соединения: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isLogin ? 'Вход' : 'Регистрация'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (errorMessage != null)
              Text(errorMessage!, style: TextStyle(color: Colors.red)),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Пароль'),
            ),
            SizedBox(height: 20),
            if (isLoading)
              CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: submit,
                child: Text(isLogin ? 'Войти' : 'Зарегистрироваться'),
              ),
            TextButton(
              onPressed: () => setState(() => isLogin = !isLogin),
              child: Text(isLogin
                  ? 'Нет аккаунта? Зарегистрироваться'
                  : 'Уже есть аккаунт? Войти'),
            ),
          ],
        ),
      ),
    );
  }
}
