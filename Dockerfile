FROM alpine AS src
RUN apk add --no-cache git
ARG JORMUNGANDR_COMMIT=v0.7.1
ENV JORMUNGANDR_COMMIT ${JORMUNGANDR_COMMIT}

RUN git clone https://github.com/input-output-hk/jormungandr /src && \
    cd /src && \
    git checkout $JORMUNGANDR_COMMIT && \
    git submodule init && \
    git submodule update --recursive

FROM ubuntu:bionic AS src-build

RUN apt-get update -qq && \
    apt-get install -qy build-essential pkg-config libssl-dev curl && \
    bash -c "curl https://sh.rustup.rs -sSf | bash -s -- -y"

COPY --from=src /src /src
# do stuff borrowed from https://github.com/input-output-hk/jormungandr/blob/master/docker/Dockerfile#L34
RUN cd /src && \
    export PATH=$HOME/.cargo/bin:$PATH && \
    rustup install stable && \
    rustup default stable && \
    cargo build --release && \
    cargo install --force --path jormungandr && \
    cargo install --force --path jcli && \
    mkdir -p /output && \
    mv $HOME/.cargo/bin/jormungandr $HOME/.cargo/bin/jcli /output


FROM ubuntu:bionic AS jormungandr
ARG JORMUNGANDR_VERSION=0.7.1
ENV JORMUNGANDR_VERSION ${JORMUNGANDR_VERSION}
LABEL jormungandr.version="${JORMUNGANDR_VERSION}"

RUN mkdir -p /nonexistent /data && \
    chown nobody: /nonexistent /data
ENV HOME /nonexistent
VOLUME ["/data"]
WORKDIR /data
ENV DATA_DIR /data
ENV PUBLIC_PORT 8299
ENV JORMUNGANDR_RESTAPI_URL http://localhost:8443/api
COPY --from=src-build /output/ /usr/local/bin/
COPY --from=src /src /src

RUN apt-get update -qq && \
    apt-get install -y git curl sudo net-tools iproute2 jq

USER nobody
RUN curl -sSL https://raw.githubusercontent.com/rcmorano/baids/master/baids | bash -s install && \
    echo source ~/.baids/baids > ~/.bashrc && \
    curl -sLo ~/.baids/functions.d/10-bash-yaml https://raw.githubusercontent.com/jasperes/bash-yaml/master/script/yaml.sh && \
    git clone https://github.com/rcmorano/baids-jormungandr.git ~/.baids/functions.d/jormungandr && \
    jcli auto-completion bash ${HOME}/.baids/functions.d

USER root
COPY ./assets/bin/entrypoint /usr/local/bin/entrypoint
ENTRYPOINT ["/bin/bash", "-c", "chown -R nobody: /data; sudo -EHu nobody /usr/local/bin/entrypoint"]
