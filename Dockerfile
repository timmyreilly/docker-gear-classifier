FROM python:3.5
RUN apt-get update -y
RUN apt-get install -y python-pip python-dev build-essential
RUN apt-get install -y openmpi-bin 
RUN apt-get install -y libpython3-dev -y 
ENV KERAS_BACKEND=cntk
COPY . /app
WORKDIR /app
RUN pip install -r requirements.txt
ENTRYPOINT ["python"]
CMD ["app.py"]