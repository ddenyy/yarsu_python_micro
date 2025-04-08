from fastapi import FastAPI
from .database import engine, Base
from .routes import router as user_router

app = FastAPI(title="User Profile Microservice")

# Создание таблиц
Base.metadata.create_all(bind=engine)

# Подключение маршрутов
app.include_router(user_router)
