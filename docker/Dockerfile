FROM ubuntu:22.04

########NOTES########
# srsran package does not have distribution for ubuntu version above 22.04
# x410 requires uhd version 4.1.0

SHELL ["/bin/bash", "-c"]

# Install dependencies
RUN apt -y update
RUN DEBIAN_FRONTEND=noninteractive apt install -y tcpdump iptables net-tools python3-pip python3-setuptools python3-wheel ninja-build build-essential flex bison git libsctp-dev libgnutls28-dev libgcrypt-dev libssl-dev libidn11-dev libmongoc-dev libbson-dev libyaml-dev libnghttp2-dev libmicrohttpd-dev libcurl4-gnutls-dev libnghttp2-dev libtins-dev libtalloc-dev meson iproute2 netcat tshark cmake nano iputils-ping jq libuhd-dev uhd-host software-properties-common gnuradio 
# For srsRAN_Project build from source
# RUN DEBIAN_FRONTEND=noninteractive apt install -y libfftw3-dev libmbedtls-dev libboost-program-options-dev libconfig++-dev libsctp-dev
RUN DEBIAN_FRONTEND=noninteractive apt install -y make gcc g++ pkg-config libfftw3-dev libmbedtls-dev libsctp-dev libyaml-cpp-dev libgtest-dev

# Install mongodb
RUN curl -fsSL https://pgp.mongodb.com/server-8.0.asc | gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg --dearmor
# For Focal 20.04: 
# RUN echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/8.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-8.0.list
# For Jammy 22.04:  
RUN echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/8.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-8.0.list
# For Noble Numbat 24.04:
# RUN echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-8.0.list
RUN apt update
RUN apt install -y mongodb-org

# Install Open5GS
RUN git clone https://github.com/open5gs/open5gs
WORKDIR open5gs
#RUN git checkout 85f150c
RUN meson build --prefix=/open5gs/install
WORKDIR build
RUN ninja
WORKDIR /

# Install srsRAN
# RUN add-apt-repository -y ppa:softwareradiosystems/srsran
# RUN apt update -y
# RUN apt-get install srsran -y

# Build srsRAN 4G from source
# RUN git clone https://github.com/srsRAN/srsRAN_4G.git
# RUN cd srsRAN_4G && git checkout release_22_10 && git rev-parse HEAD && mkdir build && cd build && cmake ../ -DUSE_LTE_RATES=ON && make && make install && ldconfig

# Build srsRAN 5g from source
RUN git clone https://github.com/srsRAN/srsRAN_Project.git
RUN cd srsRAN_Project && mkdir build && cd build && cmake ../ && make -j $(nproc) && make install && ldconfig

# Download USRP images
RUN /usr/lib/uhd/utils/uhd_images_downloader.py
# When setting up for the first time, comment out the next line to match all compat numbers
# RUN uhd_image_loader --args="type=x300,addr=192.168.30.2"

# Copy scripts and files
COPY scripts/initOperator.sh .
COPY configs/config.yaml .

# COPY configs/enb.conf .
# COPY configs/rb.conf .
# COPY configs/rr.conf .
# COPY configs/sib.conf .

# gNB files
COPY configs/gnb.yml .