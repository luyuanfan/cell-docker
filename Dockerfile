FROM ubuntu:20.04

SHELL ["/bin/bash", "-c"]

# Install dependencies
RUN apt -y update
RUN DEBIAN_FRONTEND=noninteractive apt install -y tcpdump iptables net-tools python3-pip python3-setuptools python3-wheel ninja-build build-essential flex bison git libsctp-dev libgnutls28-dev libgcrypt-dev libssl-dev libidn11-dev libmongoc-dev libbson-dev libyaml-dev libnghttp2-dev libmicrohttpd-dev libcurl4-gnutls-dev libnghttp2-dev libtins-dev libtalloc-dev meson iproute2 netcat tshark cmake nano iputils-ping jq libuhd-dev uhd-host  software-properties-common 

# Install srsRAN 4G
# RUN apt install libfftw3-dev libmbedtls-dev libboost-program-options-dev libconfig++-dev libsctp-dev
RUN add-apt-repository ppa:softwareradiosystems/srsran
RUN apt-get update
RUN apt-get install srsran -y

# Install USRP Hardware Driver
RUN add-apt-repository ppa:ettusresearch/uhd
# Download FPGA images
RUN /usr/lib/uhd/utils/uhd_images_downloader.py

# Install MongoDB Packages
RUN curl -fsSL https://pgp.mongodb.com/server-8.0.asc | gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg --dearmor
RUN echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/8.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-8.0.list
RUN apt update
RUN apt install -y mongodb-org

# Installing Open5GS
RUN add-apt-repository ppa:open5gs/latest
RUN apt update
RUN apt install -y open5gs

# Open5GS from source
# RUN git clone https://github.com/open5gs/open5gs
# WORKDIR open5gs
# #RUN git checkout 85f150c
# RUN meson build --prefix=/open5gs/install
# WORKDIR build
# RUN ninja
# WORKDIR /

COPY tune.sh .