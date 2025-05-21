FROM python:3.12

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

COPY wait-for-it.sh /wait-for-it.sh
RUN chmod +x /wait-for-it.sh

CMD ["bash", "/wait-for-it.sh", "schedule_db:5432", "--", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]

