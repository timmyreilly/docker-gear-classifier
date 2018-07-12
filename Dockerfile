FROM python:3.5
RUN apt-get update -y
RUN apt-get install -y python-pip python-dev build-essential
RUN apt-get install openmpi-bin -y 
RUN apt-get install libpython3-dev -y 
RUN export KERAS_BACKEND=cntk
COPY . /app
WORKDIR /app
RUN pip install -r requirements.txt
ENTRYPOINT ["python"]
CMD ["app.py"]