from datetime import datetime
from sqlalchemy.orm import Mapped, relationship, mapped_column
from sqlalchemy import String, Date, ForeignKey, Boolean, Integer
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
    
    email: Mapped[str] = mapped_column(String, nullable=False, unique=True)

    name: Mapped[Optional[str]] = mapped_column(String(15), nullable=True)
    second_name: Mapped[Optional[str]] = mapped_column(String(20), nullable=True)
    date_of_brthd: Mapped[Optional[datetime]] = mapped_column(Date, nullable=True)
    phone_number: Mapped[Optional[str]] = mapped_column(String, nullable=True)

    created_at: Mapped[datetime] = mapped_column(Date, default=datetime.utcnow)
    updated_at: Mapped[Optional[datetime]] = mapped_column(Date, nullable=True)

    shard_number: Mapped[Optional[int]] = mapped_column(Integer, unique=True, nullable=True)
    course: Mapped[Optional[int]] = mapped_column(Integer, nullable=True)
    group_id: Mapped[Optional[int]] = mapped_column(ForeignKey("Groups.id"), nullable=True)

    is_teacher: Mapped[bool] = mapped_column(Boolean, server_default="false")
    is_student: Mapped[bool] = mapped_column(Boolean, server_default="false")
    is_admin: Mapped[bool] = mapped_column(Boolean, server_default="false")

    group: Mapped[Optional[Group]] = relationship("Group", back_populates="users")


class Users_metadata(Base):
    __tablename__ = "Users_metadata"

    id: Mapped[int] = mapped_column(primary_key=True)
    shard_number: Mapped[int] = mapped_column(ForeignKey("Users_profile.shard_number"))
    user_count: Mapped[int] = mapped_column()
