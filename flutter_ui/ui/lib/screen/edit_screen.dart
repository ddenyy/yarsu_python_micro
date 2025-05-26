import 'package:flutter/material.dart';
import '../api_service.dart';

class EditProfileScreen extends StatefulWidget {
  final ApiService apiService;
  final Map<String, dynamic> profileData;

  const EditProfileScreen({
    Key? key,
    required this.apiService,
    required this.profileData,
  }) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _secondNameController;
  late TextEditingController _dateOfBirthController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _courseController;
  late TextEditingController _groupNameController;
  bool _isStudent = false;
  bool _isTeacher = false;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.profileData['name'] ?? '');
    _secondNameController =
        TextEditingController(text: widget.profileData['second_name'] ?? '');
    _dateOfBirthController =
        TextEditingController(text: widget.profileData['date_of_brthd'] ?? '');
    _phoneNumberController =
        TextEditingController(text: widget.profileData['phone_number'] ?? '');
    _courseController = TextEditingController(
        text: widget.profileData['course']?.toString() ?? '');
    _groupNameController = TextEditingController(
        text: widget.profileData['group_name']?.toString() ?? '');
    _isStudent = widget.profileData['is_student'] ?? false;
    _isTeacher = widget.profileData['is_teacher'] ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _secondNameController.dispose();
    _dateOfBirthController.dispose();
    _phoneNumberController.dispose();
    _courseController.dispose();
    _groupNameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final updatedData = {
      'name': _nameController.text.trim(),
      'second_name': _secondNameController.text.trim(),
      'date_of_brthd': _dateOfBirthController.text.trim(),
      'phone_number': _phoneNumberController.text.trim(),
      'course': _courseController.text.trim(),
      'group_name': _groupNameController.text.trim(),
      'is_student': _isStudent,
      'is_teacher': _isTeacher,
    };

    try {
      await widget.apiService.updateMyProfile(updatedData);
      if (mounted) {
        Navigator.of(context).pop(
            true); // Возвращаем true, чтобы обновить профиль на предыдущем экране
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Редактировать профиль')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: widget.profileData['email'] ?? '',
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      enabled: false,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Имя',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Введите имя' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _secondNameController,
                      decoration: const InputDecoration(
                        labelText: 'Фамилия',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Введите фамилию'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _dateOfBirthController,
                      decoration: const InputDecoration(
                        labelText: 'Дата рождения',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Введите дату рождения'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Телефон',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _courseController,
                      decoration: const InputDecoration(
                        labelText: 'Курс',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _groupNameController,
                      decoration: const InputDecoration(
                        labelText: 'Название группы',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Студент'),
                      value: _isStudent,
                      onChanged: (val) => setState(() => _isStudent = val),
                    ),
                    SwitchListTile(
                      title: const Text('Преподаватель'),
                      value: _isTeacher,
                      onChanged: (val) => setState(() => _isTeacher = val),
                    ),
                    const SizedBox(height: 24),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      child: const Text('Сохранить изменения'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
