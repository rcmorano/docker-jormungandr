FROM ubuntu

RUN mkdir -p /nonexistent /data && \
    chown nobody: /nonexistent /data
VOLUME ["/data"]
WORKDIR /data
ENV DATA_DIR /data
ENV PUBLIC_PORT 8299
ENV JORMUNGANDR_RESTAPI_URL http://localhost:8443/api
ARG JORMUNGANDR_VERSION=0.6.5
ENV JORMUNGANDR_VERSION ${JORMUNGANDR_VERSION}
ARG JORMUNGANDR_COMMIT=v0.6.5
ENV JORMUNGANDR_COMMIT ${JORMUNGANDR_COMMIT}

RUN apt-get update -qq && \
    apt-get install -y git curl sudo net-tools iproute2

RUN curl -sLo /tmp/jormungandr.tgz https://github.com/input-output-hk/jormungandr/releases/download/v${JORMUNGANDR_VERSION}/jormungandr-v${JORMUNGANDR_VERSION}-x86_64-unknown-linux-gnu.tar.gz && \
    cd /usr/local/bin && \
    tar -zxvf /tmp/jormungandr.tgz && \
    chmod +x jcli jormungandr

USER nobody
ENV HOME /nonexistent
RUN curl -sSL https://raw.githubusercontent.com/rcmorano/baids/master/baids | bash -s install && \
    curl -sLo ~/.baids/functions.d/10-bash-yaml https://raw.githubusercontent.com/jasperes/bash-yaml/master/script/yaml.sh && \
    jcli auto-completion bash ${HOME}/.baids/functions.d

RUN cd $HOME && \
    git clone --recurse-submodules https://github.com/input-output-hk/jormungandr && \
    cd jormungandr && \
    git checkout $JORMUNGANDR_COMMIT && \
    git submodule update --recursive
USER root
COPY ./assets/bin/entrypoint /usr/local/bin/entrypoint
ENTRYPOINT ["/bin/bash", "-c", "chown -R nobody: /data; sudo -EHu nobody /usr/local/bin/entrypoint"]
