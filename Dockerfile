#FROM rust:1.38-alpine AS build-from-src
#
#ARG JORMUNGANDR_COMMIT=v0.6.5
#ENV JORMUNGANDR_COMMIT ${JORMUNGANDR_COMMIT}
#WORKDIR /usr/src
#
#RUN rustup install stable && \
#    rustup default stable && \
#    apk add --no-cache curl bash git
#
#RUN git clone --recurse-submodules https://github.com/input-output-hk/jormungandr && \
#    cd jormungandr && \
#    git checkout $JORMUNGANDR_COMMIT && \
#    git submodule update --recursive && \
#    cargo build --release
#
#WORKDIR /usr/src/jormungandr
#
#ENTRYPOINT ["/usr/local/bin/entrypoint"]

FROM ubuntu

VOLUME ["/data"]
WORKDIR /data
ENV DATA_DIR /data
ENV PUBLIC_PORT 8299
ARG JORMUNGANDR_VERSION=0.6.5
ENV JORMUNGANDR_VERSION ${JORMUNGANDR_VERSION}
ARG JORMUNGANDR_COMMIT=v0.6.5
ENV JORMUNGANDR_COMMIT ${JORMUNGANDR_COMMIT}

COPY ./assets/bin/entrypoint /usr/local/bin/entrypoint

RUN apt-get update -qq && \
    apt-get install -y git curl

RUN cd /usr/local/src && \
    git clone --recurse-submodules https://github.com/input-output-hk/jormungandr && \
    cd jormungandr && \
    git checkout $JORMUNGANDR_COMMIT && \
    git submodule update --recursive


RUN curl -sLo /tmp/jormungandr.tgz https://github.com/input-output-hk/jormungandr/releases/download/v${JORMUNGANDR_VERSION}/jormungandr-v${JORMUNGANDR_VERSION}-x86_64-unknown-linux-gnu.tar.gz && \
    cd /usr/local/bin && \
    tar -zxvf /tmp/jormungandr.tgz && \
    chmod +x jcli jormungandr 

ENTRYPOINT ["/usr/local/bin/entrypoint"]
