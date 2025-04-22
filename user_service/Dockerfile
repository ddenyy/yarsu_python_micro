FROM python:3.12

WORKDIR /user_service_app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

COPY wait-for-it.sh /wait-for-it.sh
RUN chmod +x /wait-for-it.sh

CMD ["bash", "/wait-for-it.sh", "user_db:5432", "--", "uvicorn", "user_service_app.main:app", "--host", "0.0.0.0", "--port", "8000"]


