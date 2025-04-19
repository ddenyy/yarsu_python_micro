POST /lesson/ ----Создание нового занятия.
Возвращает: созданное занятие с id.
Ожидаемый JSON:
{
  "course_name": "Mathematics",
  "teacher_id": 12,
  "group_name": "B21-50",
  "start_time": "2025-04-20T10:00:00",
  "end_time": "2025-04-20T11:30:00",
  "room_id": 3,
  "lesson_type": "lecture"
}
Пример ответа:
{
  "id": 7,
  "course_name": "Mathematics",
  "teacher_id": 12,
  "group_name": "B21-50",
  "start_time": "2025-04-20T10:00:00",
  "end_time": "2025-04-20T11:30:00",
  "room_id": 3,
  "lesson_type": "lecture"
}

GET /lesson/?teacher_id={id} ----Получение всех занятий по teacher_id.
Пример запроса: GET /lesson/?teacher_id=12
Возвращает: список занятий, преподаваемых указанным преподавателем.

GET /lesson/?student_id={id} ----Получение всех занятий, назначенных для группы, в которой состоит студент с student_id.
Пример запроса: GET /lesson/?student_id=45
Возвращает: список занятий для группы студента.

PATCH /lesson/{lesson_id} ----Обновление информации о занятии.
Возвращает: обновлённое занятие.
Ожидаемый JSON (только поля, которые нужно изменить):
{
  "course_name": "Physics",
  "start_time": "2025-04-21T12:00:00"
}
Пример запроса: PATCH /lesson/7

DELETE /lesson/{lesson_id} ----Удаление занятия по его id.
Пример запроса: DELETE /lesson/7
Возвращает: удалённое занятие.
