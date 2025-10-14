FROM ubuntu:20.04

SHELL ["/bin/bash", "-c"]

# Install dependencies
RUN apt -y update
RUN DEBIAN_FRONTEND=noninteractive apt install -y tcpdump iptables net-tools python3-pip python3-setuptools python3-wheel ninja-build build-essential flex bison git libsctp-dev libgnutls28-dev libgcrypt-dev libssl-dev libidn11-dev libmongoc-dev libbson-dev libyaml-dev libnghttp2-dev libmicrohttpd-dev libcurl4-gnutls-dev libnghttp2-dev libtins-dev libtalloc-dev meson iproute2 netcat tshark cmake nano iputils-ping jq libuhd-dev uhd-host  software-properties-common

# Install mongodb
RUN curl -fsSL https://pgp.mongodb.com/server-8.0.asc | gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg --dearmor
RUN echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/8.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-8.0.list
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
RUN add-apt-repository -y ppa:softwareradiosystems/srsran
RUN apt update -y
RUN apt-get install srsran -y

# Download USRP images
RUN /usr/lib/uhd/utils/uhd_images_downloader.py

# Copy scripts and files
COPY scripts/initOperator.sh .
COPY configs/config.yaml .
COPY configs/enb.conf .
COPY configs/rb.conf .
COPY configs/rr.conf .
COPY configs/sib.conf .
