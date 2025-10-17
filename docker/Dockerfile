FROM ubuntu:20.04

SHELL ["/bin/bash", "-c"]

# Build UHD from source

# Install dependencies
RUN apt -y update
RUN DEBIAN_FRONTEND=noninteractive apt install -y autoconf automake build-essential ccache cmake cpufrequtils doxygen ethtool fort77 g++ gir1.2-gtk-3.0 git gobject-introspection gpsd gpsd-clients inetutils-tools libasound2-dev libboost-all-dev libcomedi-dev libcppunit-dev libfftw3-bin libfftw3-dev libfftw3-doc libfontconfig1-dev libgmp-dev libgps-dev libgsl-dev liblog4cpp5-dev libncurses5 libncurses5-dev libpulse-dev libqt5opengl5-dev libqwt-qt5-dev libsdl1.2-dev libtool libudev-dev libusb-1.0-0 libusb-1.0-0-dev libusb-dev libxi-dev libxrender-dev libzmq3-dev libzmq5 ncurses-bin python3-cheetah python3-click python3-click-plugins python3-click-threading python3-dev python3-docutils python3-gi python3-gi-cairo python3-gps python3-lxml python3-mako python3-numpy python3-numpy-dbg python3-opengl python3-pyqt5 python3-requests python3-scipy python3-six python3-sphinx python3-yaml python3-zmq python3-ruamel.yaml swig wget tcpdump iptables net-tools python3-pip python3-setuptools python3-wheel ninja-build flex bison libsctp-dev libgnutls28-dev libgcrypt-dev libssl-dev libidn11-dev libmongoc-dev libbson-dev libyaml-dev libnghttp2-dev libmicrohttpd-dev libcurl4-gnutls-dev libnghttp2-dev libtins-dev libtalloc-dev meson iproute2 netcat tshark nano iputils-ping jq software-properties-common
# UHD packages version too low: libuhd-dev uhd-host

RUN git clone https://github.com/EttusResearch/uhd
WORKDIR uhd 
RUN git checkout v4.8.0.0
RUN git submodule update --init --recursive
RUN mkdir build 
RUN cmake .. -DCMAKE_INSTALL_PREFIX:PATH
WORKDIR build
RUN make
RUN make test
RUN make install
RUN ldconfig

# RUN git clone https://github.com/EttusResearch/uhd.git /uhd && \
#     cd /uhd && \
#     git checkout v4.8.0.0 && \
#     git submodule update --init --recursive && \
#     mkdir build && cd build && \
#     cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local && \
#     make -j$(nproc) && \
#     make install && \
#     ldconfig && \
#     /usr/local/lib/uhd/utils/uhd_images_downloader.py

WORKDIR /

# # Install dependencies
# RUN apt -y update
# RUN DEBIAN_FRONTEND=noninteractive apt install -y tcpdump iptables net-tools python3-pip python3-setuptools python3-wheel ninja-build build-essential flex bison git libsctp-dev libgnutls28-dev libgcrypt-dev libssl-dev libidn11-dev libmongoc-dev libbson-dev libyaml-dev libnghttp2-dev libmicrohttpd-dev libcurl4-gnutls-dev libnghttp2-dev libtins-dev libtalloc-dev meson iproute2 netcat tshark cmake nano iputils-ping jq software-properties-common
# # to build from source: libuhd-dev uhd-host

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
