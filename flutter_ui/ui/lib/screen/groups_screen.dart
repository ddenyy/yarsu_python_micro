import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../api_service.dart'; // Убедитесь, что путь к ApiService корректен

class GroupsScreen extends StatefulWidget {
  final ApiService apiService;

  const GroupsScreen({required this.apiService, Key? key}) : super(key: key);

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  List<dynamic> _groups = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data = await widget.apiService.getGroups();
      setState(() {
        _groups = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      print("Ошибка при загрузке групп: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Список групп'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Произошла ошибка: $_errorMessage',
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : _groups.isEmpty
                  ? const Center(
                      child: Text(
                        'Группы не найдены.',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: _groups.length,
                      itemBuilder: (context, index) {
                        final group = _groups[index] as Map<String, dynamic>;
                        final groupName =
                            group['name']?.toString() ?? 'Без названия';
                        final groupId = group['id']?.toString() ?? 'N/A';
                        final groupDescription =
                            group['description']?.toString() ?? 'Нет описания';

                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(
                              vertical: 6.0, horizontal: 8.0),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16.0),
                            leading: CircleAvatar(
                              child: Text(groupId),
                            ),
                            title: Text(
                              groupName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Text(
                              groupDescription,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                            // Можно добавить onTap для перехода к деталям группы или к ее расписанию
                            // onTap: () {
                            //   // TODO: Реализовать навигацию или действие
                            //   print('Нажата группа: $groupName (ID: $groupId)');
                            // },
                          ),
                        );
                      },
                    ),
    );
  }
}
