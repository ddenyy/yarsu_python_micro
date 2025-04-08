from pydantic import BaseModel, EmailStr, Field, validator
from typing import Optional
from datetime import date, datetime


class UserProfileBase(BaseModel):
    name: str = Field(..., max_length=15)
    second_name: str = Field(..., max_length=20)
    email: EmailStr
    date_of_brthd: date
    phone_number: Optional[str] = None
    course: int
    group: str
    is_teacher: Optional[bool] = False
    is_student: Optional[bool] = False
    is_admin: Optional[bool] = False


class UserProfileCreate(UserProfileBase):
    pass


class UserProfileRead(UserProfileBase):
    id: int
    created_at: Optional[date]
    updated_at: Optional[date]
    shard_number: int

    class Config:
        orm_mode = True


class UserMetadataRead(BaseModel):
    id: int
    shard_number: int
    user_count: int

    class Config:
        orm_mode = True
