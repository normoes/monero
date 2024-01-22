ARG DEBIAN_VERSION="${DEBIAN_VERSION:-stable-slim}"
FROM debian:${DEBIAN_VERSION} as dependencies1

WORKDIR /data

ENV DEBIAN_FRONTEND=noninteractive

#su-exec
ARG SUEXEC_VERSION=v0.2
ARG SUEXEC_HASH=f85e5bde1afef399021fbc2a99c837cf851ceafa

# OpenSSL
ARG OPENSSL_VERSION=OpenSSL_1_1_1w
ARG OPENSSL_HASH=e04bd3433fd84e1861bf258ea37928d9845e6a86

#Cmake - https://github.com/Kitware/CMake/releases/tag/v3.28.1
ARG CMAKE_VERSION=v3.28.1
ARG CMAKE_HASH=1eed682d7cca9bb2c2b0709a6c3202a3b08613b2
## Boost
ARG BOOST_VERSION=boost-1.84.0
ARG BOOST_HASH=ad09f667e61e18f5c31590941e748ac38e5a81bf

ENV CFLAGS='-fPIC -O2 -g'
ENV CXXFLAGS='-fPIC -O2 -g'
ENV LDFLAGS='-static-libstdc++'

ENV BASE_DIR /usr/local

# 'unbound': 'bison', 'flex'
# 'protobuf': 'bazel'
RUN apt-get update -qq && apt-get --no-install-recommends -yqq install \
        ca-certificates \
        g++ \
        make \
        pkg-config \
        graphviz \
        doxygen \
        git \
        curl \
        libtool-bin \
        autoconf \
        automake \
        bzip2 \
        xsltproc \
        docbook-xsl \
        gperf \
        bison \
        flex \
        libreadline-dev \
        unzip > /dev/null \
    && cd /data || exit 1 \
    && echo "\e[32mbuilding: su-exec\e[39m" \
    && git clone --branch ${SUEXEC_VERSION} --single-branch --depth 1 https://github.com/ncopa/su-exec.git su-exec.git > /dev/null \
    && cd su-exec.git || exit 1 \
    && test `git rev-parse HEAD` = ${SUEXEC_HASH} || exit 1 \
    && make > /dev/null \
    && cp su-exec /data \
    && cd /data || exit 1 \
    && rm -rf /data/su-exec.git \
    && echo "\e[32mbuilding: Openssl\e[39m" \
    && cd /data || exit 1 \
    && git clone --branch ${OPENSSL_VERSION} --single-branch --depth 1 https://github.com/openssl/openssl.git openssl.git > /dev/null \
    && cd openssl.git || exit 1 \
    && test `git rev-parse HEAD` = ${OPENSSL_HASH} || exit 1 \
    && ./Configure --prefix=$BASE_DIR linux-x86_64 no-shared --static "$CFLAGS" > /dev/null \
    && make build_generated > /dev/null \
    && make libcrypto.a > /dev/null \
    && make install > /dev/null \
    && cd /data || exit 1 \
    && rm -rf /data/openssl.git \
    && echo "\e[32mbuilding: Cmake\e[39m" \
    && cd /data || exit 1 \
    && git clone --branch ${CMAKE_VERSION} --single-branch --depth 1 https://github.com/Kitware/CMake.git cmake.git > /dev/null \
    && cd cmake.git || exit 1 \
    && test `git rev-parse HEAD` = ${CMAKE_HASH} || exit 1 \
    && ./bootstrap --prefix=$BASE_DIR > /dev/null \
    && make > /dev/null \
    && make install > /dev/null \
    && cd /data || exit 1 \
    && rm -rf /data/cmake.git \
    && echo "\e[32mbuilding: Boost\e[39m" \
    && cd /data || exit 1 \
    && git clone --branch ${BOOST_VERSION} --single-branch --depth 1 --recursive https://github.com/boostorg/boost.git boost.git > /dev/null \
    && cd boost.git || exit 1 \
    && test `git rev-parse HEAD` = ${BOOST_HASH} || exit 1 \
    && ./bootstrap.sh > /dev/null \
    && ./b2 -a install --prefix=$BASE_DIR --build-type=minimal link=static runtime-link=static --with-chrono --with-date_time --with-filesystem --with-program_options --with-regex --with-serialization --with-system --with-thread --with-locale threading=multi threadapi=pthread cflags="$CFLAGS" cxxflags="$CXXFLAGS" stage > /dev/null \
    && cd /data || exit 1 \
    && rm -rf /data/boost.git

