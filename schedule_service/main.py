from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
import crud, schemas
from database import SessionLocal, engine
import models

models.Base.metadata.create_all(bind=engine)

app = FastAPI()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@app.post("/groups/", response_model=schemas.StudentGroup)
def create_group(group: schemas.GroupCreate, db: Session = Depends(get_db)):
    db_group = crud.get_group_by_name(db, name=group.name)
    if db_group:
        raise HTTPException(status_code=400, detail="Group already exists")
    return crud.create_group(db=db, group=group)

@app.post("/lesson/", response_model=schemas.LessonOut)
def create_lesson(lesson: schemas.LessonCreate, db: Session = Depends(get_db)):
    return crud.create_lesson(db, lesson)

@app.get("/lessons/{user_id}", response_model=list[schemas.LessonOut])
def get_lessons(user_id: int, db: Session = Depends(get_db)):
    user = db.query(models.User_Profile).filter(models.User_Profile.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    if user.is_student:
        return crud.get_lessons_by_student(db, user_id)
    elif user.is_teacher:
        return crud.get_lessons_by_teacher(db, user_id)
    else:
        raise HTTPException(status_code=400, detail="User is neither student nor teacher")


@app.patch("/lesson/{lesson_id}", response_model=schemas.LessonOut)
def update_lesson(lesson_id: int, updates: schemas.LessonUpdate, db: Session = Depends(get_db)):
    updated = crud.update_lesson(db, lesson_id, updates)
    if not updated:
        raise HTTPException(status_code=404, detail="Lesson not found")
    return updated

@app.delete("/lesson/{lesson_id}", response_model=schemas.LessonOut)
def delete_lesson(lesson_id: int, db: Session = Depends(get_db)):
    deleted = crud.delete_lesson(db, lesson_id)
    if not deleted:
        raise HTTPException(status_code=404, detail="Lesson not found")
    return deleted
