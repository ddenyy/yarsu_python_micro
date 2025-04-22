from fastapi import FastAPI, Request, HTTPException
import httpx

app = FastAPI()

AUTH_SERVICE_URL = "http://auth_service:8000/auth"
USER_SERVICE_URL = "http://user_service:8000"

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


@app.put("/profile/{user_id}")
async def update_profile(user_id: int, request: Request):
    data = await request.json()

    async with httpx.AsyncClient() as client:
        try:
            response = await client.put(f"{USER_SERVICE_URL}/profile/{user_id}", json=data)
            response.raise_for_status()
        except httpx.HTTPError:
            raise HTTPException(status_code=response.status_code, detail="Failed to update user profile")

        return response.json()
    


@app.post("/groups")
async def create_group(request: Request):
    data = await request.json()
    async with httpx.AsyncClient() as client:
        try:
            response = await client.post(f"{USER_SERVICE_URL}/groups", json=data)
            response.raise_for_status()
            return response.json()
        except httpx.HTTPError as e:
            raise HTTPException(status_code=response.status_code, detail="Group creation failed")
                
@app.get("/groups/{group_id}/students")
async def get_students_by_group(group_id: int):
    async with httpx.AsyncClient() as client:
        response = await client.get(f"{USER_SERVICE_URL}/groups/{group_id}/students")
        response.raise_for_status()
        return response.json()


@app.get("/students")
async def get_students():
    async with httpx.AsyncClient() as client:
        resp = await client.get(f"{USER_SERVICE_URL}/students")
        resp.raise_for_status()
        return resp.json()


@app.get("/teachers")
async def get_teachers():
    async with httpx.AsyncClient() as client:
        resp = await client.get(f"{USER_SERVICE_URL}/teachers")
        resp.raise_for_status()
        return resp.json()
    
@app.get("/teachers/{teacher_id}")
async def get_teacher_by_id(teacher_id: int):
    async with httpx.AsyncClient() as client:
        response = await client.get(f"{USER_SERVICE_URL}/teachers/{teacher_id}")
        response.raise_for_status()
        return response.json()

@app.get("/students/{student_id}")
async def get_student_by_id(student_id: int):
    async with httpx.AsyncClient() as client:
        response = await client.get(f"{USER_SERVICE_URL}/students/{student_id}")
        response.raise_for_status()
        return response.json()

    

@app.get("/groups")
async def get_groups():
    async with httpx.AsyncClient() as client:
        try:
            response = await client.get(f"{USER_SERVICE_URL}/groups")
            response.raise_for_status()
        except httpx.HTTPError:
            raise HTTPException(status_code=500, detail="Ошибка получения групп")
        return response.json()