FROM index.docker.io/normoes/monero:dependencies1 as dependencies2
WORKDIR /data

ENV DEBIAN_FRONTEND=noninteractive

ENV BASE_DIR /usr/local

# ZMQ
ARG ZMQ_VERSION=v4.3.5
ARG ZMQ_HASH=622fc6dde99ee172ebaa9c8628d85a7a1995a21d
# zmq.hpp
ARG CPPZMQ_VERSION=v4.10.0
ARG CPPZMQ_HASH=c94c20743ed7d4aa37835a5c46567ab0790d4acc
# Readline
ARG READLINE_VERSION=8.0
ARG READLINE_HASH=e339f51971478d369f8a053a330a190781acb9864cf4c541060f12078948e461
# Sodium
ARG SODIUM_VERSION=1.0.18
ARG SODIUM_HASH=4f5e89fa84ce1d178a6765b8b46f2b6f91216677
# https://nlnetlabs.nl/downloads/unbound/
ARG UNBOUND_VERSION=release-1.19.0
ARG UNBOUND_HASH=3352b1090ea1098883f6bf64236fa877e18e458b
# LibExpat (required by Unbound)
ARG LIBEXPAT_VERSION=R_2_5_0
ARG LIBEXPAT_HASH=654d2de0da85662fcc7644a7acd7c2dd2cfb21f0

ENV CFLAGS='-fPIC -O2 -g'
ENV CXXFLAGS='-fPIC -O2 -g'
ENV LDFLAGS='-static-libstdc++'

 RUN echo "\e[32mbuilding: ZMQ\e[39m" \
    && cd /data || exit 1 \
    && git clone --branch ${ZMQ_VERSION} --single-branch --depth 1 https://github.com/zeromq/libzmq.git > /dev/null \
    && cd libzmq || exit 1 \
    && test `git rev-parse HEAD` = ${ZMQ_HASH} || exit 1 \
    && ./autogen.sh > /dev/null \
    && ./configure --prefix=$BASE_DIR --enable-libunwind=no --enable-static --disable-shared > /dev/null \
    && make > /dev/null \
    && make install > /dev/null \
    && ldconfig > /dev/null \
    && cd /data || exit 1 \
    && rm -rf /data/libzmq \
    && echo "\e[32mbuilding: zmq.hpp\e[39m" \
    && cd /data || exit 1 \
    && git clone --branch ${CPPZMQ_VERSION} --single-branch --depth 1 https://github.com/zeromq/cppzmq.git > /dev/null \
    && cd cppzmq || exit 1 \
    && test `git rev-parse HEAD` = ${CPPZMQ_HASH} || exit 1 \
    && mv *.hpp $BASE_DIR/include \
    && cd /data || exit 1 \
    && rm -rf /data/cppzmq \
    && echo "\e[32mbuilding: Readline\e[39m" \
    && cd /data || exit 1 \
    && curl -sSL -O https://ftp.gnu.org/gnu/readline/readline-${READLINE_VERSION}.tar.gz > /dev/null \
    && echo "${READLINE_HASH}  readline-${READLINE_VERSION}.tar.gz" | sha256sum -c \
    && tar -xzf readline-${READLINE_VERSION}.tar.gz > /dev/null \
    && cd readline-${READLINE_VERSION} || exit 1 \
    && ./configure --prefix=$BASE_DIR > /dev/null \
    && make > /dev/null \
    && make install-static > /dev/null \
    && cd /data || exit 1 \
    && rm -rf /data/readline-${READLINE_VERSION} \
    && rm -rf readline-${READLINE_VERSION}.tar.gz \
    && echo "\e[32mbuilding: Sodium\e[39m" \
    && cd /data || exit 1 \
    && git clone --branch ${SODIUM_VERSION} --single-branch --depth 1 https://github.com/jedisct1/libsodium.git > /dev/null \
    && cd libsodium || exit 1 \
    && test `git rev-parse HEAD` = ${SODIUM_HASH} || exit 1 \
    && ./autogen.sh \
    && ./configure --prefix=$BASE_DIR --disable-shared > /dev/null \
    && make > /dev/null \
    && make check > /dev/null \
    && make install > /dev/null \
    && cd /data || exit 1 \
    && rm -rf /data/libsodium \
    && echo "\e[32mbuilding: LibExpat\e[39m" \
    && cd /data || exit 1 \
    && git clone --branch ${LIBEXPAT_VERSION} --single-branch --depth 1 https://github.com/libexpat/libexpat.git libexpat.git > /dev/null \
    && cd libexpat.git || exit 1 \
    && test `git rev-parse HEAD` = ${LIBEXPAT_HASH} || exit 1 \
    && cd expat || exit 1 \
    && ls -l \
    && ./buildconf.sh \
    && ./configure --enable-static --disable-shared --prefix=$BASE_DIR > /dev/null \
    && make -j4 > /dev/null \
    && make install -j4 > /dev/null \
    && cd /data || exit 1 \
    && rm -rf /data/expat.git \
    && echo "\e[32mbuilding: Unbound\e[39m" \
    && cd /data || exit 1 \
    && git clone --branch ${UNBOUND_VERSION} --single-branch --depth 1 https://github.com/NLnetLabs/unbound.git unbound.git > /dev/null \
    && cd unbound.git || exit 1 \
    && test `git rev-parse HEAD` = ${UNBOUND_HASH} || exit 1 \
    && ./configure --disable-shared --enable-static --without-pyunbound --prefix=$BASE_DIR --with-libevent=no --without-pythonmodule --disable-flto --with-pthreads --with-libunbound-only --with-pic > /dev/null \
    && make -j4 > /dev/null \
    && make install -j4 > /dev/null \
    && cd /data || exit 1 \
    && rm -rf /data/unbound.git

