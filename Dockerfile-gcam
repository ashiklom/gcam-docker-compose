FROM debian:stretch

RUN apt-get update && apt-get install -y --no-install-recommends \
        make \
        g++ \
        unzip \
        wget \
        libboost-dev \
        libboost-system-dev \
        libboost-filesystem-dev \
        libxerces-c-dev \
        default-jre-headless \
        default-jdk-headless && \
	rm -rf /var/lib/apt/lists/*

ENV USRLIB=/usr/lib/x86_64-linux-gnu
ENV BOOST_LIB=$USRLIB
ENV BOOST_INCLUDE=/usr/include/boost
ENV BOOSTLIB=$BOOST_LIB
ENV XERCES_LIB=$USRLIB
ENV XERCES_INCLUDE=/usr/include/xercesc
ENV JAVA_INCLUDE=/usr/lib/jvm/default-java/include
ENV JAVA_LIB=/usr/lib/jvm/default-java/jre/lib/amd64/server

# Download model interface java libraries from the 5.1 GitHub release
RUN wget https://github.com/JGCRI/modelinterface/releases/download/v5.1/ModelInterface.zip && \
        unzip ModelInterface.zip
ENV JARS_LIB=/ModelInterface/jars/*

RUN mkdir -p /gcam
COPY . /gcam
WORKDIR /gcam

# To compile in parallel with 8 cores, run a command like:
# docker build . --build-arg NCPU=8
ARG NCPU=1

RUN make gcam -j $NCPU
