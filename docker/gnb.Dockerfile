FROM ubuntu:24.04

SHELL ["/bin/bash", "-c"]

RUN apt -y update
# install srsran dependencies and helper softwares
RUN DEBIAN_FRONTEND=noninteractive apt install -y \ 
cmake make gcc g++ pkg-config libfftw3-dev libmbedtls-dev libsctp-dev libyaml-cpp-dev libgtest-dev \ 
tmux git
# install uhd dependencies
RUN DEBIAN_FRONTEND=noninteractive apt install -y \ 
    autoconf automake build-essential ccache cmake cpufrequtils doxygen ethtool \
    g++ git inetutils-tools libboost-all-dev libncurses5-dev libusb-1.0-0 libusb-1.0-0-dev \
    libusb-dev python3-dev python3-mako python3-numpy python3-requests python3-scipy python3-setuptools \
    python3-ruamel.yaml 

# build uhd from source
RUN git clone https://github.com/EttusResearch/uhd.git
RUN cd uhd && git checkout v4.8.0.0 && cd host && mkdir build && cd build && cmake ../ && make -j $(nproc) && make install && ldconfig

# build srsRAN 5g from source
RUN git clone https://github.com/srsRAN/srsRAN_Project.git
RUN cd srsRAN_Project && git checkout release_25_04 && mkdir build && cd build && cmake ../ && make -j $(nproc) && make install && ldconfig

# download USRP images
RUN uhd_images_downloader

# copy scripts and configs
COPY scripts/initGnb.sh .
COPY configs/gnb.yml .