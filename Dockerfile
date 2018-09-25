FROM debian:stable-slim

# BUILD_PATH:
# v0.12.3.0: /monero/build/release/bin
# master:    /monero/build/Linux/master/release/bin

ARG MONERO_URL=https://github.com/monero-project/monero.git
# master branch
ARG BRANCH=master
ARG BUILD_PATH=/monero/build/Linux/master/release/bin
# specific branch
#ARG BRANCH=v0.12.3.0
#BUILD_PATH=/monero/build/release/bin
ARG USER_ID=500

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

#COPY --from=build /data/monero/build/Linux/master/release/bin /data
COPY entrypoint.sh /entrypoint.sh

RUN apt-get purge -y git \
    && apt-get autoremove --purge -y \
    && rm -rf /var/tmp/* /tmp/* /var/lib/apt/lists/* \
    && mv /data$BUILD_PATH/monerod /usr/local/bin/ \
    && mv /data$BUILD_PATH/monero-wallet-rpc /usr/local/bin/ \
    && rm -rf /data \
    && adduser --system --group --uid $USER_ID --no-create-home --shell /bin/false monero \
    && chmod +x /entrypoint.sh

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