FROM index.docker.io/normoes/monero:dependencies2 as dependencies3
WORKDIR /data

ENV DEBIAN_FRONTEND=noninteractive

ENV BASE_DIR /usr/local

# Udev
ARG UDEV_VERSION=v3.2.14
ARG UDEV_HASH=9e7c4e744b9e7813af9acee64b5e8549ea1fbaa3
# Libusb
ARG USB_VERSION=v1.0.26
ARG USB_HASH=4239bc3a50014b8e6a5a2a59df1fff3b7469543b
# Hidapi
ARG HIDAPI_VERSION=hidapi-0.14.0
ARG HIDAPI_HASH=d3013f0af3f4029d82872c1a9487ea461a56dee4
# Protobuf
# https://bazel.build/install/ubuntu#install-on-ubuntu
# https://github.com/protocolbuffers/protobuf/blob/v25.2/src/README.md
# ARG PROTOBUF_VERSION=v25.2
# ARG PROTOBUF_HASH=a9b006bddd52e289029f16aa77b77e8e0033d9ee
ARG PROTOBUF_VERSION=v3.21.12
ARG PROTOBUF_HASH=f0dc78d7e6e331b8c6bb2d5283e06aa26883ca7c

ENV CFLAGS='-fPIC -O2 -g'
ENV CXXFLAGS='-fPIC -O2 -g'
ENV LDFLAGS='-static-libstdc++'

