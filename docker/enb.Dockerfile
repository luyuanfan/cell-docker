FROM ubuntu:24.04

SHELL ["/bin/bash", "-c"]

RUN apt -y update
# install uhd (rf driver), srsran dependencies, and helper softwares
RUN DEBIAN_FRONTEND=noninteractive apt install -y libuhd-dev uhd-host \ 
    cmake make gcc g++ pkg-config libfftw3-dev libmbedtls-dev libsctp-dev libyaml-cpp-dev libgtest-dev \ 
    tmux git software-properties-common build-essential libboost-program-options-dev libconfig++-dev

# build srsRAN 4G from source
RUN git clone https://github.com/srsran/srsRAN_4G.git
RUN cd srsRAN_4G && mkdir build && cd build && cmake ../ -DUSE_LTE_RATES=ON && make -j $(nproc) && make install && srsran_install_configs.sh user && ldconfig

# download USRP images
RUN uhd_images_downloader

# copy scripts and configs
COPY scripts/initEnb.sh .
COPY configs/enb.conf .
COPY configs/rb.conf .
COPY configs/rr.conf .
COPY configs/sib.conf .