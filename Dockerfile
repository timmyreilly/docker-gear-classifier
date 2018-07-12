FROM python:3.5
RUN apt-get update -y
RUN apt-get install -y python-pip python-dev build-essential

# RUN apt-get install -y openmpi-bin

# Get and build Open MPI
RUN wget -q https://www.open-mpi.org/software/ompi/v1.10/downloads/openmpi-1.10.3.tar.gz && \
    tar -xzvf ./openmpi-1.10.3.tar.gz && \
    cd openmpi-1.10.3 && \
    ./configure --prefix=/usr/local/mpi && \
    make -j all && \
    make install && cd .. && \
    rm -rf openmpi-1.10.3 openmpi-1.10.3.tar.gz

# Add Open MPI to path
ENV PATH "/usr/local/mpi/bin:$PATH"
ENV LD_LIBRARY_PATH "/usr/local/mpi/lib:$LD_LIBRARY_PATH"
ENV MPI_ROOT "/usr/local/mpi"

RUN apt-get install -y libpython3-dev -y 
ENV KERAS_BACKEND=cntk
ENV PATH=/usr/local/mpi/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/local/mpi/lib:$LD_LIBRARY_PATH
COPY . /app
WORKDIR /app
RUN pip install -r requirements.txt
ENTRYPOINT ["python"]
CMD ["app.py"]