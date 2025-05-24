from pydantic import BaseModel
from typing import Optional
from datetime import datetime
import enum

from yarsu_python_micro.schedule_service.models import StudentGroup


class LessonType(str, enum.Enum):
    lecture = "lecture"
    practice = "practice"

class GroupCreate(StudentGroup):
    name: str
class LessonCreate(BaseModel):
    course_name: str
    teacher_id: int
    group_name: str
    start_time: datetime
    end_time: datetime
    room_id: int
    lesson_type: LessonType

class LessonUpdate(BaseModel):
    course_name: Optional[str]
    teacher_id: Optional[int]
    group_name: Optional[str]
    start_time: Optional[datetime]
    end_time: Optional[datetime]
    room_id: Optional[int]
    lesson_type: Optional[LessonType]

class LessonOut(BaseModel):
    id: int
    course_name: str
    teacher_id: int
    group_name: str
    start_time: datetime
    end_time: datetime
    room_id: int
    lesson_type: LessonType

    class Config:
        orm_mode = True

