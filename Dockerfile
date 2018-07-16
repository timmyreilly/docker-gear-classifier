FROM ufoym/deepo:cntk-py36-cu90

EXPOSE 5000

COPY . /app
WORKDIR /app
RUN pip install -r requirements.txt
ENTRYPOINT ["python"]
CMD ["app.py"]