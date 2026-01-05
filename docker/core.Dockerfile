FROM ubuntu:24.04

SHELL ["/bin/bash", "-c"]

RUN apt -y update
# install open5gs and mongodb dependencies and helper softwares
RUN DEBIAN_FRONTEND=noninteractive apt install -y gnupg python3-pip python3-setuptools \
    python3-wheel ninja-build build-essential flex bison git cmake libsctp-dev libgnutls28-dev \
    libgcrypt-dev libssl-dev libmongoc-dev libbson-dev libyaml-dev libnghttp2-dev libmicrohttpd-dev \
    libcurl4-gnutls-dev libnghttp2-dev libtins-dev libtalloc-dev meson libidn11-dev \
    tmux git curl netcat-openbsd

# install mongodb
RUN curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | \
    gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg \
    --dearmor
RUN echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-8.0.list
RUN apt -y update
RUN apt install -y mongodb-org

# install Open5GS
# RUN git clone https://github.com/open5gs/open5gs
# RUN cd open5gs && meson build --prefix=`pwd`/install && ninja -C build && cd build && ninja install

# copy scripts and configs
COPY scripts/initRoaming.sh .
# COPY scripts/initCore.sh .
COPY configs/* .