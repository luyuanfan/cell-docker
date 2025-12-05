FROM ubuntu:22.04

SHELL ["/bin/bash", "-c"]

# Install dependencies
RUN apt -y update
RUN DEBIAN_FRONTEND=noninteractive apt install -y tcpdump iptables net-tools python3-pip python3-setuptools python3-wheel ninja-build build-essential flex bison git libsctp-dev libgnutls28-dev libgcrypt-dev libssl-dev libidn11-dev libmongoc-dev libbson-dev libyaml-dev libnghttp2-dev libmicrohttpd-dev libcurl4-gnutls-dev libnghttp2-dev libtins-dev libtalloc-dev meson iproute2 netcat tshark cmake nano iputils-ping jq software-properties-common gnuradio curl
RUN DEBIAN_FRONTEND=noninteractive apt install -y make gcc g++ pkg-config libfftw3-dev libmbedtls-dev libsctp-dev libyaml-cpp-dev libgtest-dev libuhd-dev uhd-host

# Build srsRAN 5g from source
RUN git clone https://github.com/srsRAN/srsRAN_Project.git
RUN cd srsRAN_Project && git checkout release_25_04 && mkdir build && cd build && cmake ../ && make -j $(nproc) && make install && ldconfig

# Download USRP images
RUN uhd_images_downloader

# Copy scripts and configs
COPY scripts/initGnb.sh .
COPY configs/gnb.yml .
COPY configs/cu.yml .
COPY configs/du_b200.yml .
COPY configs/du_b205.yml .