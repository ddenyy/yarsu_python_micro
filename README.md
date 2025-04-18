
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


