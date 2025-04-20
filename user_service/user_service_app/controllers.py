from fastapi import HTTPException
from sqlalchemy.orm import Session
from datetime import date
from . import models, schemas


class UserController:

    @staticmethod
    def validate_user_data(user_data: schemas.UserProfileCreate):
        if user_data.date_of_brthd > date.today():
            raise HTTPException(status_code=400, detail="Birth date cannot be in the future.")

        if user_data.course < 1 or user_data.course > 6:
            raise HTTPException(status_code=400, detail="Course must be between 1 and 6.")

        roles = [user_data.is_student, user_data.is_teacher, user_data.is_admin]
        if sum(bool(role) for role in roles) == 0:
            raise HTTPException(
                status_code=400,
                detail="At least one role must be assigned: student, teacher, or admin."
            )
        if sum(bool(role) for role in roles) > 1:
            raise HTTPException(
                status_code=400,
                detail="Only one role can be assigned to a user."
            )

    @staticmethod
    def filter_users_by_role(db: Session, role: str):
        query = db.query(models.User_Profile)

        if role == "student":
            query = query.filter(models.User_Profile.is_student == True)
        elif role == "teacher":
            query = query.filter(models.User_Profile.is_teacher == True)
        elif role == "admin":
            query = query.filter(models.User_Profile.is_admin == True)
        else:
            raise HTTPException(status_code=400, detail="Invalid role specified.")

        return query.all()
