FROM nvidia/cuda:11.7.1-cudnn8-runtime-ubuntu22.04

WORKDIR /usr/src/app

RUN apt-get update && apt-get install -y \
    wget \
    xz-utils \
    git \
    python3 \
    python3-pip \
    python-is-python3 \
    libglib2.0-0

RUN pip install opencv-python

RUN apt install -y \
    libsm6 libxext6 \
    libxrender-dev

COPY ./start.sh ./

EXPOSE 9000

CMD ["sh", "./start.sh"]
