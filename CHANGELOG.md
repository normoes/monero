# 06.01.2021
- Dockerfile version `v1.0.3`.
- Update on network attacks with `v0.17.1.8`.
    + https://www.reddit.com/r/Monero/comments/ko3d1n/third_update_on_the_ongoing_network_attacks/
    + Download this [file](https://gui.xmr.pm/files/block_tor.txt) and mount it into the container.
        - `docker run --rm -d ... -v $(pwd)/block_tor.txt:/data/block_tor.txt...`
    + Add `--ban-list block_tor.txt` as daemon startup flag.
- Clean `apt-get` cache.

# 17.12.2020
- Dockerfile version `v1.0.2`.
- Upgrade `openssl` to `1.1.1i`.
