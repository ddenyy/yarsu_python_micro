from datetime import datetime
from sqlalchemy.orm import Mapped, relationship
from sqlalchemy.orm import mapped_column
from sqlalchemy import String
from sqlalchemy import Date
from sqlalchemy import ForeignKey
from typing import Optional, List
from .database import Base


class Group(Base):
    __tablename__ = "Groups"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    name: Mapped[str] = mapped_column(String(50), unique=True)
    description: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)

    users: Mapped[List["User_Profile"]] = relationship("User_Profile", back_populates="group")

class User_Profile(Base):
    __tablename__ = "Users_profile"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True, unique=True)
    name: Mapped[str] = mapped_column(String(15))
    second_name: Mapped[str] = mapped_column(String(20))
    email: Mapped[str] = mapped_column(String)
    date_of_brthd: Mapped[datetime] = mapped_column(Date)
    phone_number: Mapped[Optional[str]] = mapped_column(String)
    created_at: Mapped[Optional[datetime]] = mapped_column(Date)
    updated_at: Mapped[Optional[datetime]] = mapped_column(Date)
    shard_number: Mapped[int] = mapped_column(autoincrement=True, unique=True)
    course: Mapped[int] = mapped_column()
    group_id: Mapped[Optional[int]] = mapped_column(ForeignKey("Groups.id"))
    is_teacher: Mapped[bool] = mapped_column(server_default="false")
    is_student: Mapped[bool] = mapped_column(server_default="false")
    is_admin: Mapped[bool] = mapped_column(server_default="false")

    group: Mapped[Optional[Group]] = relationship("Group", back_populates="users")


class Users_metadata(Base):
    __tablename__ = "Users_metadata"

    id: Mapped[int] = mapped_column(primary_key=True)
    shard_number: Mapped[int] = mapped_column(ForeignKey("Users_profile.shard_number"))
    user_count: Mapped[int] = mapped_column()