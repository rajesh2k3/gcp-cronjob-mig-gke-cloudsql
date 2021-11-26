FROM python:3.8-alpine

RUN apk update --no-cache && apk add bash

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY main.py .

CMD ["/usr/local/bin/python", "./main.py"]