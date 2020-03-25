FROM ubuntu:bionic-20200311 as builder

ARG SGX_SDK_URL=https://download.01.org/intel-sgx/sgx-linux/2.7.1/distro/ubuntu18.04-server/sgx_linux_x64_sdk_2.7.101.3.bin
ARG SGX_SDK_BIN=sgx_linux_x64_sdk_2.7.101.3.bin

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl ca-certificates make build-essential cmake libssl-dev protobuf-compiler golang automake libtool pkg-config

RUN curl -sO $SGX_SDK_URL && chmod +x $SGX_SDK_BIN && \
    echo -e 'no\n/opt/intel' | ./$SGX_SDK_BIN && \
    curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain nightly-2019-11-25 -y && \
    export PATH=$PATH:$HOME/.cargo/bin && \
    rustup target add wasm32-unknown-unknown
    
ENV SGX_DEBUG=1
ENV SGX_MODE=SW

COPY advanca-node /advanca-node
COPY advanca-worker /advanca-worker

WORKDIR /advanca-worker

RUN . $HOME/.cargo/env && \
    . /opt/intel/sgxsdk/environment && \
    make

#=============== worker =======
FROM ubuntu:bionic-20200311 as worker

#TODO: make this consistent with previous stage
ARG SOURCE_PATH=/advanca-worker

COPY --from=builder $SOURCE_PATH/bin/advanca-worker /usr/local/bin

# TODO: copy only the dynamic libraries
COPY --from=builder /opt/intel/sgxsdk /opt/intel/sgxsdk

RUN	useradd -m -u 1000 -U -s /bin/sh -d /advanca advanca

COPY --from=builder $SOURCE_PATH/bin/enclave.signed.so /advanca

RUN apt-get update && apt-get install -y --no-install-recommends libssl-dev

WORKDIR /advanca
USER advanca
EXPOSE 12345

ENV LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/opt/intel/sgxsdk/sdk_libs"

ENTRYPOINT ["/usr/local/bin/advanca-worker"]

#============== client ========
FROM ubuntu:bionic-20200311 as client

#TODO: make this consistent with previous stage
ARG SOURCE_PATH=/advanca-worker

COPY --from=builder $SOURCE_PATH/bin/advanca-client /usr/local/bin

RUN	useradd -m -u 1000 -U -s /bin/sh -d /advanca advanca

WORKDIR /advanca
USER advanca

ENTRYPOINT ["/usr/local/bin/advanca-client"]