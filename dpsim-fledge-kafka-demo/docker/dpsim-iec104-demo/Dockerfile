# Adapted from the dpsim:dev Docker image

FROM fedora:34 AS base

LABEL \
	org.label-schema.schema-version = "1.0.0" \
	org.label-schema.name = "DPsim" \
	org.label-schema.license = "MPL 2.0" \
	org.label-schema.url = "http://dpsim.fein-aachen.org/" \
	org.label-schema.vcs-url = "https://github.com/sogno-platform/dpsim"

RUN dnf -y update

# Toolchain
RUN dnf -y install \
	gcc gcc-c++ clang \
	git \
	rpmdevtools rpm-build \
	make cmake pkgconfig \
	python3-pip \
	cppcheck

# Tools needed for developement
RUN dnf -y install \
	doxygen graphviz \
	gdb \
	procps-ng \
    procps

# Dependencies
RUN dnf --refresh -y install \
	python3-devel \
	eigen3-devel \
	libxml2-devel \
	graphviz-devel \
	spdlog-devel \
	fmt-devel

# Build & Install sundials
RUN cd /tmp && \
	git clone --recursive https://github.com/LLNL/sundials.git && \
	mkdir -p sundials/build && cd sundials/build && \
	git checkout v3.2.1 && \
	cmake -DCMAKE_BUILD_TYPE=Release ..  && \
	make -j$(nproc) install

# CIMpp and VILLAS are installed here
ENV LD_LIBRARY_PATH="/usr/local/lib64:/usr/local/lib:${LD_LIBRARY_PATH}"
RUN ldconfig

# minimal VILLAS dependencies
RUN dnf -y install \
    openssl-devel \
    libuuid-devel \
    libcurl-devel \
    jansson-devel \
    libwebsockets-devel

# optional VILLAS dependencies
RUN dnf -y install \
  	mosquitto-devel \
	libconfig-devel \
  	libnl3-devel

# get DPsim source
RUN cd / && \
    git clone https://github.com/sogno-platform/dpsim.git dpsim && \
	cd dpsim && git checkout 13caf0ae47212a2bf3c0d70aabbe8434b34c90de

# Python dependencies
RUN pip3 install --upgrade wheel build
RUN pip3 install -r /dpsim/requirements.txt

# Install CIMpp from source
RUN cd /tmp && \
	git clone --recursive https://github.com/sogno-platform/libcimpp.git && \
	cd libcimpp && \
	git checkout ad5532a0e909065a939a1b14188efc532e0b977a && \
	mkdir -p build && cd build && \
	cmake -DCMAKE_INSTALL_LIBDIR=/usr/local/lib64 -DUSE_CIM_VERSION=CGMES_2.4.15_16FEB2016 -DBUILD_SHARED_LIBS=ON -DBUILD_ARABICA_EXAMPLES=OFF .. && make -j$(nproc) install && \
	rm -rf /tmp/libcimpp

# Install lib60870 for VILLASnode
RUN cd /tmp && \
	git clone https://github.com/mz-automation/lib60870.git && \
	cd lib60870 && \
	git checkout 5741f28c122f83982ff3b8e20137b7db5c66eb70 && \
	mkdir -p build && cd build && \
	cmake -DCMAKE_INSTALL_DIR=/usr/local ../lib60870-C && make -j$(nproc) install && \
	rm -rf /tmp/lib60870

# Install VILLAS from source
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

# install VILLASnode
RUN cd /tmp && \
	git clone --recursive https://github.com/VILLASframework/node.git villasnode && \
	cd villasnode && \
	git checkout 37c9efad92de55f62bd74af97eb755e9b350390e && \
	mkdir -p build && cd build && \
	cmake -DDOWNLOAD_GO=OFF -DCMAKE_INSTALL_LIBDIR=/usr/local/lib64 .. && \
	make -j$(nproc) install && \
	rm -rf /tmp/villasnode

WORKDIR /dpsim

# build DPsim + Villas Interface
RUN sed -iE \
	-e "s|\('--target', 'dpsimpy'\)|\1, '--target', 'dpsimpyvillas'|" \
	-e "s|\(CMakeExtension('dpsimpy')\)|\1, CMakeExtension('dpsimpyvillas')|" \
	setup.py && \
	python setup.py build && \
	python setup.py install

ADD start.sh /start.sh

ARG DPSIM_DEFAULT_SIMULATION_FILE=simulation.py
ADD ${DPSIM_DEFAULT_SIMULATION_FILE} /default_simulation.py

ENV DPSIM_SIMULATION_FILE=/default_simulation.py
CMD [ "sh", "/start.sh" ]
