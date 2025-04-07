from sqlalchemy import Column, Integer, String, ForeignKey, Enum, DateTime
from database import Base
import enum

class LessonType(str, enum.Enum):
    lecture = "lecture"
    practice = "practice"

class Room(Base):
    __tablename__ = "room"
    id = Column(Integer, primary_key=True)
    room_number = Column(String)
    floor = Column(Integer)

class StudentGroup(Base):
    __tablename__ = "student_group"
    id = Column(Integer, primary_key=True)
    name = Column(String)

class Lesson(Base):
    __tablename__ = "lesson"
    id = Column(Integer, primary_key=True)
    course_name = Column(String)
    teacher_id = Column(Integer)
    group_id = Column(Integer, ForeignKey("student_group.id"))
    start_time = Column(DateTime)
    end_time = Column(DateTime)
    room_id = Column(Integer, ForeignKey("room.id"))
    lesson_type = Column(Enum(LessonType))
