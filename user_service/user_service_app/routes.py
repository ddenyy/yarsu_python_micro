from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from .database import get_db
from .models import User_Profile, Group
from .schemas import GroupCreate, UserProfileCreate, UserProfileUpdate
from typing import List

import logging

router = APIRouter()

@router.post("/profile", status_code=201)
def create_user_profile(payload: UserProfileCreate, db: Session = Depends(get_db)):
    if db.query(User_Profile).filter(User_Profile.id == payload.id).first():
        raise HTTPException(status_code=400, detail="User profile already exists")

    new_profile = User_Profile(
        id=payload.id,
        email=payload.email
    )
    db.add(new_profile)
    db.commit()
    db.refresh(new_profile)
    return {"message": "User profile created", "id": new_profile.id}

@router.put("/profile/{user_id}")
def update_user_profile(user_id: int, payload: UserProfileUpdate, db: Session = Depends(get_db)):
    logging.warning(f"payload = {payload}")
    profile = db.query(User_Profile).filter(User_Profile.id == user_id).first()
    if not profile:
        raise HTTPException(status_code=404, detail="User profile not found")

    for key, value in payload.dict(exclude_unset=True).items():
        setattr(profile, key, value)

    db.commit()
    db.refresh(profile)
    return profile

@router.get("/profile/{user_id}")
def get_user_profile(user_id: int, db: Session = Depends(get_db)):
    profile = db.query(User_Profile).filter(User_Profile.id == user_id).first()
    if not profile:
        raise HTTPException(status_code=404, detail="User profile not found")
    return profile

@router.get("/students")
def get_students(db: Session = Depends(get_db)):
    students = db.query(User_Profile).filter(User_Profile.is_student == True).all()
    return [{"id": s.id, "group": s.group.name if s.group else None} for s in students]

@router.get("/teachers")
def get_teachers(db: Session = Depends(get_db)):
    teachers = db.query(User_Profile).filter(User_Profile.is_teacher == True).all()
    return [{"id": t.id, "group": t.group.name if t.group else None} for t in teachers]


@router.get("/groups", response_model=List[str])
def get_groups(db: Session = Depends(get_db)):
    groups = db.query(Group.name).distinct().all()
    return [g[0] for g in groups if g[0] is not None]

@router.get("/groups/{group_id}/students")
def get_students_by_group(group_id: int, db: Session = Depends(get_db)):
    group = db.query(Group).filter(Group.id == group_id).first()
    if not group:
        raise HTTPException(status_code=404, detail="Group not found")

    students = db.query(User_Profile).filter(
        User_Profile.group_id == group_id,
        User_Profile.is_student == True
    ).all()

    return [
        {
            "name": student.name,
            "second_name": student.second_name,
        }
        for student in students
    ]

@router.get("/teachers/{teacher_id}")
def get_teacher_by_id(teacher_id: int, db: Session = Depends(get_db)):
    teacher = db.query(User_Profile).filter(
        User_Profile.id == teacher_id,
        User_Profile.is_teacher == True
    ).first()

    if not teacher:
        raise HTTPException(status_code=404, detail="Teacher not found")

    return {
        "id": teacher.id,
        "name": teacher.name,
        "second_name": teacher.second_name,
        "email": teacher.email
    }

@router.get("/students/{student_id}")
def get_student_by_id(student_id: int, db: Session = Depends(get_db)):
    student = db.query(User_Profile).filter(
        User_Profile.id == student_id,
        User_Profile.is_student == True
    ).first()

    if not student:
        raise HTTPException(status_code=404, detail="Student not found")

    return {
        "id": student.id,
        "name": student.name,
        "second_name": student.second_name,
        "email": student.email,
        "group": student.group.name if student.group else None
    }

@router.post("/groups")
def create_group(group: GroupCreate, db: Session = Depends(get_db)):
    new_group = Group(name=group.name, description=group.description)
    db.add(new_group)
    db.commit()
    db.refresh(new_group)
    return new_group

@router.get("/users/{user_id}/group")
def get_user_group_name(user_id: int, db: Session = Depends(get_db)):
    user = db.query(User_Profile).filter(User_Profile.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    return {"group_name": user.group.name if user.group else None}