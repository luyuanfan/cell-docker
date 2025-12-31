FROM ubuntu:24.04

SHELL ["/bin/bash", "-c"]

RUN apt -y update
# install uhd (rf driver), srsran dependencies, and helper softwares
RUN DEBIAN_FRONTEND=noninteractive apt install -y libuhd-dev uhd-host \ 
    cmake make gcc g++ pkg-config libfftw3-dev libmbedtls-dev libsctp-dev libyaml-cpp-dev libgtest-dev \ 
    tmux git

# build srsRAN 5g from source
RUN git clone https://github.com/srsRAN/srsRAN_Project.git
RUN cd srsRAN_Project && git checkout release_25_04 && mkdir build && cd build && cmake ../ && make -j $(nproc) && make install && ldconfig

# download USRP images
RUN uhd_images_downloader

# copy scripts and configs
COPY scripts/initGnb.sh .
COPY configs/gnb.yml .
COPY configs/cu.yml .
COPY configs/du_b200.yml .
COPY configs/du_b205.yml .