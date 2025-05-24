import logging

from fastapi import FastAPI, Request, HTTPException, Depends
import httpx
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

AUTH_SERVICE_URL = "http://auth_service:8000/auth"
USER_SERVICE_URL = "http://user_service:8000"
SCHEDULE_SERVICE_URL = "http://schedule_service:8000"

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

async def get_current_user(request: Request):
    auth_header = request.headers.get("Authorization")
    if not auth_header or not auth_header.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Missing or invalid Authorization header")

    token = auth_header.split(" ")[1]
    async with httpx.AsyncClient() as client:
        resp = await client.post(f"{AUTH_SERVICE_URL}/verify-token", json={"token": token})
        if resp.status_code != 200:
            raise HTTPException(status_code=401, detail="Invalid token")

        return resp.json()["user_id"]

@app.post("/register")
async def register_user(request: Request):
    data = await request.json()

    async with httpx.AsyncClient() as client:
        # Регистрация в auth_service
        try:
            auth_resp = await client.post(f"{AUTH_SERVICE_URL}/register", json=data)
            auth_resp.raise_for_status()
        except httpx.HTTPError as e:
            raise HTTPException(status_code=auth_resp.status_code, detail="Auth registration failed")

        auth_user = auth_resp.json()

        # Создание профиля в user_service
        try:
            profile_resp = await client.post(f"{USER_SERVICE_URL}/profile", json=auth_user)
            profile_resp.raise_for_status()
        except httpx.HTTPError as e:
            raise HTTPException(status_code=profile_resp.status_code, detail="User profile creation failed")

        return {
            "auth": auth_user,
            "profile": profile_resp.json()
        }

@app.post("/login")
async def login(request: Request):
    data = await request.json()

    async with httpx.AsyncClient() as client:
        try:
            response = await client.post(f"{AUTH_SERVICE_URL}/login", json=data)
            response.raise_for_status()
        except httpx.HTTPError:
            raise HTTPException(status_code=response.status_code, detail="Login failed")

        return response.json()

@app.get("/profile")
async def get_own_profile(current_user: int = Depends(get_current_user)):
    async with httpx.AsyncClient() as client:
        profile = await client.get(f"{USER_SERVICE_URL}/profile/{current_user}")
        if profile.status_code == 200:
            return profile.json()
        raise HTTPException(status_code=404, detail="Profile not found")


@app.post("/refresh")
async def refresh_token(request: Request):
    data = await request.json()
    refresh_token = data.get("refresh_token")
    
    if not refresh_token:
        raise HTTPException(status_code=400, detail="Refresh token is required")

    async with httpx.AsyncClient() as client:
        try:
            response = await client.post(f"{AUTH_SERVICE_URL}/refresh", json={"refresh_token": refresh_token})
            response.raise_for_status()
        except httpx.HTTPError:
            raise HTTPException(status_code=response.status_code, detail="Token refresh failed")

        return response.json()

# Новый эндпоинт для получения профиля текущего пользователя
@app.get("/profile/me")
async def get_my_profile(current_user_id: int = Depends(get_current_user)):
    async with httpx.AsyncClient() as client:
        try:
            # Пытаемся получить как студента
            resp = await client.get(f"{USER_SERVICE_URL}/students/{current_user_id}")
            if resp.status_code == 404: # Not Found
                # Если не студент, пытаемся как преподавателя
                resp = await client.get(f"{USER_SERVICE_URL}/teachers/{current_user_id}")
            
            resp.raise_for_status() # Проверка на ошибки HTTP (4xx, 5xx)
            return resp.json()
        except httpx.HTTPStatusError as e:
            # Ошибка от user_service (например, 404, если профиль не найден)
            detail = f"Failed to get user profile from user_service: {e.response.text}"
            try:
                # Попытка извлечь более конкретную ошибку из ответа user_service
                error_json = e.response.json()
                if isinstance(error_json, dict) and 'detail' in error_json:
                    detail = error_json['detail']
            except ValueError: # Если ответ не JSON
                pass 
            raise HTTPException(status_code=e.response.status_code, detail=detail)
        except httpx.RequestError as e:
            # Ошибка сети при обращении к user_service
            raise HTTPException(status_code=503, detail=f"User service is unavailable: {str(e)}")