RUN echo "\e[32mbuilding: Udev\e[39m" \
    && cd /data || exit 1 \
    && git clone --branch ${UDEV_VERSION} --single-branch --depth 1 https://github.com/eudev-project/eudev.git eudev.git > /dev/null \
    && cd eudev.git || exit 1 \
    && test `git rev-parse HEAD` = ${UDEV_HASH} || exit 1 \
    && ./autogen.sh > /dev/null \
    && ./configure --prefix=$BASE_DIR --disable-introspection --disable-hwdb --disable-manpages --disable-shared > /dev/null \
    && make > /dev/null \
    && make install > /dev/null \
    && cd /data || exit 1 \
    && rm -rf /data/eudev.git \
    && echo "\e[32mbuilding: Libusb\e[39m" \
    && cd /data || exit 1 \
    && git clone --branch ${USB_VERSION} --single-branch --depth 1 https://github.com/libusb/libusb.git libusb.git > /dev/null \
    && cd libusb.git || exit 1 \
    && test `git rev-parse HEAD` = ${USB_HASH} || exit 1 \
    && ./autogen.sh > /dev/null \
    && ./configure --prefix=$BASE_DIR --disable-shared > /dev/null \
    && make > /dev/null \
    && make install > /dev/null \
    && cd /data || exit 1 \
    && rm -rf /data/libusb.git \
    && echo "\e[32mbuilding: Hidapi\e[39m" \
    && cd /data || exit 1 \
    && git clone --branch ${HIDAPI_VERSION} --single-branch --depth 1 https://github.com/libusb/hidapi.git hidapi.git > /dev/null \
    && cd hidapi.git || exit 1 \
    && test `git rev-parse HEAD` = ${HIDAPI_HASH} || exit 1 \
    && ./bootstrap > /dev/null \
    && ./configure --prefix=$BASE_DIR --enable-static --disable-shared > /dev/null \
    && make > /dev/null \
    && make install > /dev/null \
    && cd /data || exit 1 \
    && rm -rf /data/hidapi.git \
    && echo "\e[32mbuilding: Protobuf\e[39m" \
    && cd /data || exit 1 \
    # && curl -fsSL https://bazel.build/bazel-release.pub.gpg | gpg --dearmor >bazel-archive-keyring.gpg \
    # && apt-get --no-install-recommends -yqq install \
    #     bazel \
    #     apt-transport-https \
    #     gnupg \
    # && sudo mv bazel-archive-keyring.gpg /usr/share/keyrings \
    # && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/bazel-archive-keyring.gpg] https://storage.googleapis.com/bazel-apt stable jdk1.8" | sudo tee /etc/apt/sources.list.d/bazel.list \
    && git clone --branch ${PROTOBUF_VERSION}  --single-branch --depth 1 https://github.com/protocolbuffers/protobuf.git protobuf.git > /dev/null \
    && cd protobuf.git || exit 1 \
    && test `git rev-parse HEAD` = ${PROTOBUF_HASH} || exit 1 \
    && git submodule update --init --recursive > /dev/null \
    # && bazel build :protoc_static :protobuf \
    # && bazel build :protoc :protobuf \
    && ./autogen.sh > /dev/null \
    && ./configure --prefix=$BASE_DIR --enable-static --disable-shared > /dev/null \
    && make > /dev/null \
    && make install > /dev/null \
    && ldconfig > /dev/null \
    && cd /data || exit 1 \
    && rm -rf /data/protobuf.git

FROM index.docker.io/normoes/monero:dependencies3 as builder
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /data
# BUILD_PATH:
# Using 'USE_SINGLE_BUILDDIR=1 make' creates a unified build dir (/monero.git/build/release/bin)

ARG PROJECT_URL=https://github.com/monero-project/monero.git
ARG BRANCH=master
# ARG BUILD_PATH=/monero.git/build/bin
ARG BUILD_PATH=/monero.git/build/release/bin
ARG BUILD_BRANCH=$BRANCH

ENV CFLAGS='-fPIC -O1'
ENV CXXFLAGS='-fPIC -O1'
ENV LDFLAGS='-static-libstdc++'
# ENV LDFLAGS='-static-libstdc++ -L/usr/local/lib'
# ENV LFLAGS='-llibunbound,-llibreadline'
# ENV LDFLAGS='-static-libstdc++,-L/usr/local'
# ENV CPPFLAGS='-I/usr/local/include'

# COPY patch.diff /data

