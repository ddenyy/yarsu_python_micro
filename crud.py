from sqlalchemy.orm import Session
from models import Lesson
import schemas

def create_lesson(db: Session, lesson: schemas.LessonCreate):
    db_lesson = Lesson(**lesson.dict())
    db.add(db_lesson)
    db.commit()
    db.refresh(db_lesson)
    return db_lesson

def get_lessons_by_teacher(db: Session, teacher_id: int):
    return db.query(Lesson).filter(Lesson.teacher_id == teacher_id).all()

def get_lessons_by_student(db: Session, student_id: int):
    # Получение группы студента — через внешний микросервис (заглушка)
    group_id = get_group_id_by_student(student_id)
    return db.query(Lesson).filter(Lesson.group_id == group_id).all()

def update_lesson(db: Session, lesson_id: int, updates: schemas.LessonUpdate):
    lesson = db.query(Lesson).filter(Lesson.id == lesson_id).first()
    if not lesson:
        return None
    for field, value in updates.dict(exclude_unset=True).items():
        setattr(lesson, field, value)
    db.commit()
    db.refresh(lesson)
    return lesson

def delete_lesson(db: Session, lesson_id: int):
    lesson = db.query(Lesson).filter(Lesson.id == lesson_id).first()
    if not lesson:
        return None
    db.delete(lesson)
    db.commit()
    return lesson

# Заглушка функции запроса во внешний сервис
def get_group_id_by_student(student_id: int) -> int:
    mock_students = {
        1: 1,
        2: 1,
        3: 2
    }
    return mock_students.get(student_id)
