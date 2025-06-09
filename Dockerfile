FROM python:3.10-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY models/ models/

EXPOSE 8080 8081

CMD ["mlserver", "start", "./models"]

