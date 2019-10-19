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
    apt-get install -y git curl && \
    mkdir -p /nonexistent && \
    chown nobody: /nonexistent /data
RUN curl -sLo /tmp/jormungandr.tgz https://github.com/input-output-hk/jormungandr/releases/download/v${JORMUNGANDR_VERSION}/jormungandr-v${JORMUNGANDR_VERSION}-x86_64-unknown-linux-gnu.tar.gz && \
    cd /usr/local/bin && \
    tar -zxvf /tmp/jormungandr.tgz && \
    chmod +x jcli jormungandr

USER nobody
ENV HOME /nonexistent
RUN curl -sSL https://raw.githubusercontent.com/rcmorano/baids/master/baids | bash -s install
RUN curl -sLo ~/.baids/functions.d/10-bash-yaml https://raw.githubusercontent.com/jasperes/bash-yaml/master/script/yaml.sh

RUN cd $HOME && \
    git clone --recurse-submodules https://github.com/input-output-hk/jormungandr && \
    cd jormungandr && \
    git checkout $JORMUNGANDR_COMMIT && \
    git submodule update --recursive


ENTRYPOINT ["/usr/local/bin/entrypoint"]