@app.put("/profile")
async def update_profile(
    request: Request,
    current_user: int = Depends(get_current_user)
):
    data = await request.json()
    logging.warning(f"DATA TO USER SERVICE: {data}")

    async with httpx.AsyncClient() as client:
        try:
            response = await client.put(f"{USER_SERVICE_URL}/profile/{current_user}", json=data)
            response.raise_for_status()
        except httpx.HTTPError:
            logging.error(f"USER SERVICE ERROR: {response.text}")
            raise HTTPException(status_code=response.status_code, detail="Failed to update user profile")

        return response.json()
    


@app.post("/groups")
async def create_group(request: Request, current_user: int = Depends(get_current_user)):
    # Получение профиля пользователя
    async with httpx.AsyncClient() as client:
        try:
            profile_resp = await client.get(f"{USER_SERVICE_URL}/profile/{current_user}")
            profile_resp.raise_for_status()
            profile_data = profile_resp.json()
        except httpx.HTTPError:
            raise HTTPException(status_code=500, detail="Failed to fetch user profile")

    #if not profile_data.get("is_admin", False):
    #    raise HTTPException(status_code=403, detail="Only admins can create groups")

    # Получаем тело запроса
    data = await request.json()

    async with httpx.AsyncClient() as client:
        # Создание группы в user_service
        try:
            user_response = await client.post(f"{USER_SERVICE_URL}/groups", json=data)
            user_response.raise_for_status()
        except httpx.HTTPError as e:
            raise HTTPException(status_code=user_response.status_code, detail="User service: group creation failed")

        # Создание группы в schedule_service
        try:
            schedule_response = await client.post(f"{SCHEDULE_SERVICE_URL}/groups", json=data)
            schedule_response.raise_for_status()
        except httpx.HTTPError as e:
            raise HTTPException(
                status_code=schedule_response.status_code,
                detail="Schedule service: group creation failed"
            )

        return {
            "user_service": user_response.json(),
            "schedule_service": schedule_response.json()
        }



                
@app.get("/groups/{group_id}/students")
async def get_students_by_group(group_id: int, current_user: int = Depends(get_current_user)):
    async with httpx.AsyncClient() as client:
        # Получаем профиль пользователя
        profile_resp = await client.get(f"{USER_SERVICE_URL}/students/{current_user}")
        if profile_resp.status_code != 200:
            profile_resp = await client.get(f"{USER_SERVICE_URL}/teachers/{current_user}")
        if profile_resp.status_code != 200:
            raise HTTPException(status_code=403, detail="Access denied: no profile")

        profile = profile_resp.json()

        # Проверяем права доступа
        is_admin = profile.get("is_admin", False)
        is_teacher = profile.get("is_teacher", False)
        is_student = profile.get("is_student", False)
        user_group_id = profile.get("group_id")

        if is_admin or is_teacher or (is_student and user_group_id == group_id):
            # Разрешено — возвращаем студентов группы
            response = await client.get(f"{USER_SERVICE_URL}/groups/{group_id}/students")
            response.raise_for_status()
            return response.json()

        raise HTTPException(status_code=403, detail="Access denied: insufficient permissions")



@app.get("/students")
async def get_students():
    async with httpx.AsyncClient() as client:
        # Возвращаем список студентов
        response = await client.get(f"{USER_SERVICE_URL}/students")
        response.raise_for_status()
        return response.json()



@app.get("/teachers")
async def get_teachers(current_user: int = Depends(get_current_user)):
    async with httpx.AsyncClient() as client:
        # Просто факт, что пользователь авторизован (ID есть), уже даёт доступ
        resp = await client.get(f"{USER_SERVICE_URL}/teachers")
        resp.raise_for_status()
        return resp.json()

    
@app.get("/teachers/{teacher_id}")
async def get_teacher_by_id(teacher_id: int, current_user: int = Depends(get_current_user)):
    async with httpx.AsyncClient() as client:
        response = await client.get(f"{USER_SERVICE_URL}/teachers/{teacher_id}")
        response.raise_for_status()
        return response.json()


