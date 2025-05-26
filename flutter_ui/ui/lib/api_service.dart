import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Замените на ваш актуальный IP и порт, если он отличается
  static const String _baseUrl = 'http://localhost:8080';
  static const String _tokenKey = 'auth_token';
  // Ключ для хранения ID пользователя, если он вам понадобится глобально
  static const String _userIdKey = 'user_id';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey); // Очищаем и ID пользователя при выходе
  }

  Future<void> _saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, userId);
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': '*/*',
    };
    if (includeAuth) {
      final token = await _getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: await _getHeaders(includeAuth: false),
      body: jsonEncode({
        'email': email,
        'password': password
      }), // Используем полученный userId
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data.containsKey('access_token')) {
        await _saveToken(data['access_token']!);
      }
      // Попытка извлечь user_id из ответа, если он есть
      // Структура ответа от вашего auth_service при логине может быть другой
      // Например, если user_id находится внутри объекта user: data['user']['id']
      if (data.containsKey('user') &&
          data['user'] is Map &&
          data['user'].containsKey('id')) {
        await _saveUserId(data['user']['id'] as int);
      } else if (data.containsKey('user_id')) {
        await _saveUserId(data['user_id'] as int);
      }
      return data;
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(
          'Ошибка входа: ${errorData['detail'] ?? response.reasonPhrase}');
    }
  }

  Future<Map<String, dynamic>> register(String email, String password,
      String firstName, String lastName, bool isTeacher, int? groupId) async {
    final body = {
      'email': email,
      'password': password,
    };

    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: await _getHeaders(includeAuth: false),
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(
          'Ошибка регистрации: ${errorData['detail'] ?? response.reasonPhrase}');
    }
  }

  Future<void> logout() async {
    await _clearToken();
    // Опционально: вызов эндпоинта /logout на сервере, если он инвалидирует токен
  }

  Future<Map<String, dynamic>> getMyProfile() async {
    final response = await http.get(
      Uri.parse(
          '$_baseUrl/profile'), // Используем эндпоинт /profile как указано пользователем
      headers: await _getHeaders(), // _getHeaders() по умолчанию включает токен
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      if (response.statusCode == 401) {
        throw Exception('Сессия истекла. Пожалуйста, войдите снова.');
      }
      // Попытка распарсить тело ошибки, если оно есть и это JSON
      String detail = response.reasonPhrase ?? 'Unknown error';
      try {
        final errorData = jsonDecode(response.body);
        if (errorData != null &&
            errorData is Map &&
            errorData['detail'] != null) {
          detail = errorData['detail'];
        }
      } catch (e) {
        // Игнорируем ошибку парсинга JSON, используем reasonPhrase или тело ответа, если оно не пустое
        if (response.body.isNotEmpty) {
          detail = response.body;
        }
      }
      throw Exception('Ошибка получения профиля: $detail');
    }
  }

  Future<Map<String, dynamic>> updateMyProfile(
      Map<String, dynamic> profileData) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/profile'), // только /profile!
      headers: await _getHeaders(),
      body: jsonEncode(profileData),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      if (response.statusCode == 401) {
        throw Exception('Сессия истекла. Пожалуйста, войдите снова.');
      }
      if (response.statusCode == 403) {
        throw Exception('Forbidden: нет прав на изменение этого профиля.');
      }
      String detail = response.reasonPhrase ?? 'Unknown error';
      try {
        final errorData = jsonDecode(response.body);
        if (errorData != null &&
            errorData is Map &&
            errorData['detail'] != null) {
          detail = errorData['detail'];
        }
      } catch (e) {
        if (response.body.isNotEmpty) {
          detail = response.body;
        }
      }
      throw Exception('Ошибка обновления профиля: $detail');
    }
  }

  Future<List<dynamic>> getGroups() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/groups'),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(
          'Ошибка получения групп: ${errorData['detail'] ?? response.reasonPhrase}');
    }
  }

  Future<List<dynamic>> getTeachers() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/teachers'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception(
            'Failed to load teachers. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching teachers: $e');
      throw Exception('Failed to load teachers: $e');
    }
  }

  Future<List<dynamic>> getStudents() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/students'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception(
            'Failed to load students. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching students: $e');
      throw Exception('Failed to load students: $e');
    }
  }

  Future<List<dynamic>> getMyLessons() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/lessons/'),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(
          'Ошибка получения расписания: ${errorData['detail'] ?? response.reasonPhrase}');
    }
  }

  // Методы для получения расписания по ID студента или преподавателя (если нужны админу)
  Future<List<dynamic>> getStudentLessons(int studentId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/lesson/student/$studentId'),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(
          'Ошибка расписания для студента $studentId: ${errorData['detail'] ?? response.reasonPhrase}');
    }
  }

  Future<List<dynamic>> getTeacherLessons(int teacherId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/lesson/teacher/$teacherId'),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(
          'Ошибка расписания для преподавателя $teacherId: ${errorData['detail'] ?? response.reasonPhrase}');
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await _getToken();
    return token != null;
  }

  // Новый универсальный метод POST
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body,
      {bool includeAuth = true}) async {
    final response = await http.post(
      Uri.parse('$_baseUrl$endpoint'),
      headers: await _getHeaders(includeAuth: includeAuth),
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(
          'Ошибка POST $endpoint: ${errorData['detail'] ?? response.reasonPhrase}');
    }
  }
}
