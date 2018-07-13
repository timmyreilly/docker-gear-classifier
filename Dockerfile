# FROM python:3.5


# FROM microsoft/cntk:2.5.1-gpu-python3.5-cuda9.0-cudnn7.0
# RUN apt-get update && apt-get install -y --no-install-recommends apt-utils
# RUN apt-get install -y python-pip python-dev build-essential

# # RUN apt-get install -y openmpi-bin

# # Get and build Open MPI
# RUN wget -q https://www.open-mpi.org/software/ompi/v1.10/downloads/openmpi-1.10.3.tar.gz && \
#     tar -xzvf ./openmpi-1.10.3.tar.gz && \
#     cd openmpi-1.10.3 && \
#     ./configure --prefix=/usr/local/mpi && \
#     make -j all && \
#     make install && cd .. && \
#     rm -rf openmpi-1.10.3 openmpi-1.10.3.tar.gz

# # Add Open MPI to path
# ENV PATH "/usr/local/mpi/bin:$PATH"
# ENV LD_LIBRARY_PATH "/usr/local/mpi/lib:$LD_LIBRARY_PATH"
# ENV MPI_ROOT "/usr/local/mpi"

# RUN apt-get install -y libpython3-dev -y 
# ENV KERAS_BACKEND=cntk
# ENV PATH=/usr/local/mpi/bin:$PATH
# ENV LD_LIBRARY_PATH=/usr/local/mpi/lib:$LD_LIBRARY_PATH
# COPY . /app
# WORKDIR /app
# ENTRYPOINT ["python"]
# CMD ["app.py"]


FROM nvidia/cuda:9.2-cudnn7-devel-ubuntu16.04

MAINTAINER Jonathan DEKHTIAR [http://www.jonathandekhtiar.eu] <contact@jonathandekhtiar.eu>

# install debian packages
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -qq \
 && apt-get install --no-install-recommends -y \
    # install essentials and build dependencies
    build-essential \
    autotools-dev \
    cmake \
    curl \
    git \
    g++ \
    git \
    gfortran-multilib \
    libavcodec-dev \
    libavformat-dev \
    libjasper-dev \
    libjpeg-dev \
    libpng-dev \
    liblapacke-dev \
    libswscale-dev \
    libtiff-dev \
    pkg-config \
    libfreetype6-dev \
    libpng12-dev \
    libzmq3-dev \
    rsync \
    software-properties-common \
    unzip \
    wget \
    zlib1g-dev \
    libffi-dev \
    # Protobuf
    ca-certificates \
    less \
    procps \
    vim-tiny \
    # install python 3
    python3 \
    python3-dev \
    python3-pip \
    python3-setuptools \
    python3-virtualenv \
    python3-wheel \
    pkg-config \
    # requirements for numpy
    libopenblas-base \
    python3-numpy \
    python3-scipy \
    # requirements for cntk
    openmpi-bin \
    # requirements for keras
    python3-h5py \
    python3-yaml \
    python3-pydot \
    python3-matplotlib \
    python3-pillow \
    # For Kaldi
    automake \
    libtool \
    autoconf \
    subversion \
    # For Kaldi's dependencies
    libapr1 libaprutil1 libltdl-dev libltdl7 libserf-1-1 libsigsegv2 libsvn1 m4 \
    # For Java Bindings
    openjdk-8-jdk \
    # For SWIG
    libpcre3-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
 
 RUN pip3 install --upgrade pip
 RUN pip3 --no-cache-dir install \
        Pillow \
        h5py \
        ipykernel \
        jupyter \
        matplotlib \
        numpy \
        pandas \
        scipy \
        scikit-learn \
        statsmodels \
        # jupyter notebook and ipython (Python 3)
        ipython \
        ipykernel \
&& python3 -m ipykernel.kernelspec

RUN pip3 install -r requirements.txt

RUN ln -s /usr/bin/pip3 /usr/bin/pip \ 
&& ln -s /usr/bin/python3 /usr/bin/python

# ############ TENSORFLOW INSTALLATION #############
# RUN pip3 install tensorflow-gpu
# # For CUDA profiling, TensorFlow requires CUPTI.
# ENV LD_LIBRARY_PATH /usr/local/cuda/extras/CUPTI/lib64:$LD_LIBRARY_PATH
# ENV LD_LIBRARY_PATH /usr/local/cuda/bin:$LD_LIBRARY_PATH
# ENV LD_LIBRARY_PATH /usr/local/cuda/lib64:$LD_LIBRARY_PATH
# ENV LD_LIBRARY_PATH /usr/lib/x86_64-linux-gnu/:$LD_LIBRARY_PATH

# ############ THEANO INSTALLATION #############
# RUN pip3 install Theano

############ NLTK INSTALLATION #############
RUN pip3 install https://cntk.ai/PythonWheel/GPU/cntk-2.1-cp35-cp35m-linux_x86_64.whl
ENV PATH /usr/bin:$PATH
ENV LD_LIBRARY_PATH /usr/lib:$LD_LIBRARY_PATH
ENV KERAS_BACKEND=cntk

############ KERAS INSTALLATION #############
RUN pip3 install keras

# configure console
RUN echo 'alias ll="ls --color=auto -lA"' >> /root/.bashrc \
 && echo '"\e[5~": history-search-backward' >> /root/.inputrc \
 && echo '"\e[6~": history-search-forward' >> /root/.inputrc
# default password: keras
ENV PASSWD='sha1:98b767162d34:8da1bc3c75a0f29145769edc977375a373407824'

# dump package lists
RUN dpkg-query -l > /dpkg-query-l.txt \
 && pip3 freeze > /pip3-freeze.txt

# for jupyter
EXPOSE 8888
# for tensorboard
EXPOSE 6006
# For Flask 
EXPOSE 5000

COPY . /app
WORKDIR /app
ENTRYPOINT ["python"]
CMD ["app.py"]
