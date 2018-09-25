#!/bin/bash

# used for monerod and monero-wallet-rpc
OPTIONS="--log-level=$LOG_LEVEL --confirm-external-bind --rpc-bind-ip=$RPC_BIND_IP --rpc-bind-port=$RPC_BIND_PORT"
# used for monerod
MONEROD_OPTIONS="--p2p-bind-ip=$P2P_BIND_IP --p2p-bind-port=$P2P_BIND_PORT"

MONEROD="monerod $@ $OPTIONS $MONEROD_OPTIONS --check-updates disabled"

if [[ "${1:0:1}" = '-' ]]  || [[ -z "$@" ]]; then
  set -- $MONEROD
else
  set -- "$@ $OPTIONS"
fi

exec $@
