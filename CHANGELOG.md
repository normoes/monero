## 2021-08-14
* Added github actions to keep on building docker images.

# 2022-03-14
- Dockerfile version `v1.1.0`.
* Added a way that hopefully enables users to verify the binaries within this docker image are based on the original source (github).
    - This is necessary because the binaries are built from source.
    - I would like to show that I did not change anything in the source code before starting the build process:
        + `git log --format=%H | head -1 > /monero_git_commit.hash`
        + `sha256sum $(find ./src -type f) > /single_src_files.sha256`
        + `cat /single_src_files.sha256 | awk '{print $1}' | sort -n -u | sha256sum | cut -d " " -f 1 > /entire_src_files.sha256`
        + Starting a docker container from this very docker image will show the following information:
        ```
        Docker image build information
        * Monero version:
            Monero 'Oxygen Orion' (v0.17.0.0-d562deaaa)
        * Based on git commit hash:
            d562deaaa950979b7a31a441a8f02a00013e26d6
        * SHA256 over all the files under src/ in the github repository:
            180157605caa5919608d3509d8990dd2e78a2a2adc12eeae033eccaa01c4399a
        ```

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