RUN echo "\e[32mcloning: $PROJECT_URL on branch: $BRANCH\e[39m" \
    && cd /data || exit 1 \
    && git clone -n --branch "$BRANCH" --single-branch --depth 1 --recursive $PROJECT_URL monero.git > /dev/null \
    && cd monero.git || exit 1 \
    && git checkout "$BUILD_BRANCH" > /dev/null \
    && git submodule update --init --force --recursive > /dev/null \
    # && echo "\e[32mapplying  patch\e[39m" \
    # && git apply --stat ../patch.diff \
    # && git apply --check ../patch.diff \
    # && git apply  ../patch.diff \
    && echo "\e[32mcreating hash of source\e[39m" \
    && git log --format=%H | head -1 > /monero_git_commit.hash \
    && sha256sum $(find ./src -type f) > /single_src_files.sha256 \
    && cat /single_src_files.sha256 | awk '{print $1}' | sort -u | sha256sum | cut -d " " -f 1 > /entire_src_files.sha256 \
    && echo "\e[32mbuilding static binaries\e[39m" \
    # && mkdir build && cd build || exit 1 \
    # # CFLAGS="-march=native -mtune=native -Ofast" CXXFLAGS="-march=native -mtune=native -Ofast" \
    # && cmake .. -D BUILD_DOCUMENTATION=OFF -D BUILD_DEBUG_UTILITIES=OFF -D BUILD_TESTS=OFF -D BUILD_GUI_DEPS=OFF -D STACK_TRACE=OFF \
    # -D STATIC=ON -D ARCH="x86-64" -D BUILD_64=ON -D CMAKE_BUILD_TYPE=release \
    # # -D STATIC=ON -D ARCH="native" -D CMAKE_BUILD_TYPE=Release \
    # # && cmake --build . --target daemon -- -j$(nproc) \
    # && cmake --build . -- -j$(nproc) \
    && USE_SINGLE_BUILDDIR=1 make release-static > /dev/null \
    && echo "\e[32mcopy and clean up\e[39m" \
    && mv /data$BUILD_PATH/monerod /data/ \
    && chmod +x /data/monerod \
    && mv /data$BUILD_PATH/monero-wallet-rpc /data/ \
    && chmod +x /data/monero-wallet-rpc \
    && mv /data$BUILD_PATH/monero-wallet-cli /data/ \
    && chmod +x /data/monero-wallet-cli \
    && cd /data || exit 1 \
    && rm -rf /data/monero.git \
    && apt-get purge -yqq \
        ca-certificates \
        g++ \
        make \
        pkg-config \
        # gnupg \
        graphviz \
        doxygen \
        git \
        curl \
        libtool-bin \
        autoconf \
        automake \
        bzip2 \
        xsltproc \
        docbook-xsl \
        gperf \
        bison \
        flex \
        # bazel \
        unzip \
        libreadline-dev > /dev/null \
    && apt-get autoremove --purge -yqq > /dev/null \
    && apt-get clean > /dev/null \
    && rm -rf /var/tmp/* /tmp/* /var/lib/apt/lists/* /var/cache/apt/* > /dev/null

FROM debian:${DEBIAN_VERSION}
COPY --from=builder /data/monerod /usr/local/bin/
COPY --from=builder /data/monero-wallet-rpc /usr/local/bin/
COPY --from=builder /data/monero-wallet-cli /usr/local/bin/
COPY --from=builder /data/su-exec /usr/local/bin/
COPY --from=builder /monero_git_commit.hash /monero_git_commit.hash
COPY --from=builder /single_src_files.sha256 /single_src_files.sha256
COPY --from=builder /entire_src_files.sha256 /entire_src_files.sha256

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -qq && apt-get install -yqq --no-install-recommends \
        torsocks \
        tor > /dev/null \
    && apt-get autoremove --purge -yqq > /dev/null \
    && apt-get clean > /dev/null \
    && rm -rf /var/tmp/* /tmp/* /var/lib/apt/lists/* /var/cache/apt/* > /dev/null

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
COPY inputrc /etc/inputrc
# Copy Tor configuration files after installing Tor apps
# otherwise configuration might be replaced, build might stop
COPY torsocks.conf /etc/tor/torsocks.conf
COPY torrc /etc/tor/torrc

WORKDIR /monero

RUN monerod --version > /version.txt \
    && cat /etc/os-release > /system.txt \
    && cat /proc/version >> /system.txt \
    && ldd $(command -v monerod) > /dependencies.txt \
    && torsocks --version > /torsocks.txt \
    && tor --version > /tor.txt

LABEL author="norman.moeschter@gmail.com" \
      maintainer="norman.moeschter@gmail.com" \
      version="v1.4.0" \
      update="2024-01-22"

VOLUME ["/monero", "/data"]

EXPOSE 18080 18081 28080 28081 38080 38081

ENV USER_ID 1000
ENV LOG_LEVEL 0
ENV DAEMON_HOST 127.0.0.1
ENV DAEMON_PORT 28081
ENV RPC_USER ""
ENV RPC_PASSWD ""
ENV RPC_LOGIN ""
ENV DAEMON_USER ""
ENV DAEMON_PASSWD ""
ENV DAEMON_LOGIN ""
ENV WALLET_PASSWD ""
ENV WALLET_ACCESS ""
ENV RPC_BIND_IP 0.0.0.0
ENV RPC_BIND_PORT 28081
ENV P2P_BIND_IP 0.0.0.0
ENV P2P_BIND_PORT 28080
ENV USE_TORSOCKS NO
ENV USE_TOR NO

ENTRYPOINT ["/entrypoint.sh"]
