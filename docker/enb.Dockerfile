FROM ubuntu:24.04

SHELL ["/bin/bash", "-c"]

RUN apt -y update
# install uhd (rf driver), srsran dependencies, and helper softwares
RUN DEBIAN_FRONTEND=noninteractive apt install -y \
    build-essential libuhd-dev uhd-host libboost-program-options-dev libconfig++-dev \ 
    cmake make gcc g++ pkg-config libfftw3-dev libmbedtls-dev libsctp-dev libyaml-cpp-dev libgtest-dev \
    tmux git 

# build srsRAN 4G from source
RUN git clone https://github.com/srsran/srsRAN_4G.git
# RUN cd srsRAN_4G && mkdir build && cd build && cmake ../ && make -j $(nproc) && make install && srsran_install_configs.sh user && ldconfig
RUN cd srsRAN_4G && mkdir build && cd build && cmake ../ && make -j $(nproc) && make install && ldconfig

# RUN DEBIAN_FRONTEND=noninteractive apt install -y software-properties-common
# RUN add-apt-repository ppa:softwareradiosystems/srsran
# RUN apt-get update
# RUN apt-get install srsran -y

# download USRP images
RUN uhd_images_downloader

# copy scripts and configs
COPY scripts/initEnb.sh .
COPY configs/enb.conf .
COPY configs/rb.conf .
COPY configs/rr.conf .
COPY configs/sib.conf .