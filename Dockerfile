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

ENV VALIDATOR /bbx/validator
ENV BASE_URL https://s3-us-west-1.amazonaws.com/bioboxes-tools/validate-biobox-file
ENV VERSION 0.x.y
RUN mkdir -p ${VALIDATOR}
RUN wget \
      --quiet \
      --output-document -\
      ${BASE_URL}/${VERSION}/validate-biobox-file.tar.xz \
    | tar -xJf - \
      --directory ${VALIDATOR} \
      --strip-components=1
ENV PATH ${PATH}:${VALIDATOR}
RUN wget \
    --output-document /schema.yaml \
    https://raw.githubusercontent.com/bioboxes/rfc/master/container/binning/input_schema.yaml

WORKDIR /usr/local/bin
ENV CONVERT https://github.com/bronze1man/yaml2json/releases/download/v1.3/yaml2json_linux_amd64
RUN wget --output-document yaml2json --quiet ${CONVERT} && chmod 700 yaml2json
ENV JQ http://stedolan.github.io/jq/download/linux64/jq
RUN wget --quiet ${JQ} && chmod 700 jq
ADD Taskfile /

WORKDIR /
