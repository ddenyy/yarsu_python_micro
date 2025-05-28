from sqlalchemy.orm import Session
import schemas
import os
import requests

from models import StudentGroup, Lesson, Room


def create_group(db: Session, group: schemas.GroupCreate):
    db_group = StudentGroup(**group.dict())
    db.add(db_group)
    db.commit()
    db.refresh(db_group)
    return db_group

def create_lesson(db: Session, lesson: schemas.LessonCreate):
    db_lesson = Lesson(**lesson.dict())
    db.add(db_lesson)
    db.commit()
    db.refresh(db_lesson)
    return db_lesson

def get_lessons_by_teacher(db: Session, teacher_id: int):
    return db.query(Lesson).filter(Lesson.teacher_id == teacher_id).all()


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


USER_SERVICE_URL = os.getenv("USER_SERVICE_URL", "http://user_service:8000/")

def get_group_name_by_student(student_id: int) -> str:
    try:
        response = requests.get(f"{USER_SERVICE_URL}/profile/{student_id}")
        response.raise_for_status()
        student_data = response.json()
        return student_data["group"]
    except requests.RequestException:
        return None


def get_lessons_by_student(db: Session, student_id: int):
    group_name = get_group_name_by_student(student_id)
    return db.query(Lesson).join(StudentGroup).filter(StudentGroup.name == group_name).all()


def get_group_by_name(db: Session, name: str):
    return db.query(StudentGroup).filter(StudentGroup.name == name).first()

def create_room(db: Session, room: schemas.RoomCreate):
    db_room = Room(**room.dict())
    db.add(db_room)
    db.commit()
    db.refresh(db_room)
    return db_room

def get_room_by_number(db: Session, number: str):
    return db.query(Room).filter(Room.room_number == number).first()