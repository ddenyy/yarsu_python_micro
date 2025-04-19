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

@app.post("/lesson/", response_model=schemas.LessonOut)
def create_lesson(lesson: schemas.LessonCreate, db: Session = Depends(get_db)):
    return crud.create_lesson(db, lesson)

@app.get("/lesson/", response_model=list[schemas.LessonOut])
def get_lessons(student_id: int = None, teacher_id: int = None, db: Session = Depends(get_db)):
    if student_id:
        return crud.get_lessons_by_student(db, student_id)
    elif teacher_id:
        return crud.get_lessons_by_teacher(db, teacher_id)
    else:
        raise HTTPException(status_code=400, detail="student_id or teacher_id required")

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
