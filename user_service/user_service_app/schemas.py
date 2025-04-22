from pydantic import BaseModel, EmailStr, Field, validator
from typing import Optional
from datetime import date, datetime


class UserProfileCreate(BaseModel):
    id: int
    email: EmailStr

class GroupCreate(BaseModel):
    name: str
    description: Optional[str] = None


class UserProfileUpdate(BaseModel):
    name: Optional[str]
    second_name: Optional[str]
    date_of_birth: Optional[date]
    phone_number: Optional[str]
    course: Optional[int]
    group_id: Optional[int]
    is_teacher: Optional[bool]
    is_student: Optional[bool]

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
