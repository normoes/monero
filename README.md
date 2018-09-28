
For running `monerod` or `monero-wallet-rpc` or `monero-wallet-cli` in a docker container.

This daemon is built from source: [monero project](https://github.com/monero-project/monero).

* `stagenet`/`mainnet`: Use the version tags like `0.12.3.0` or `0.13.0.1-RC1`.
* `testnet`: Use the `master` tag.
  - Generally, it is recommended to use `master` branch when working on `testnet`.
  - Of course, this tag can also be used with `mainnet` and `stagenet`.
* The `latest` docker image is the same as `master`.

## default configuration

* docker container user running `monero`
  - `USER_ID` can be used to set the user who runs `monero`
    + `-e USER_ID=1000`
  - The container can also be started with `--user 1000`
    + No existing user is used then
  - Running `monero` as `root` is not possible (`USER_ID` defaults to 1000).
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

### hint:
* The IPs, the daemon or RPC are binding to, need to be `0.0.0.0` instead of `127.0.0.1` within a docker container.
* The path `/monero` in the docker container is a volume and can be mapped to a path on the client.

Check the repository for `docker-compose` templates. They show configuration examples of `monerod` and `monero-wallet-rpc`, respectively.

## monerod

Without any additional command

`docker run --rm -it xmrto/monero`

`monerod` starts with the above default configuration plus the following option:
* `--check-updates disabled`

Any additional `monerod` parameters can be passed as command:

```
docker run --rm -d -p 18081:18081 -v <path_to_contents_of_.bitmonero>:/monero xmrto/monero --data-dir /monero --non-interactive
```

### user
Run `monerod` as different user (`uid != 1000 && uid != 0`).
Abbreviated command:

```
docker run --rm -d -p 18081:18081 -e USER_ID=500 -v <host>:<container> xmrto/monero <options>
```

### rpc
To secure `monerod` rpc also pass the option `--rpc-login user:password`. Any JSON RPC request should then be provided with user credentials like this:

```
    curl -u user:password --digest http://localhost:18081
```

### hint
The path `/monero` is supposed to be used as `--data-dir` configuration for `monerod`. Here the synchronized blockchain data is stored. So when mounted, `/monero` should contain the files from within `.bitmonero`.


## monero-wallet-rpc
When used as `monero-wallet-rpc` the full command is necessary as command to docker run:

```
docker run --rm -d --net host -e RPC_BIND_PORT=18083 -v <path_to_contents_of_wallet_folder>:/monero xmrto/monero monero-wallet-rpc --daemon-host <host>  --wallet-file wallet --password-file wallet.passwd --disable-rpc-login
```

### user
Run `monero-wallet-rpc` as different user (`uid != 1000 && uid != 0`).
Abbreviated command:

```
docker run --rm -d --net host -e RPC_BIND_PORT=18083 -e USER_ID=500 -v <host>:<container> xmrto/monero monero-wallet-rpc <options>
```

### rpc
`monero-wallet-rpc` starts with the above default configuration plus additional options passed in the actual docker run command, like `-e RPC_BIND_PORT=18083`.

To secure `monero-wallet-rpc` replace `--disable-rpc-login` by `--rpc-login user:password`. Any JSON RPC request should then be provided with user credentials like this:

```
    curl -u user:password --digest http://localhost:18083
```


### hint
The path `/monero` is supposed to contain the actual wallet files. So when mounted, `/monero` should contain the files from within e.g. `~/Monero/wallets/wallet/`.


## monero-wallet-cli

When used as `monero-wallet-cli` the full command is necessary as command to docker run:

```
docker run --rm -it -v <path_to_contents_of_wallet_folder>:/monero --net host xmrto/monero monero-wallet-cli --daemon-host <host>  --wallet-file wallet --password-file wallet.passwd
```

Attaching to the container then allows you to use `monero-wallet-cli` commands.

### user
Run `monero-wallet-cli` as different user (`uid != 1000 && uid != 0`).
Abbreviated command:

```
docker run --rm -it --net host -e USER_ID=500 -v <host>:<container> xmrto/monero monero-wallet-cli <options>
```

### hint
The path `/monero` is supposed to contain the actual wallet files. So when mounted, `/monero` should contain the files from within e.g. `~/Monero/wallets/wallet/`.
