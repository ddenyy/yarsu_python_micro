from fastapi import Depends, HTTPException, Header
from .auth import verify_jwt_token

def get_current_user(authorization: str = Header(None)):
    if authorization is None or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Токен не найден")
    
    token = authorization.split(" ")[1]
    user_id = verify_jwt_token(token)
    
    if user_id is None:
        raise HTTPException(status_code=401, detail="Неверный токен")
    
    return user_id
