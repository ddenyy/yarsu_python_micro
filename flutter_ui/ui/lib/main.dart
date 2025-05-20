import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:ui/screens/auth_or_login_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthScreen(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool isTeacher = true; // Replace with real auth check
  bool isEditing = false;

  List<Map<String, dynamic>> lessons = [];

  List<String> times = [
    '09:00 - 10:30',
    '10:45 - 12:15',
    '13:00 - 14:30',
  ];

  Map<String, List<String>> schedule = {
    'Monday': ['Math', 'Physics', ''],
    'Tuesday': ['Chemistry', '', 'Biology'],
    'Wednesday': ['Lecture', 'Lab', ''],
    'Thursday': ['Lab', '', 'Seminar'],
    'Friday': ['', 'History', ''],
  };

  Map<String, TextEditingController> controllers = {};

  @override
  void initState() {
    super.initState();
    schedule.forEach((day, subjects) {
      for (var i = 0; i < subjects.length; i++) {
        controllers['$day\$i'] = TextEditingController(text: subjects[i]);
      }
    });
  }

  Future<void> fetchLessonsForTeacher(int teacherId) async {
    final url = Uri.parse('http://10.0.2.2:8000/lesson/?teacher_id=$teacherId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          lessons = data.cast<Map<String, dynamic>>();
        });
      } else {
        throw Exception('Ошибка: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка при получении занятий: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Расписание'),
        actions: isTeacher
            ? [
                if (!isEditing)
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => setState(() => isEditing = true),
                  ),
              ]
            : null,
      ),
      body: Row(
        children: [
          // Профиль
          Container(
            width: 250,
            color: Colors.white,
            padding: EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        NetworkImage('https://via.placeholder.com/100'),
                  ),
                  SizedBox(height: 16),
                  Text('Имя Фамилия',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(isTeacher ? 'Преподаватель' : 'Студент',
                      style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      fetchLessonsForTeacher(12); // ID преподавателя
                    },
                    child: Text('Запросить расписание'),
                  ),
                  SizedBox(height: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ID: 123456'),
                      Text('Email: user@example.com'),
                      Text('Факультет: Информатика'),
                    ],
                  ),
                  if (lessons.isNotEmpty) ...[
                    SizedBox(height: 24),
                    Text('Занятия:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    ...lessons.map((lesson) => ListTile(
                          title: Text(
                              '${lesson["course_name"]} (${lesson["lesson_type"]})'),
                          subtitle: Text(
                              '${lesson["group_name"]} | ${lesson["start_time"]} - ${lesson["end_time"]}'),
                        )),
                  ]
                ],
              ),
            ),
          ),

          VerticalDivider(width: 1),

          // Расписание
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: isEditing ? buildEditForm() : buildScheduleTable(),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildScheduleTable() {
    return SingleChildScrollView(
      child: DataTable(
        columns: [
          DataColumn(label: Text('Время')),
          ...schedule.keys.map((day) => DataColumn(label: Text(day))).toList(),
        ],
        rows: List.generate(times.length, (rowIndex) {
          return DataRow(cells: [
            DataCell(Text(times[rowIndex])),
            ...schedule.keys.map((day) {
              return DataCell(Text(schedule[day]![rowIndex]));
            }).toList(),
          ]);
        }),
      ),
    );
  }

  Widget buildEditForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Редактировать расписание',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 16),
        Expanded(
          child: ListView(
            children: schedule.keys.map((day) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(day, style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    ...List.generate(times.length, (i) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: TextField(
                          controller: controllers['$day\$i'],
                          decoration: InputDecoration(
                            labelText: times[i],
                            border: OutlineInputBorder(),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  schedule.forEach((day, subjects) {
                    for (var i = 0; i < subjects.length; i++) {
                      subjects[i] = controllers['$day\$i']!.text;
                    }
                  });
                  isEditing = false;
                });
              },
              child: Text('Сохранить'),
            ),
            SizedBox(width: 16),
            TextButton(
              onPressed: () => setState(() => isEditing = false),
              child: Text('Отменить'),
            ),
          ],
        ),
      ],
    );
  }
}
