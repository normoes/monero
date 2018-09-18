
For running `monerod` or `monero-wallet-rpc` in a docker container.

This daemon is explictitely made for `mainnet` and `stagenet`.

It runs monero `0.12.3.0`, `x64` and the docker image is based on   ubuntu:16.04  .


A `testnet` daemon will follow.

**Hint**:
The IPs, the daemon or RPC are binding to, need to be `0.0.0.0` instead of `127.0.0.1` within a docker container.

## Default configuration

* `monerod` and `monero-wallet-rpc`
  - `--log-level=0`
  - `--confirm-external-bind`
  - `--rpc-bind-ip=0.0.0.0`
  - `--rpc-bind-port=18081`
* Adapt default configuration using environment variables:
  - `--log-level=$LOG_LEVEL`
  - `---rpc-bind-ip=$RPC_BIND_IP`
  - `--rpc-bind-port=$RPC_BIND_PORT`

**Hint**:
The path `/monero` in the docker container is a volume and can be mapped to a path on the client.

## monerod

Without any additional command

`docker run --rm -it normoes/monero`

`monerod` starts with the above default configuration plus the following option:
* `--check-updates disabled`

Any additional `monerod` parameters can be passed as command:

```
docker run --rm -it -v <path_to_contents_of_.bitmonero>:/monero normoes/monero --p2p-bind-ip=0.0.0.0 --p2p-bind-port=18080 --data-dir /monero --non-interactive
```

**Hint**:
The path `/monero` is supposed to be used as `--data-dir` configuration for `monerod`. Here the synchronized blockchain data is stored. So when mounted `/monero` should contain the files from within `.bitmonero`.


## monero-wallet-rpc


When used as `monero-wallet-rpc` the full command is necessary as command to the docker run command:

```
docker run --rm -it -v <path_tp_wallet>:/monero --net host normoes/monero monero-wallet-rpc --daemon-host 127.0.0.1  --wallet-file wallet --password-file wallet.passwd --disable-rpc-login
```

`monero-wallet-rpc` starts with the above default configuration plus additional options passed in the actual docker run command.

To secure `monero-wallet-rpc` replace `--disable-rpc-login` by `rpc-login user:password`. Any JSON RPC request should then be provided with user credentials like this:

```
    curl -u user:password --digest http://localhost:18083
```


**Hint**:
The path `/monero` is supposed to contain the actual wallet files. So when mounted `/monero` should contain the files from within e.g. `~/Monero/wallets/wallet/`.
