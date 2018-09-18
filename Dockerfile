FROM debian:stable-slim as build

RUN apt-get update && apt-get install -y \
          bzip2 \
          curl

ARG MONERO_SHA256=72fe937aa2832a0079767914c27671436768ff3c486597c3353a8567d9547487
ARG MONERO_VERSION=0.12.3.0
ARG ARCH_TYPE=x64

WORKDIR /data

RUN curl https://downloads.getmonero.org/cli/monero-linux-$ARCH_TYPE-v$MONERO_VERSION.tar.bz2 -O \
  && echo "$MONERO_SHA256  monero-linux-$ARCH_TYPE-v$MONERO_VERSION.tar.bz2" | sha256sum -c - \
  && tar -xjvf monero-linux-$ARCH_TYPE-v$MONERO_VERSION.tar.bz2 \
  && rm monero-linux-$ARCH_TYPE-v$MONERO_VERSION.tar.bz2 \
  && cp ./monero-v$MONERO_VERSION/monerod . \
  && chmod +x monerod \
  && cp ./monero-v$MONERO_VERSION/monero-wallet-rpc . \
  && chmod +x monero-wallet-rpc \
  && rm -r monero-v$MONERO_VERSION \
  && apt-get purge -y curl bzip2 \
  && apt-get autoremove --purge -y \
  && rm -rf /var/tmp/* /tmp/* /var/lib/apt/lists/*


FROM ubuntu:16.04

COPY --from=build /data /data
COPY entrypoint.sh /entrypoint.sh

# libpcsclite1 as dependency for monero since 0.12.0.0/0.12.2.0
RUN apt-get update && apt-get install -y libpcsclite1 \
  && apt-get autoremove --purge -y \
  && rm -rf /var/tmp/* /tmp/* /var/lib/apt/lists/* \
  && adduser --system --group --uid 1000 --no-create-home --shell /bin/false monero \
  && chmod +x /entrypoint.sh \
  && mv /data/* /usr/local/bin/ \
  && rm -rf /data

# switch user
USER monero

WORKDIR /monero
VOLUME ["/monero"]

ENV LOG_LEVEL 0
ENV RPC_BIND_IP 0.0.0.0
ENV RPC_BIND_PORT 18081

ENTRYPOINT ["/entrypoint.sh"]
