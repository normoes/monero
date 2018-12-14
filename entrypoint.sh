#!/bin/bash

LOGGING="--log-level $LOG_LEVEL"

DAEMON_OPTIONS="--daemon-host $DAEMON_HOST --daemon-port $DAEMON_PORT"

# used for monerod and monero-wallet-rpc
RPC_OPTIONS="$LOGGING --confirm-external-bind --rpc-bind-ip $RPC_BIND_IP --rpc-bind-port $RPC_BIND_PORT"
# used for monerod
MONEROD_OPTIONS="--p2p-bind-ip $P2P_BIND_IP --p2p-bind-port $P2P_BIND_PORT"

MONEROD="monerod $@ $RPC_OPTIONS $MONEROD_OPTIONS --check-updates disabled"

# COMMAND="$@"

if [[ "${1:0:1}" = '-' ]]  || [[ -z "$@" ]]; then
  set -- $MONEROD
elif [[ "$1" = monero-wallet-rpc* ]]; then
  set -- "$@ $DAEMON_OPTIONS $RPC_OPTIONS"
  # prefix="monero-wallet-rpc"
  # COMMAND=${COMMAND#$prefix}
  # set -- "$prefix $COMMAND $RPC_OPTIONS"
elif [[ "$1" = monero-wallet-cli* ]]; then
  set -- "$@ $DAEMON_OPTIONS $LOGGING"
  # prefix="monero-wallet-cli"
  # COMMAND=${COMMAND#$prefix}
  # set -- "$prefix $COMMAND $LOGGING"
fi

echo "$@"

# allow the container to be started with `--user
if [ "$(id -u)" = 0 ]; then
  # USER_ID defaults to 1000 (Dockerfile)
  adduser --system --group --uid "$USER_ID" --shell /bin/false monero &> /dev/null
  exec su-exec monero $@
fi

exec $@
