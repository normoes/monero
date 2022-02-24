## 2021-08-14
* Added github actions to keep on building docker images.

# 2022-02-24
* Force new commit and by adding this comment.
    - Re-enable github actions.

# 2021-01-06
- Dockerfile version `v1.0.3`.
- Update on network attacks with `v0.17.1.8`.
    + https://www.reddit.com/r/Monero/comments/ko3d1n/third_update_on_the_ongoing_network_attacks/
    + Download this [file](https://gui.xmr.pm/files/block_tor.txt) and mount it into the container.
        - `docker run --rm -d ... -v $(pwd)/block_tor.txt:/data/block_tor.txt...`
    + Add `--ban-list block_tor.txt` as daemon startup flag.
- Clean `apt-get` cache.

# 2020-12-17
- Dockerfile version `v1.0.2`.
- Upgrade `openssl` to `1.1.1i`.
