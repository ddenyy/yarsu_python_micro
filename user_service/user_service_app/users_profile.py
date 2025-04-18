from sqlalchemy.orm import Session
from . import models, schemas
from datetime import datetime


def create_user_profile(db: Session, user: schemas.UserProfileCreate) -> models.User_Profile:
    db_user = models.User_Profile(**user.dict(), created_at=datetime.now(), updated_at=datetime.now())
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user


def update_user_profile(db: Session, user: schemas.UserProfileUpdate, user_id: int) -> models.User_Profile:
    db_user = db.query(models.User_Profile).filter(models.User_Profile.id == user_id).first()

    if db_user is None:
        raise ValueError(f"User with id {user_id} not found")

    for key, value in user.dict().items():
        setattr(db_user, key, value)

    db_user.updated_at = datetime.now()

    db.commit()

    db.refresh(db_user)

    return db_user


def get_user_profile(db: Session, user_id: int):
    return db.query(models.User_Profile).filter(models.User_Profile.id == user_id).first()


def get_users(db: Session, skip: int = 0, limit: int = 10):
    return db.query(models.User_Profile).offset(skip).limit(limit).all()


def delete_user(db: Session, user_id: int):
    user = db.query(models.User_Profile).filter(models.User_Profile.id == user_id).first()
    if user:
        db.delete(user)
        db.commit()
        return True
    return False
