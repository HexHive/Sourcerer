FROM ubuntu:16.04 AS build

RUN apt update -y 

# Prerequites to build python 3.8
RUN apt-get install build-essential checkinstall wget tar -y
RUN apt-get install -y libreadline-gplv2-dev libncursesw5-dev libssl-dev \
    libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev libffi-dev zlib1g-dev

# Download and build python 3.8

RUN cd /opt && wget https://www.python.org/ftp/python/3.8.12/Python-3.8.12.tgz
RUN cd /opt && tar xzf Python-3.8.12.tgz
RUN cd /opt/Python-3.8.12/ && ./configure --enable-optimizations && make altinstall

RUN apt-get -y install git build-essential \ 
    cmake libuv1-dev libssl-dev libhwloc-dev clang 

RUN python3.8 -m pip install --upgrade pip 
RUN pip install python-dotenv pytest pytest-xdist pytest-timeout


FROM build AS hextype
RUN git clone https://github.com/abouquet27/HexType.git

RUN cd HexType && ./build.sh
RUN cd /HexType/build/bin
RUN mkdir /tmp/hextype/
ENV BUILD_DIR="/HexType/build"

COPY ./ /HexType/

CMD cd /HexType/ && python3.8 run_test.py -hextype