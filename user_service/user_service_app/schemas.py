from pydantic import BaseModel, EmailStr, Field, validator
from typing import Optional
from datetime import date, datetime


class UserProfileCreate(BaseModel):
    id: int
    email: EmailStr

class GroupCreate(BaseModel):
    name: str
    description: Optional[str] = None

class Group(BaseModel):
    name: str
    id: int
    descrption: Optional[str] = None


class UserProfileUpdate(BaseModel):
    name: Optional[str] = None
    second_name: Optional[str] = None
    date_of_brthd: Optional[date] = None
    phone_number: Optional[str] = None
    course: Optional[int] = None
    group_name: Optional[str] = None
    is_teacher: Optional[bool] = None
    is_student: Optional[bool] = None

class UserProfile(BaseModel):
    id: int
    created_at: Optional[date]
    updated_at: Optional[date]
    shard_number: int

    class Config:
        orm_mode = True


class UserMetadata(BaseModel):
    id: int
    shard_number: int
    user_count: int

    class Config:
        orm_mode = True