@app.get("/students/{student_id}")
async def get_student_by_id(student_id: int, request: Request, current_user: int = Depends(get_current_user)):
    async with httpx.AsyncClient() as client:
        # Получаем профиль текущего пользователя
        user_resp = await client.get(f"{USER_SERVICE_URL}/students/{current_user}")
        if user_resp.status_code != 200:
            raise HTTPException(status_code=403, detail="Unable to verify current user")

        current_profile = user_resp.json()

        # Проверяем права доступа
        is_admin = current_profile.get("is_admin", False)
        is_teacher = current_profile.get("is_teacher", False)
        is_self = int(current_user) == student_id

        if not (is_admin or is_teacher or is_self):
            raise HTTPException(status_code=403, detail="Access denied")

        # Получаем запрашиваемого студента
        response = await client.get(f"{USER_SERVICE_URL}/students/{student_id}")
        response.raise_for_status()
        return response.json()


    

@app.get("/groups")
async def get_groups(request: Request, current_user: int = Depends(get_current_user)):
    async with httpx.AsyncClient() as client:
        try:
            response = await client.get(f"{USER_SERVICE_URL}/groups")
            response.raise_for_status()
        except httpx.HTTPError:
            raise HTTPException(status_code=500, detail="Ошибка получения групп")
        return response.json()


@app.post("/lesson")
async def create_lesson(request: Request, current_user_id: str = Depends(get_current_user)):
    # Получаем профиль пользователя
    async with httpx.AsyncClient() as client:
        profile_resp = await client.get(f"{USER_SERVICE_URL}/students/{current_user_id}")
        if profile_resp.status_code != 200:
            profile_resp = await client.get(f"{USER_SERVICE_URL}/teachers/{current_user_id}")
            if profile_resp.status_code != 200:
                raise HTTPException(status_code=403, detail="Cannot fetch user profile")

        profile = profile_resp.json()
        #if not (profile.get("is_teacher") or profile.get("is_admin")):
        #    raise HTTPException(status_code=403, detail="Only teachers or admins can create lessons")

        data = await request.json()
        resp = await client.post(f"{SCHEDULE_SERVICE_URL}/lesson/", json=data)
        resp.raise_for_status()
        return resp.json()

    
@app.get("/lesson/teacher/{teacher_id}")
async def get_lessons_by_teacher(current_user: dict = Depends(get_current_user)):
    async with httpx.AsyncClient() as client:
        resp = await client.get(f"{SCHEDULE_SERVICE_URL}/lesson/?teacher_id={current_user}")
        resp.raise_for_status()
        return resp.json()

@app.get("/lesson/student/{student_id}")
async def get_lessons_by_student(current_user: dict = Depends(get_current_user)):
    if not (current_user.get("is_admin") or current_user["user_id"] == current_user):
        raise HTTPException(status_code=403, detail="Access denied")

    async with httpx.AsyncClient() as client:
        resp = await client.get(f"{SCHEDULE_SERVICE_URL}/lesson/?student_id={current_user}")
        resp.raise_for_status()
        return resp.json()


@app.patch("/lesson/{lesson_id}")
async def update_lesson(lesson_id: int, request: Request, current_user: dict = Depends(get_current_user)):
    if not (current_user.get("is_teacher") or current_user.get("is_admin")):
        raise HTTPException(status_code=403, detail="Only teachers or admins can update lessons")

    data = await request.json()
    async with httpx.AsyncClient() as client:
        resp = await client.patch(f"{SCHEDULE_SERVICE_URL}/lesson/{lesson_id}", json=data)
        resp.raise_for_status()
        return resp.json()

@app.delete("/lesson/{lesson_id}")
async def delete_lesson(lesson_id: int, current_user: dict = Depends(get_current_user)):
    if not current_user.get("is_admin"):
        raise HTTPException(status_code=403, detail="Only admins can delete lessons")

    async with httpx.AsyncClient() as client:
        resp = await client.delete(f"{SCHEDULE_SERVICE_URL}/lesson/{lesson_id}")
        resp.raise_for_status()
        return {"detail": "Lesson deleted"}






