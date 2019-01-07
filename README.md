## Supported tags and respective `Dockerfile` links
* `latest` ([Dockerfile](https://github.com/XMRto/monero/blob/master/Dockerfile))
* `most_recent_tag` ([Dockerfile](https://github.com/XMRto/monero/blob/most_recent_tag/Dockerfile))
* `v0.13.0.4` ([Dockerfile](https://github.com/XMRto/monero/blob/most_recent_tag/Dockerfile))

---

For running `monerod` or `monero-wallet-rpc` or `monero-wallet-cli` in a docker container.

This daemon is built from source: [monero project](https://github.com/monero-project/monero).

* Monero stable for `stagenet`/`mainnet`: Use version tags like `v0.13.0.3`.
* `testnet`: Use the `master` tag.
  - Generally, it is recommended to use `master` branch when working on `testnet`.
  - Of course, `latest` can also be used with `mainnet` and `stagenet`.
* The `latest` docker image is based on `master` branch.
* Monero tools can also be used through the Tor network, see **Tor software** below.

## system and binary information

You can find the following information within the docker image:
* `/version.txt` contains output of `monerod --version`
* `/system.txt` contains output of `cat /etc/os-release`
* `/dependencies.txt` contains output of `ldd $(command -v monerod)`

## default configuration

* docker container user running `monero`
  - `USER_ID` can be used to set the user who runs `monero`
    + `-e USER_ID=1000`
  - The container can also be started with `--user 1000`
    + No existing user is used then
  - Running `monero` as `root` is not possible (`USER_ID` defaults to 1000).
* `monerod` and `monero-wallet-rpc`
  - `--log-level=$LOG_LEVEL` (**default**: `0`) (also `monero-wallet-cli`)
  - `--confirm-external-bind`
  - `--rpc-bind-ip=$RPC_BIND_IP` (**default**: `0.0.0.0`)
  - `--rpc-bind-port=$RPC_BIND_PORT` (**default**: `28081`)
* only `monerod`
  - `--p2p-bind-ip=$P2P_BIND_IP` (**default**: `0.0.0.0`)
  - `--p2p-bind-port=$P2P_BIND_PORT` (**default**: `28080`)
* only `monero-wallet-rpc` and `monero-wallet-cli`  
  - `--daemon-host=$DAEMON_HOST` (**default**: `127.0.0.1`)
  - `--daemon-port=$DAEMON_PORT` (**default**: `28081`)
* Adapt default configuration using environment variables:
  - `-e LOG_LEVEL=3`
  - `-e RPC_BIND_IP=127.0.0.1`
  - `-e RPC_BIND_PORT=18081`
  - `-e P2P_BIND_IP=0.0.0.0`
  - `-e P2P_BIND_PORT=18080`
  - `-e DAEMON_HOST=localhost` (assuming daemon is running locally)
  - `-e DAEMON_PORT=18081` (assuming daemon listens on port `18081`)
* Using `monerod`, `monero-wallet-rpc` and `monero-wallet-cli` with `torsocks`:
  - `-e USE_TORSOCKS=YES` (**default**: `NO`)

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
docker run --rm -d -p 18081:18081 -v <path/to/and/including/.bitmonero>:/monero xmrto/monero --data-dir /monero --non-interactive
```

### user
Run `monerod` as different user (`uid != 1000 && uid != 0`). This is useful if deployed to several systems (AWS ec2-user: `uid=500`).

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
docker run --rm -d --net host -e DAEMON_HOST=node.xmr.to -e DAEMON_PORT=18081 -e RPC_BIND_PORT=18083 -v <path/to/and/including/wallet_folder>:/monero xmrto/monero monero-wallet-rpc  --wallet-file wallet --password-file wallet.passwd --disable-rpc-login
```

### user
Run `monero-wallet-rpc` as different user (`uid != 1000 && uid != 0`). This is useful if deployed to several systems (AWS ec2-user: `uid=500`).

Abbreviated command:

```
docker run --rm -d --net host -e DAEMON_HOST=node.xmr.to -e DAEMON_PORT=18081 -e RPC_BIND_PORT=18083 -e USER_ID=500 -v <host>:<container> xmrto/monero monero-wallet-rpc <options>
```

### rpc
`monero-wallet-rpc` starts with the above default configuration plus additional options passed in the actual docker run command, like `-e RPC_BIND_PORT=18083`.

To secure `monero-wallet-rpc` replace `--disable-rpc-login` by `--rpc-login user:password`. Any JSON RPC request should then be provided with user credentials like this:

```
    curl -u user:password --digest http://localhost:18083
```


### hint
The path `/monero` is supposed to contain the actual wallet files. So when mounted, `/monero` should contain the files from within e.g. `~/Monero/wallets/my_wallet/`.


## monero-wallet-cli

When used as `monero-wallet-cli` the full command is necessary as command to docker run:

```
docker run --rm -it -e DAEMON_HOST=node.xmr.to -e DAEMON_PORT=18081 -v <path/to/and/including/wallet_folder>:/monero --net host xmrto/monero monero-wallet-cli --wallet-file wallet --password-file wallet.passwd
```

Attaching to the container then allows you to use `monero-wallet-cli` commands.

### user
Run `monero-wallet-cli` as different user (`uid != 1000 && uid != 0`). This is useful if deployed to several systems (AWS ec2-user: `uid=500`).

Abbreviated command:

```
docker run --rm -it --net host -e DAEMON_HOST=node.xmr.to -e DAEMON_PORT=18081 -e USER_ID=500 -v <host>:<container> xmrto/monero monero-wallet-cli <options>
```

### hint
The path `/monero` is supposed to contain the actual wallet files. So when mounted, `/monero` should contain the files from within e.g. `~/Monero/wallets/my_wallet/`.

## Tor software

Additional software installed:
* `torsocks`

You can find the following information within the docker image:
* `/torsocks.txt` contains output of `torsocks --version`

### using the Tor proxy
There are two options:
* a single container containing monero and Tor proxy,
* sparate containers for monero and Tor proxy.

#### single image including the Tor proxy
There is a [monero docker image incl. the tor proxy](https://github.com/XMRto/monero/blob/tor/Dockerfile).
Please also refer to [xmrto/tor](https://hub.docker.com/r/xmrto/tor) for further details.

In this case the monero daemon ports available in the clearnet, are forwarded by the Tor proxy into the Tor network.

Against docker best practices (1 service per container), this **monero tor docker image** bundles monero tools with the Tor proxy witihn a single docker image.

#### separate images
The previous case can be separated, so the monero tools and the Tor proxy run in separate containers (from separate images).

Please also refer to [xmrto/tor](https://hub.docker.com/r/xmrto/tor) for further details.

### using torsocks
Every monero docker image also contains `torsocks`.

To start `monerod`, `monero-wallet-rpc` and `monero-wallet-cli` using `torsocks`,the environment variable `USE_TORSOCKS=YES` should be passed into the container.

This allows, similar to the previous case, to make monero tools available in Tor network.

The following configuraion file `torsocks.conf` is used:

```
TorAddress 127.0.0.1
TorPort 9050

OnionAddrRange 127.42.42.0/24

AllowInbound 1
```

The option `AllowInbound` is set to `1`, in order to allow binding the monero daemon to all interfaces (`0.0.0.0`) - within docker containers.
