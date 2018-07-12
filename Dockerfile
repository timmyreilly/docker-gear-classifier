FROM python:3
RUN apt-get update -y
RUN apt-get install -y python-pip python-dev build-essential
RUN apt-get install openmpi-bin
RUN apt-get install libpython3-dev
RUN python3.6 -m pip install https://cntk.ai/PythonWheel/CPU-Only/cntk-2.1-cp36-cp36m-linux_x86_64.whl
RUN export KERAS_BACKEND=cntk
COPY . /app
WORKDIR /app
RUN pip install -r requirements.txt
ENTRYPOINT ["python"]
CMD ["app.py"]