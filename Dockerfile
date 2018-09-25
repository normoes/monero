FROM debian:stable-slim


ARG MONERO_SHA256=72fe937aa2832a0079767914c27671436768ff3c486597c3353a8567d9547487
ARG MONERO_VERSION=0.12.3.0
ARG ARCH_TYPE=x64
ARG USER_ID=500

WORKDIR /data

# libpcsclite1 as dependency for monero since 0.12.0.0/0.12.2.0
RUN apt-get update && apt-get install -y \
          bzip2 \
          curl \
          libpcsclite1 \
    && curl https://downloads.getmonero.org/cli/monero-linux-$ARCH_TYPE-v$MONERO_VERSION.tar.bz2 -O \
    && echo "$MONERO_SHA256  monero-linux-$ARCH_TYPE-v$MONERO_VERSION.tar.bz2" | sha256sum -c - \
    && tar -xjvf monero-linux-$ARCH_TYPE-v$MONERO_VERSION.tar.bz2 \
    && rm monero-linux-$ARCH_TYPE-v$MONERO_VERSION.tar.bz2 \
    && cp ./monero-v$MONERO_VERSION/monerod /usr/local/bin/ \
    && chmod +x /usr/local/bin/monerod \
    && cp ./monero-v$MONERO_VERSION/monero-wallet-rpc /usr/local/bin/ \
    && chmod +x /usr/local/bin/monero-wallet-rpc \
    && rm -rf /data \
    && apt-get purge -y curl bzip2 \
    && apt-get autoremove --purge -y \
    && rm -rf /var/tmp/* /tmp/* /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh

RUN adduser --system --group --uid $USER_ID --no-create-home --shell /bin/false monero \
    && chmod +x /entrypoint.sh

# switch user
USER monero

WORKDIR /monero
VOLUME ["/monero"]

ENV LOG_LEVEL 0
ENV RPC_BIND_IP 0.0.0.0
ENV RPC_BIND_PORT 18081
ENV P2P_BIND_IP 0.0.0.0
ENV P2P_BIND_PORT 18080

ENTRYPOINT ["/entrypoint.sh"]
