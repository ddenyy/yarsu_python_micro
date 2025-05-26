import 'package:flutter/material.dart';
import 'package:ui/screen/Groups_screen.dart';
import 'package:ui/screen/students_screen.dart';
import 'package:ui/screen/teachers_screen.dart';
import '../api_service.dart';
import 'login_screen.dart';
import 'profile_screen.dart'; // Создадим
import 'schedule_screen.dart'; // Создадим

class HomeScreen extends StatefulWidget {
  final ApiService apiService; // Добавляем ApiService

  // Обновляем конструктор
  const HomeScreen({required this.apiService, super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ApiService будет получен из widget.apiService
  // final ApiService _apiService = ApiService();
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // Используем widget.apiService
      final profile = await widget.apiService.getMyProfile();
      setState(() {
        _userProfile = profile;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        if (e.toString().contains('Сессия истекла')) {
          // Передаем apiService в LoginScreen
          _logout(navigateToLogin: true);
        }
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _logout({bool navigateToLogin = true}) async {
    // Используем widget.apiService
    await widget.apiService.logout();
    if (mounted && navigateToLogin) {
      Navigator.of(context).pushAndRemoveUntil(
        // Передаем apiService в LoginScreen
        MaterialPageRoute(
            builder: (context) => LoginScreen(apiService: widget.apiService)),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Главная'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            // Убедимся, что _logout вызывается без аргументов по умолчанию или с navigateToLogin: true
            onPressed: () => _logout(navigateToLogin: true),
            tooltip: 'Выйти',
          ),
        ],
      ),
      drawer: _buildDrawer(), // Боковое меню
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Ошибка: $_errorMessage',
                      style: const TextStyle(color: Colors.red)),
                ))
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Добро пожаловать, ${_userProfile?['first_name'] ?? _userProfile?['email'] ?? 'Пользователь'}!',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              // TODO: ProfileScreen должен будет принимать apiService
                              builder: (context) => ProfileScreen(
                                  apiService: widget.apiService)));
                        },
                        child: const Text('Мой профиль'),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              // TODO: ScheduleScreen должен будет принимать apiService
                              builder: (context) => ScheduleScreen(
                                  apiService: widget.apiService)));
                        },
                        child: const Text('Мое расписание'),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  GroupsScreen(apiService: widget.apiService)));
                        },
                        child: const Text('Группы'),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => TeachersScreen(
                                  apiService: widget.apiService)));
                        },
                        child: const Text('Преподаватели'),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => StudentsScreen(
                                  apiService: widget.apiService)));
                        },
                        child: const Text('Студенты'),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(_userProfile?['first_name'] != null &&
                    _userProfile?['last_name'] != null
                ? '${_userProfile!['first_name']} ${_userProfile!['last_name']}'
                : _userProfile?['email'] ?? 'Загрузка...'),
            accountEmail: Text(_userProfile?['email'] ?? '...'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                _userProfile?['first_name']?.substring(0, 1).toUpperCase() ??
                    '?',
                style: const TextStyle(fontSize: 40.0),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Главная'),
            onTap: () {
              Navigator.pop(context); // Закрыть drawer
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Профиль'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                  // TODO: ProfileScreen должен будет принимать apiService
                  builder: (context) =>
                      ProfileScreen(apiService: widget.apiService)));
            },
          ),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('Расписание'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                  // TODO: ScheduleScreen должен будет принимать apiService
                  builder: (context) =>
                      ScheduleScreen(apiService: widget.apiService)));
            },
          ),
          // TODO: Добавить другие пункты меню (Группы, Студенты, Преподаватели и т.д. в зависимости от роли)
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Выйти'),
            // Убедимся, что _logout вызывается без аргументов по умолчанию или с navigateToLogin: true
            onTap: () => _logout(navigateToLogin: true),
          ),
        ],
      ),
    );
  }
}
