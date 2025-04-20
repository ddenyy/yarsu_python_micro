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

1) POST /profile
Создание нового профиля пользователя после регистрации (получает id и email от сервиса авторизации).
ожидаемый json: {
  "id": 1,
  "email": "user@example.com"
}

2) PUT /profile/{user_id}
Обновление профиля пользователя — ФИО, номер телефона, группа и т.д.
ожидаемый json: {
  "name": "Ivan",
  "second_name": "Petrov",
  "phone_number": "+79998887766",
  "course": 3,
  "group_id": 2,
  "is_student": true
}

3)  GET /students
Возвращает список всех студентов.

4) GET /teachers
Возвращает список всех преподавателей

5) GET /groups
Возвращает список всех уникальных названий групп

6) GET /groups/{group_id}/students (GET /groups/2/students)
Возвращает список студентов, принадлежащих к конкретной группе по group_id.

7) GET /teachers/{teacher_id}
Возвращает преподавателя по его id.

8) GET /students/{student_id}
Возвращает конкретного студенита по его id


