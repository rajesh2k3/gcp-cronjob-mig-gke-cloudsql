FROM python:3.8.2-alpine
//FROM python:3.8-alpine

RUN apk update --no-cache && apk add bash

# Allow statements and log messages to immediately appear in the Knative logs
ENV PYTHONUNBUFFERED True
ENV PORT 8080

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY realcode/ ./realcode/
COPY main.py .

CMD exec gunicorn --bind :$PORT --workers 1 --threads 1 --timeout 0 main:app
