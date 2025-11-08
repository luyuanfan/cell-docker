FROM ubuntu:22.04

SHELL ["/bin/bash", "-c"]

# Install dependencies
RUN apt -y update
RUN DEBIAN_FRONTEND=noninteractive apt install -y tcpdump iptables net-tools python3-pip python3-setuptools python3-wheel ninja-build build-essential flex bison git libsctp-dev libgnutls28-dev libgcrypt-dev libssl-dev libidn11-dev libmongoc-dev libbson-dev libyaml-dev libnghttp2-dev libmicrohttpd-dev libcurl4-gnutls-dev libnghttp2-dev libtins-dev libtalloc-dev meson iproute2 netcat tshark cmake nano iputils-ping jq software-properties-common gnuradio curl
RUN DEBIAN_FRONTEND=noninteractive apt install -y make gcc g++ pkg-config libfftw3-dev libmbedtls-dev libsctp-dev libyaml-cpp-dev libgtest-dev libuhd-dev uhd-host

# Install mongodb
RUN curl -fsSL https://pgp.mongodb.com/server-8.0.asc | gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg --dearmor
RUN echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/8.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-8.0.list
RUN apt update
RUN apt install -y mongodb-org

# Install Open5GS
RUN git clone https://github.com/open5gs/open5gs
RUN cd open5gs && meson build --prefix=`pwd`/install && ninja -C build && cd build && ninja install
WORKDIR /

# Build srsRAN 5g from source
RUN git clone https://github.com/srsRAN/srsRAN_Project.git
RUN cd srsRAN_Project && git checkout release_25_04 && mkdir build && cd build && cmake ../ && make -j $(nproc) && make install && ldconfig

# Download USRP images
RUN uhd_images_downloader

# Copy scripts and configs
COPY scripts/initOperator.sh .
COPY scripts/srsran_performance .
COPY configs/amf.yaml .
COPY configs/nrf.yaml .
COPY configs/upf.yaml .
COPY configs/smf.yaml .
COPY configs/gnb.yml .