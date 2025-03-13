from fastapi import FastAPI
from .users import router as user_router
from .database import Base, engine

app = FastAPI()

# Создаём таблицы
Base.metadata.create_all(bind=engine)

# Подключаем маршруты
app.include_router(user_router, prefix="/auth", tags=["Auth"])
