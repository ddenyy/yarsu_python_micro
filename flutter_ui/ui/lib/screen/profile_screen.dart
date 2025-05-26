import 'package:flutter/material.dart';
import 'package:ui/screen/edit_screen.dart';
import '../api_service.dart';

class ProfileScreen extends StatefulWidget {
  final ApiService apiService;

  const ProfileScreen({required this.apiService, super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final data = await widget.apiService.getMyProfile();
      setState(() {
        _profileData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Widget _buildProfileDetail(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$title: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value ?? 'Не указано')),
        ],
      ),
    );
  }

  Future<void> _editProfile() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          apiService: widget.apiService,
          profileData: _profileData!,
        ),
      ),
    );

    if (result == true) {
      await _loadProfile(); // Заново загрузи профиль из API
      setState(() {}); // Обнови UI
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Мой профиль')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Text('Ошибка: $_errorMessage',
                      style: const TextStyle(color: Colors.red)))
              : _profileData == null
                  ? const Center(child: Text('Не удалось загрузить профиль.'))
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ListView(
                        children: <Widget>[
                          _buildProfileDetail(
                              'ID',
                              _profileData!['id']?.toString() ??
                                  _profileData!['user_id']?.toString()),
                          _buildProfileDetail(
                              'Email', _profileData!['email']?.toString()),
                          _buildProfileDetail(
                              'Имя', _profileData!['name']?.toString()),
                          _buildProfileDetail('Фамилия',
                              _profileData!['second_name']?.toString()),
                          _buildProfileDetail('Дата рождения',
                              _profileData!['date_of_brthd']?.toString()),
                          _buildProfileDetail('Телефон',
                              _profileData!['phone_number']?.toString()),
                          _buildProfileDetail(
                              'Курс', _profileData!['course']?.toString()),
                          _buildProfileDetail(
                              'Преподаватель',
                              (_profileData!['is_teacher'] == true
                                  ? 'Да'
                                  : 'Нет')),
                          _buildProfileDetail(
                              'Администратор',
                              (_profileData!['is_admin'] == true
                                  ? 'Да'
                                  : 'Нет')),
                          if (_profileData!['is_teacher'] == false &&
                              _profileData!['group_name'] != null)
                            _buildProfileDetail('Название группы',
                                _profileData!['group_name']?.toString()),
                          if (_profileData!['is_teacher'] == false &&
                              _profileData!['group_name'] != null)
                            _buildProfileDetail('Название группы',
                                _profileData!['group_name']?.toString()),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _editProfile,
                            child: const Text('Редактировать профиль'),
                          ),
                          // TODO: Добавить кнопку для редактирования профиля
                        ],
                      ),
                    ),
    );
  }
}
