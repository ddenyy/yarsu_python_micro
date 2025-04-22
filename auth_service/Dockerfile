FROM python:3.11

WORKDIR /app

COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

COPY . .

COPY wait-for-it.sh /wait-for-it.sh
RUN chmod +x /wait-for-it.sh


CMD ["bash", "/wait-for-it.sh", "auth_db:5432", "--", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]

