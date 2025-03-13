from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session
from .database import SessionLocal
from .models import User
from .schemas import TokenRequest, UserCreate, UserResponse
from .auth import hash_password, verify_jwt_token, verify_password, create_tokens
from .dependencies import get_current_user

router = APIRouter()

# Подключение к БД
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/register", response_model=UserResponse)
def register(user_data: UserCreate, db: Session = Depends(get_db)):
    # Проверяем, существует ли пользователь
    existing_user = db.query(User).filter(User.email == user_data.email).first()
    if existing_user:
        raise HTTPException(status_code=400, detail="Email уже используется")

    # Хэшируем пароль
    hashed_password = hash_password(user_data.password)

    # Создаём нового пользователя
    new_user = User(email=user_data.email, hashed_password=hashed_password)
    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    return new_user

# Логин (выдача Access и Refresh токена)
@router.post("/login")
def login(user_data: UserCreate, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == user_data.email).first()
    
    if not user or not verify_password(user_data.password, user.hashed_password):
        raise HTTPException(status_code=401, detail="Неверный email или пароль")

    access_token, refresh_token = create_tokens(user.id)
    
    return {"access_token": access_token, "refresh_token": refresh_token, "token_type": "bearer"}


@router.post("/verify-token")
def verify_token_request(data: TokenRequest):
    user_id = verify_jwt_token(data.token)

    if user_id is None:
        raise HTTPException(status_code=401, detail="Неверный токен")

    return {"user_id": user_id}



@router.get("/me")
def get_me(user_id: int = Depends(get_current_user)):
    return {"user_id": user_id}

@router.post("/refresh")
def refresh_token(refresh_token: str):
    user_id = verify_jwt_token(refresh_token)
    
    if user_id is None:
        raise HTTPException(status_code=401, detail="Неверный refresh-токен")
    
    access_token, new_refresh_token = create_tokens(int(user_id))
    
    return {"access_token": access_token, "refresh_token": new_refresh_token, "token_type": "bearer"}

