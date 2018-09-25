
For running `monerod` or `monero-wallet-rpc` in a docker container.

This daemon is explictitely made for `mainnet` and `stagenet`, since it downloads and installs the binaries from https://getmonero.org/downloads/.

It runs monero `0.12.3.0`, `x64` and the docker image is based on ubuntu:16.04  .


A `testnet` daemon will follow (based on `monero master branch`).

**Hint**:
The IPs, the daemon or RPC are binding to, need to be `0.0.0.0` instead of `127.0.0.1` within a docker container.

**Hint**:
In the repository you can find a template for `docker-compose`. This is supposed to be an example on how to configure and use the image.

## Default configuration

* `monerod` and `monero-wallet-rpc`
  - `--log-level=$LOG_LEVEL` (**default**: `0`)
  - `--confirm-external-bind`
  - `--rpc-bind-ip=$RPC_BIND_IP` (**default**: `0.0.0.0`)
  - `--rpc-bind-port=$RPC_BIND_PORT` (**default**: `18081`)
* only `monerod`
  - `--p2p-bind-ip=$P2P_BIND_IP` (**default**: `0.0.0.0`)
  - `--p2p-bind-port=$P2P_BIND_PORT` (**default**: `18080`)
* Adapt default configuration using environment variables:
  - `-e LOG_LEVEL=3`
  - `-e RPC_BIND_IP=127.0.0.1`
  - `-e RPC_BIND_PORT=18081`
  - `-e P2P_BIND_IP=0.0.0.0`
  - `-e P2P_BIND_PORT=18080`

**Hint**:
The path `/monero` in the docker container is a volume and can be mapped to a path on the client.

**Hint**:
The `uid` of the user running `monerod` (**default**: 500) is configurable. `USER_ID` is implemented as `ARG` in the Dockerfile and can be set on build.

**Hint**:
Check the repository for `docker-compose` templates. They can be used to start `monerod` or `monero-wallet-rpc`, respectively.

## monerod

Without any additional command

`docker run --rm -it normoes/monero`

`monerod` starts with the above default configuration plus the following option:
* `--check-updates disabled`

Any additional `monerod` parameters can be passed as command:

```
docker run --rm -it -p 18081:18081 -v <path_to_contents_of_.bitmonero>:/monero normoes/monero --data-dir /monero --non-interactive
```

**Hint**:
The path `/monero` is supposed to be used as `--data-dir` configuration for `monerod`. Here the synchronized blockchain data is stored. So when mounted, `/monero` should contain the files from within `.bitmonero`.


## monero-wallet-rpc

When used as `monero-wallet-rpc` the full command is necessary as command to docker run:

```
docker run --rm -it -e RPC_BIND_PORT=18083 -v <path_to_contents_of_wallet_folder>:/monero --net host normoes/monero monero-wallet-rpc --daemon-host <host>  --wallet-file wallet --password-file wallet.passwd --disable-rpc-login
```

`monero-wallet-rpc` starts with the above default configuration plus additional options passed in the actual docker run command, like `-e RPC_BIND_PORT=18083`.

To secure `monero-wallet-rpc` replace `--disable-rpc-login` by `rpc-login user:password`. Any JSON RPC request should then be provided with user credentials like this:

```
    curl -u user:password --digest http://localhost:18083
```


**Hint**:
The path `/monero` is supposed to contain the actual wallet files. So when mounted, `/monero` should contain the files from within e.g. `~/Monero/wallets/wallet/`.
