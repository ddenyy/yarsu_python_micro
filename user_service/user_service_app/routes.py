from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from . import users_profile, schemas, models
from .database import get_db

router = APIRouter(prefix="/users", tags=["Users"])


@router.post("/", response_model=schemas.UserProfileRead)
def create_user(user: schemas.UserProfileCreate, db: Session = Depends(get_db)):
    return users_profile.create_user_profile(db, user)


@router.get("/{user_id}", response_model=schemas.UserProfileRead)
def read_user(user_id: int, db: Session = Depends(get_db)):
    db_user = users_profile.get_user_profile(db, user_id)
    if db_user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return db_user


@router.get("/", response_model=list[schemas.UserProfileRead])
def read_users(skip: int = 0, limit: int = 10, db: Session = Depends(get_db)):
    return users_profile.get_users(db, skip=skip, limit=limit)

@router.put("/{user_id}", response_model=schemas.UserProfileRead)
def update_user(user_id: int, user_data: schemas.UserProfileCreate, db: Session = Depends(get_db)):
    db_user = users_profile.get_user_profile(db, user_id)
    if not db_user:
        raise HTTPException(status_code=404, detail="User not found")
    for key, value in user_data.dict().items():
        setattr(db_user, key, value)
    db_user.updated_at = datetime.now()
    db.commit()
    db.refresh(db_user)
    return db_user

@router.get("/filter/", response_model=list[schemas.UserProfileRead])
def filter_by_role(role: str, db: Session = Depends(get_db)):
    query = db.query(models.User_Profile)
    if role == "student":
        query = query.filter(models.User_Profile.is_student == True)
    elif role == "teacher":
        query = query.filter(models.User_Profile.is_teacher == True)
    elif role == "admin":
        query = query.filter(models.User_Profile.is_admin == True)
    else:
        raise HTTPException(status_code=400, detail="Некорректная роль")
    return query.all()

@router.delete("/{user_id}")
def delete_user(user_id: int, db: Session = Depends(get_db)):
    user = users_profile.get_user_profile(db, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    if not user.is_admin:
        raise HTTPException(status_code=403, detail="Удаление разрешено только администраторам")
    users_profile.delete_user(db, user_id)
    return {"detail": "User deleted"}


