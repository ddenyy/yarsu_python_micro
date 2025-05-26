import 'package:flutter/material.dart';
import '../api_service.dart';

class StudentsScreen extends StatefulWidget {
  final ApiService apiService;

  const StudentsScreen({required this.apiService, Key? key}) : super(key: key);

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  List<dynamic> _allStudents = []; // Будет хранить всех загруженных студентов
  List<dynamic> _filteredStudents =
      []; // Будет хранить отфильтрованных студентов для отображения
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStudents();
    _searchController.addListener(_filterStudents);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterStudents);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // ПРЕДПОЛОЖЕНИЕ: в ApiService должен быть метод getStudents()
      final students = await widget.apiService.getStudents();
      setState(() {
        _allStudents = students;
        _filteredStudents = students; // Изначально показываем всех
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterStudents() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredStudents = _allStudents.where((student) {
        final name = student['name']?.toString().toLowerCase() ?? '';
        final secondName =
            student['second_name']?.toString().toLowerCase() ?? '';
        // Можно добавить поиск по другим полям, если нужно, например, по email или группе
        return name.contains(query) || secondName.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Студенты'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Поиск',
                hintText: 'Введите имя или фамилию...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('Произошла ошибка: $_errorMessage',
                            style: const TextStyle(color: Colors.red)),
                      ))
                    : _filteredStudents.isEmpty
                        ? Center(
                            child: Text(_searchController.text.isNotEmpty
                                ? 'Студенты не найдены'
                                : 'Список студентов пуст'),
                          )
                        : ListView.builder(
                            itemCount: _filteredStudents.length,
                            itemBuilder: (context, index) {
                              final student = _filteredStudents[index];
                              final name = student['name']?.toString() ??
                                  'Имя не указано';
                              final secondName =
                                  student['second_name']?.toString() ??
                                      'Фамилия не указана';
                              final email = student['email']?.toString() ??
                                  'Email не указан';
                              final studentId =
                                  student['id']?.toString() ?? 'N/A';
                              // Можно добавить отображение группы, если оно есть в данных
                              // final groupName = student['group_name']?.toString() ?? 'Группа не указана';

                              return ListTile(
                                leading: CircleAvatar(
                                  child: Text(studentId),
                                ),
                                title: Text(name),
                                subtitle: Text(secondName),
                                // trailing: Text(email), // Можно оставить email или отобразить группу
                                trailing: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(email),
                                    // if (student['group_name'] != null) Text(groupName, style: TextStyle(fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
