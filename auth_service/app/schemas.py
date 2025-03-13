from pydantic import BaseModel, EmailStr

class UserCreate(BaseModel):
    email: EmailStr
    password: str

class UserResponse(BaseModel):
    id: int
    email: str

    class Config:
        from_attributes = True  # Позволяет работать с SQLAlchemy-моделью

class TokenRequest(BaseModel):
    token: str
