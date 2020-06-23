FROM debian:stable
MAINTAINER Fabio Malcher Miranda, fabio.malchermiranda@hpi.de

ENV PACKAGES gcc \
             cmake \
             zlib1g-dev \
             git \
             python3 \
             python3-setuptools \
             python3-pip \
             python3-pandas \
             wget
RUN apt-get update && apt-get install --yes ${PACKAGES}

WORKDIR /opt
ENV SRC https://github.com/pirovc/ganon.git
RUN git clone --recurse-submodules ${SRC} # ganon, catch2, cxxopts, sdsl-lite, seqan
RUN git clone https://github.com/pirovc/taxsbp.git # taxsbp
WORKDIR /opt/taxsbp
RUN python3 setup.py install
RUN pip3 install binpacking==1.4.1
RUN mkdir /opt/ganon/build
WORKDIR /opt/ganon/build
RUN cmake -DCMAKE_BUILD_TYPE=Release -DVERBOSE_CONFIG=ON -DGANON_OFFSET=ON -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCONDA=OFF ..
RUN make
ENV PATH ${PATH}:/opt/ganon
WORKDIR /