from typing import Optional

from sqlalchemy import Column, Integer, String, ForeignKey, Enum, DateTime
from sqlalchemy.orm import Mapped, mapped_column

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

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    name: Mapped[str] = mapped_column(String(50), unique=True)
    description: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)

class Lesson(Base):
    __tablename__ = "lesson"
    id = Column(Integer, primary_key=True)
    course_name = Column(String)
    teacher_id = Column(Integer, nullable=True)
    group_name = Column(String, ForeignKey("student_group.name"))
    start_time = Column(DateTime)
    end_time = Column(DateTime)
    room_id = Column(Integer, ForeignKey("room.id"), nullable=True)
    lesson_type = Column(Enum(LessonType))
