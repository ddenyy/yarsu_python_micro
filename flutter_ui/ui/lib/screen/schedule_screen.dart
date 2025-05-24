import 'package:flutter/material.dart';
import '../api_service.dart';
import 'package:intl/intl.dart'; // Для форматирования дат

class ScheduleScreen extends StatefulWidget {
  final ApiService apiService; // Добавляем ApiService

  // Обновляем конструктор
  const ScheduleScreen({required this.apiService, super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  // ApiService будет получен из widget.apiService
  // final ApiService _apiService = ApiService();
  List<dynamic> _lessons = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  Future<void> _loadLessons() async {
    setState(() => _isLoading = true);
    try {
      // Используем widget.apiService
      final data = await widget.apiService.getMyLessons();
      setState(() {
        _lessons = data;
        _isLoading = false;
      });
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
      appBar: AppBar(title: const Text('Мое расписание')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Text('Ошибка: $_errorMessage',
                      style: const TextStyle(color: Colors.red)))
              : _lessons.isEmpty
                  ? const Center(child: Text('Нет занятий для отображения.'))
                  : ListView.builder(
                      itemCount: _lessons.length,
                      itemBuilder: (context, index) {
                        final lesson = _lessons[index]
                            as Map<String, dynamic>; // Убедимся, что это Map
                        // Парсинг времени, если оно приходит как строка
                        // Предположим, что API возвращает время в формате ISO 8601 или HH:mm:ss
                        String startTime =
                            lesson['start_time']?.toString() ?? 'N/A';
                        String endTime =
                            lesson['end_time']?.toString() ?? 'N/A';
                        String lessonDate = 'N/A';

                        try {
                          // Если start_time это полная дата-время строка
                          final dtStart =
                              DateTime.tryParse(lesson['start_time']);
                          if (dtStart != null) {
                            lessonDate =
                                DateFormat('dd.MM.yyyy').format(dtStart);
                            startTime = DateFormat('HH:mm').format(dtStart);
                          }
                          final dtEnd = DateTime.tryParse(lesson['end_time']);
                          if (dtEnd != null) {
                            endTime = DateFormat('HH:mm').format(dtEnd);
                          }
                        } catch (e) {
                          // Оставляем как есть, если парсинг не удался
                        }

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          child: ListTile(
                            title: Text(
                                '${lesson['course_name']} (${lesson['lesson_type']})'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Дата: $lessonDate'),
                                Text('Время: $startTime - $endTime'),
                                if (lesson['classroom'] != null)
                                  Text('Аудитория: ${lesson['classroom']}'),
                                if (lesson['group_name'] != null)
                                  Text('Группа: ${lesson['group_name']}'),
                                if (lesson['teacher_name'] != null)
                                  Text(
                                      'Преподаватель: ${lesson['teacher_name']}'),
                              ],
                            ),
                            // TODO: Добавить возможность редактирования/удаления для преподавателя/админа
                          ),
                        );
                      },
                    ),
    );
  }
}
