FROM debian:stable-slim as builder

WORKDIR /data

RUN apt-get update -qq && apt-get -y install \
        build-essential \
        cmake \
        pkg-config \
        libboost-all-dev \
        libssl-dev \
        libzmq3-dev \
        libpgm-dev \
        libunbound-dev \
        libsodium-dev \
        libunwind8-dev \
        liblzma-dev \
        libreadline6-dev \
        libldns-dev \
        libexpat1-dev \
        doxygen \
        graphviz \
        libpcsclite-dev \
        libgtest-dev \
        git \
    && cd /usr/src/gtest \
    && cmake . \
    && make \
    && mv libg* /usr/lib/


RUN cd /data \
    && git clone https://github.com/ncopa/su-exec.git su-exec-clone \
    && cd su-exec-clone \
    && make \
    && cp su-exec /data

# BUILD_PATH:
# v0.12.3.0: /monero/build/release/bin
# v0.13.0.1-RC1: /monero/build/Linux/_no_branch_/release/bin
# master:    /monero/build/Linux/master/release/bin
# Using 'USE_SINGLE_BUILDDIR=1 make' creates a unified build dir (/monero/build/release/bin)

ARG MONERO_URL=https://github.com/monero-project/monero.git
ARG BRANCH
ARG BUILD_PATH=/monero/build/release/bin

RUN cd /data \
    && git clone -b "$BRANCH" --single-branch --depth 1 --recursive $MONERO_URL
RUN cd monero \
    && USE_SINGLE_BUILDDIR=1 make \
    && mv /data$BUILD_PATH/monerod /data/ \
    && chmod +x /data/monerod \
    && mv /data$BUILD_PATH/monero-wallet-rpc /data/ \
    && chmod +x /data/monero-wallet-rpc \
    && mv /data$BUILD_PATH/monero-wallet-cli /data/ \
    && chmod +x /data/monero-wallet-cli

RUN apt-get purge -y \
        build-essential \
        cmake \
        libboost-all-dev \
        libssl-dev \
        libzmq3-dev \
        libpgm-dev \
        libunbound-dev \
        libsodium-dev \
        libunwind8-dev \
        liblzma-dev \
        libreadline6-dev \
        libldns-dev \
        libexpat1-dev \
        doxygen \
        graphviz \
        libpcsclite-dev \
        libgtest-dev \
        git \
    && apt-get autoremove --purge -y \
    && apt-get clean \
    && rm -rf /var/tmp/* /tmp/* /var/lib/apt \
    && rm -rf /data/monero \
    && rm -rf /data/su-exec-clone

# /var/lib/apt/lists/* \

FROM debian:stable-slim
COPY --from=builder /data/monerod /usr/local/bin/
COPY --from=builder /data/monero-wallet-rpc /usr/local/bin/
COPY --from=builder /data/monero-wallet-cli /usr/local/bin/
COPY --from=builder /data/su-exec /usr/local/bin/

RUN apt-get update -qq && apt-get install -y \
        libboost-all-dev \
        libzmq3-dev \
        libunbound-dev \
        libexpat1-dev \
        torsocks \
    && apt-get autoremove --purge -y \
    && apt-get clean \
    && rm -rf /var/tmp/* /tmp/* /var/lib/apt

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
COPY torsocks.conf /etc/tor/torsocks.conf

WORKDIR /monero

RUN monerod --version > /version.txt \
    && cat /etc/os-release > /system.txt \
    && ldd $(command -v monerod) > /dependencies.txt \
    && torsocks --version > /torsocks.txt

VOLUME ["/monero"]

ENV USER_ID 1000
ENV LOG_LEVEL 0
ENV DAEMON_HOST 127.0.0.1
ENV DAEMON_PORT 28081
ENV RPC_BIND_IP 0.0.0.0
ENV RPC_BIND_PORT 28081
ENV P2P_BIND_IP 0.0.0.0
ENV P2P_BIND_PORT 28080
ENV USE_TORSOCKS NO

ENTRYPOINT ["/entrypoint.sh"]
