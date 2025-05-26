import 'package:flutter/material.dart';
import '../api_service.dart';

class TeachersScreen extends StatefulWidget {
  final ApiService apiService;

  const TeachersScreen({required this.apiService, Key? key}) : super(key: key);

  @override
  State<TeachersScreen> createState() => _TeachersScreenState();
}

class _TeachersScreenState extends State<TeachersScreen> {
  List<dynamic> _allTeachers =
      []; // Будет хранить всех загруженных преподавателей
  List<dynamic> _filteredTeachers =
      []; // Будет хранить отфильтрованных преподавателей для отображения
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTeachers();
    _searchController.addListener(_filterTeachers);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterTeachers);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTeachers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final teachers = await widget.apiService.getTeachers();
      setState(() {
        _allTeachers = teachers;
        _filteredTeachers = teachers; // Изначально показываем всех
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterTeachers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredTeachers = _allTeachers.where((teacher) {
        final name = teacher['name']?.toString().toLowerCase() ?? '';
        final secondName =
            teacher['second_name']?.toString().toLowerCase() ?? '';
        return name.contains(query) || secondName.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Преподаватели'),
        // Можно добавить поле поиска прямо в AppBar, если хотите
        // bottom: PreferredSize(
        //   preferredSize: Size.fromHeight(kToolbarHeight),
        //   child: Padding(
        //     padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        //     child: TextField(
        //       controller: _searchController,
        //       decoration: InputDecoration(
        //         hintText: 'Поиск по имени/фамилии...',
        //         border: OutlineInputBorder(),
        //         filled: true,
        //         fillColor: Colors.white,
        //         prefixIcon: Icon(Icons.search),
        //       ),
        //     ),
        //   ),
        // ),
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
                // Кнопка для очистки поля поиска
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          // _filterTeachers(); // Вызовется автоматически через listener
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
                    ? Center(child: Text(_errorMessage!))
                    : _filteredTeachers.isEmpty
                        ? Center(
                            child: Text(_searchController.text.isNotEmpty
                                ? 'Преподаватели не найдены'
                                : 'Список преподавателей пуст'),
                          )
                        : ListView.builder(
                            itemCount: _filteredTeachers.length,
                            itemBuilder: (context, index) {
                              final teacher = _filteredTeachers[index];
                              final name = teacher['name']?.toString() ??
                                  'Имя не указано';
                              final secondName =
                                  teacher['second_name']?.toString() ??
                                      'Фамилия не указана';
                              final email = teacher['email']?.toString() ??
                                  'Email не указан';
                              final teacherId =
                                  teacher['id']?.toString() ?? 'N/A';

                              return ListTile(
                                leading: CircleAvatar(
                                  child: Text(teacherId),
                                ),
                                title: Text(name),
                                subtitle: Text(secondName),
                                trailing: Text(email),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
