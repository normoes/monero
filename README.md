## Supported tags
* `latest` (This is the most recent Monero `master` branch commit.)
* `850edfe4199458314346e2910550b33663310f42` (This is a specific Monero `master` branch commit, specified by commit hash.)
* `most_recent_tag` (This is the most recent Monero `tag`.)
* `v0.17.1.5` (This is a specific Monero `tag`.)

---

For running `monerod` or `monero-wallet-rpc` or `monero-wallet-cli` in a docker container.

This daemon is built from source: [monero project](https://github.com/monero-project/monero).

* Monero stable for `stagenet`/`mainnet`: Use version tags like `v0.17.1.5`.
* `testnet`: Use the `master` tag.
  - Generally, it is recommended to use `master` branch when working on `testnet`.
  - Of course, `latest` can also be used with `mainnet` and `stagenet`.
* The `latest` docker image is based on `master` branch.
* Monero tools can also be used through the Tor network, see **Tor software** below.

`readline` is finally compiled into the binaries, so using `monero-wallet-cli` is way more convenient.

## system and binary information

## default configuration

* docker container user running `monero`
  - `USER_ID` can be used to set the user who runs `monero`
    + `-e USER_ID=1000`
  - The container can also be started with `--user 1000`
    + No existing user is used then
  - Running `monero` as `root` is not possible (`USER_ID` defaults to 1000).
    + Of course, you can still disable the entrypoint with `--entrypoint=""` and run as root with `-u 0` ...
* `monerod` and `monero-wallet-rpc`
  - `--log-level=$LOG_LEVEL` (**default**: `0`) (also `monero-wallet-cli`)
  - `--confirm-external-bind`
  - `--rpc-bind-ip=$RPC_BIND_IP` (**default**: `0.0.0.0`)
  - `--rpc-bind-port=$RPC_BIND_PORT` (**default**: `28081`)
  - `--rpc-login $RPC_USER:$RPC_PASSWD` (**default RPC_USER**: `""`, **default RPC_PASSWD**: `""`)
    + For **authentication**, please see below.
* only `monerod`
  - `--p2p-bind-ip=$P2P_BIND_IP` (**default**: `0.0.0.0`)
  - `--p2p-bind-port=$P2P_BIND_PORT` (**default**: `28080`)
* only `monero-wallet-rpc` and `monero-wallet-cli`  
  - `--daemon-host=$DAEMON_HOST` (**default**: `127.0.0.1`)
  - `--daemon-port=$DAEMON_PORT` (**default**: `28081`)
  - `--password=$WALLET_PASSWD` (**default**: `""`)
    + For **wallet password**, please see below.
* Adapt default configuration using environment variables:
  - `-e LOG_LEVEL=3`
  - `-e RPC_USER=user`
  - `-e RPC_PASSWD=passwd`
  - `-e RPC_BIND_IP=127.0.0.1`
  - `-e RPC_BIND_PORT=18081`
  - `-e P2P_BIND_IP=0.0.0.0`
  - `-e P2P_BIND_PORT=18080`
  - `-e DAEMON_HOST=localhost` (assuming daemon is running locally)
  - `-e DAEMON_PORT=18081` (assuming daemon listens on port `18081`)
* Using `monerod`, `monero-wallet-rpc` and `monero-wallet-cli` with `torsocks`:
  - `-e USE_TORSOCKS=YES` (**default**: `NO`)
* Running the Tor proxy (`tor`) within the container:
  - `-e USE_TOR=YES` (**default**: `NO`)
* Log files:
  - The size of log files is limited to around `5.1 MB`.
  - The number of log files is capped at `3`.
  - By using `--max-log-file-size 5242880 --max-log-files 3` in the entrypoint script.

### hint:
* The IPs, the daemon or RPC are binding to, need to be `0.0.0.0` instead of `127.0.0.1` within a docker container.
* The path `/monero` in the docker container is a volume and can be mapped to a path on the client.

Check the repository for `docker-compose` templates. They show configuration examples of `monerod` and `monero-wallet-rpc`, respectively.

### authentication

Authentication can be activated for `monerod` and `monero-wallet-rpc`.

If the environment variables `RPC_USER` and `RPC_PASSWD` are set, the container's entrypoint script adds the option `--rpc-login $RPC_USER:$RPC_PASSWD`.

If you don't provide user and password, you have two options:
* Add `--disable-rpc-login` when starting the container to remove authentication.
* Use the default user `monero`, password is a randomly generated string. In this case, the login information is written into a file:
  ```bash
  # log message on starting monero-walet-rpc
  WARN 	wallet.rpc	src/wallet/wallet_rpc_server.cpp:225	RPC username/password is stored in file monero-wallet-rpc.38083.login
  # example output
  monero:6xsMGa/BPkHJJvf0y+fYRg==root@78b746205a4b
  ```
  - You can get the information like this:
  ```bash
  docker exec rpc_user cat /monero/monero-wallet-rpc.38083.login
  ```

Example requesting the rpc:
```
    curl -u user:password --digest http://localhost:18081
```

It is always recommended to use RPC authentication.

### wallet password

The wallet password can be configured for `monero-wallet-cli` and `monero-wallet-rpc`.

If the environment variable `WALLET_PASSWD` is set, the container's entrypoint script adds the option `--password $WALLET_PASSWD`.

If you don't provide a wallet password that way:
* You could set `--password-file wallet.passwd` and add a file containing the wallet password to the mounted voume.

It is always recommended to use a wallet password.

### raw commands

It is also possible to deactivate the entrpoint script.

This way, it is possible to define and configure e.g. the `monero-wallet-rpc` yourself:
```
docker run --rm -d --net host -v <path/to/and/including/wallet_folder>:/monero --entrypoint="" melotools/monero monero-wallet-rpc --log-level 2 --daemon-host node.melo.tools --daemon-port 18081 --confirm-external-bind --rpc-login user:passwd --rpc-bind-ip 0.0.0.0 --rpc-bind-port 18083 --wallet-file wallet --password-file wallet.passwd
```

## monerod

Without any additional command

`docker run --rm -it melotools/monero`

`monerod` starts with the above default configuration plus the following option:
* `--check-updates disabled`

Any additional `monerod` parameters can be passed as command:

```
docker run --rm -d -p 18081:18081 -v <path/to/and/including/.bitmonero>:/monero melotools/monero --data-dir /monero
```

Not specifying a host port in `-p <host_port>:<container_port>` docker will automatically assign a free port on the host.

```
docker run --rm -d -p 18081 -v <path/to/and/including/.bitmonero>:/monero melotools/monero --data-dir /monero
```

However, this only works for the common Monero network ports:
* `18080`
* `18081`
* `28080`
* `28081`
* `38080`
* `38081`

### user
Run `monerod` as different user (`uid != 1000 && uid != 0`). This is useful if deployed to several systems (AWS ec2-user: `uid=500`).

Abbreviated command:

```
docker run --rm -d -p 18081:18081 -e USER_ID=500 -v <host>:<container> melotools/monero <options>
```

### hint
The path `/monero` is supposed to be used as `--data-dir` configuration for `monerod`. Here the synchronized blockchain data is stored. So when mounted, `/monero` should contain the files from within `.bitmonero`.


## monero-wallet-rpc
When used as `monero-wallet-rpc` the full command is necessary as command to docker run:

Passing the pasword as environment variable:
```
docker run --rm -d --net host -e DAEMON_HOST=node.melo.tools -e DAEMON_PORT=18081 -e RPC_BIND_PORT=18083 -e RPC_USER=user -e RPC_PASSWD=passwd -e WALLET_PASSWD=securePasswd -v <path/to/and/including/wallet_folder>:/monero melotools/monero monero-wallet-rpc  --wallet-file wallet
```

Using a password file:
```
docker run --rm -d --net host -e DAEMON_HOST=node.melo.tools -e DAEMON_PORT=18081 -e RPC_BIND_PORT=18083 -e RPC_USER=user -e RPC_PASSWD=passwd -v <path/to/and/including/wallet_folder>:/monero melotools/monero monero-wallet-rpc  --wallet-file wallet --password-file wallet.passwd
```

### user
Run `monero-wallet-rpc` as different user (`uid != 1000 && uid != 0`). This is useful if deployed to several systems (AWS ec2-user: `uid=500`).

Abbreviated command:

```
docker run --rm -d --net host -e DAEMON_HOST=node.melo.tools -e DAEMON_PORT=18081 -e RPC_BIND_PORT=18083 -e USER_ID=500 -v <host>:<container> melotools/monero monero-wallet-rpc <options>
```

### rpc
`monero-wallet-rpc` starts with the above default configuration plus additional options passed in the actual docker run command, like `-e RPC_BIND_PORT=18083`.


### hint
The path `/monero` is supposed to contain the actual wallet files. So when mounted, `/monero` should contain the files from within e.g. `~/Monero/wallets/my_wallet/`.


## monero-wallet-cli

When used as `monero-wallet-cli` the full command is necessary as command to docker run:

```
docker run --rm -it -e DAEMON_HOST=node.melo.tools -e DAEMON_PORT=18081 -v <path/to/and/including/wallet_folder>:/monero --net host melotools/monero monero-wallet-cli --wallet-file wallet --password-file wallet.passwd
```

Due to `-it` (interactive terminal), you will end up within the container and can use the `monero-wallet-cli` commands.

### user
Run `monero-wallet-cli` as different user (`uid != 1000 && uid != 0`). This is useful if deployed to several systems (AWS ec2-user: `uid=500`).

Abbreviated command:

```
docker run --rm -it --net host -e DAEMON_HOST=node.melo.tools -e DAEMON_PORT=18081 -e USER_ID=500 -v <host>:<container> melotools/monero monero-wallet-cli <options>
```

### hint
The path `/monero` is supposed to contain the actual wallet files. So when mounted, `/monero` should contain the files from within e.g. `~/Monero/wallets/my_wallet/`.

## Tor software

Additional software installed:
* `torsocks`
* `tor`

You can find the following information within the docker image:
* `/torsocks.txt` contains output of `torsocks --version`
* `/tor.txt` contains output of `tor --version`

### using torsocks
Every monero docker image comes with `torsocks`.

To start `monerod`, `monero-wallet-rpc` and `monero-wallet-cli` using `torsocks`, the environment variable `USE_TORSOCKS=YES` should be passed into the container.
In case you use an external Tor proxy, you should run the monero docker container with `--net host` (docker cli) or `network_mode: "host"` (docker-compose), in order to make the host's localhost (and hence the external Tor proxy port) available to `torsocks` - provided the Tor proxy runs on the host's localhost. Please see below.

The following configuraion file `/etc/tor/torsocks.conf` is used:

```
TorAddress 127.0.0.1
TorPort 9050

OnionAddrRange 127.42.42.0/24

AllowInbound 1
```

The option `AllowInbound` is set to `1`, in order to allow binding the monero daemon to all interfaces (`0.0.0.0`) - within docker containers.

Please also refer to [melotools/tor](https://hub.docker.com/r/melotools/tor) for further details.

### using the Tor proxy
There are two options:
* a single container containing monero and Tor proxy,
* sparate containers for monero and Tor proxy.

Generally it is more recommended to have one single process within a docker container. separate containers

#### single image including the Tor proxy
Every monero docker image comes with `tor`.

The `tor` proxy is started within the docker image, when the environment variable `USE_TOR=YES` is set.

Against docker best practices (1 service per container), this **monero tor docker image** bundles monero tools with the Tor proxy witihn a single docker image.

The following configuraion file `/etc/tor/torrc` is used:

```
RunAsDaemon 1
User debian-tor
SOCKSPort 0.0.0.0:9050
## comment for local use with e.g. curl
# SOCKSPolicy "reject *"

HiddenServiceDir /var/lib/tor/daemons/
HiddenServicePort 18081 127.0.0.1:18081
HiddenServicePort 28081 127.0.0.1:28081
HiddenServicePort 38081 127.0.0.1:38081

DataDirectory /var/lib/tor
Log notice file /var/log/tor/notices.log

```
In this case the monero daemon ports available in the clearnet, are forwarded by the Tor proxy into the Tor network.
The option `SOCKSPort` is bound to `0.0.0.0` (all interfaces), in order to make it run within the docker container.
The option `HiddenServiceDir /var/lib/tor/daemons/` can be used as docker volume to provide the files `hostname` and `private_key`.

After starting the docker container you will find your hostname (**.onion address**) here:

`docker exec <container_name> cat /var/lib/tor/daemons/hostname`

Please also refer to [melotools/tor](https://hub.docker.com/r/melotools/tor) for further details.

#### separate images
The monero tools and the Tor proxy can also be run in separate containers (from separate images or processes on the host).

In this case, you need to make the host's localhost available within the monero docker container - see above **using torsocks**.

Please also refer to [melotools/tor](https://hub.docker.com/r/melotools/tor) for further details.

### docker container configuration examples

* serve `monerod` in the Tor network
  - `USE_TOR=YES`
  - `USE_TORSOCKS=NO`
  - Check tor configuration
  - Consider using `SOCKSPolicy "reject *"`
* run `monero-wallet-rpc` or `monero-wallet-cli` over the Tor network
  - running Tor proxy contained in the image
    + `USE_TOR=YES`
    + `USE_TORSOCKS=YES`
  - running an external Tor proxy
    + `USE_TOR=NO`
    + `USE_TORSOCKS=YES`
  - Check tor configuration

Please also refer to [melotools/tor](https://hub.docker.com/r/melotools/tor) for further details.
