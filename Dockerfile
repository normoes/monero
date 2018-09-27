FROM debian:stable-slim as builder

# BUILD_PATH:
# v0.12.3.0: /monero/build/release/bin
# v0.13.0.1-RC1: /monero/build/Linux/_no_branch_/release/bin
# master:    /monero/build/Linux/master/release/bin

ARG MONERO_URL=https://github.com/monero-project/monero.git
# master branch
ARG BRANCH=master
ARG BUILD_PATH=/monero/build/Linux/master/release/bin
# specific branch
#ARG BRANCH=v0.12.3.0
#BUILD_PATH=/monero/build/release/bin
#ARG BRANCH=v0.13.0.1-RC1

WORKDIR /data

RUN apt-get update && apt-get -y install \
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

#RUN git clone --recursive $MONERO_URL
RUN git clone -b "$BRANCH" --single-branch --depth 1 --recursive $MONERO_URL
RUN cd monero \
    && make
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
    && rm -rf /var/tmp/* /tmp/* /var/lib/apt/lists/* \
    && mv /data$BUILD_PATH/monerod /data/ \
    && chmod +x /data/monerod \
    && mv /data$BUILD_PATH/monero-wallet-rpc /data/ \
    && chmod +x /data/monero-wallet-rpc \
    && rm -rf /monero

FROM debian:stable-slim
ARG USER_ID=500
COPY --from=builder /data/monerod /usr/local/bin/
COPY --from=builder /data/monero-wallet-rpc /usr/local/bin/
COPY entrypoint.sh /entrypoint.sh

RUN apt-get update && apt-get install -y \
          libboost-all-dev \
          libzmq3-dev \
          libunbound-dev \
          libexpat1-dev \
    && apt-get autoremove --purge -y \
    && rm -rf /var/tmp/* /tmp/* /var/lib/apt/lists/*

RUN adduser --system --group --uid $USER_ID --shell /bin/false monero \
    && chmod +x /entrypoint.sh \
    && rm -rf /data

# switch user
USER monero

WORKDIR /monero
VOLUME ["/monero"]

ENV LOG_LEVEL 0
ENV RPC_BIND_IP 0.0.0.0
ENV RPC_BIND_PORT 28081
ENV P2P_BIND_IP 0.0.0.0
ENV P2P_BIND_PORT 28080

ENTRYPOINT ["/entrypoint.sh"]
