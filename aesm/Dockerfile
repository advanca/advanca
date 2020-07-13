FROM ubuntu:18.04

ARG PSW_PKG_VERSION=2.9.101.2-bionic1
RUN apt-get update && apt-get install -y dkms gnupg2 apt-transport-https software-properties-common curl && \
    curl -fsSL  https://download.01.org/intel-sgx/sgx_repo/ubuntu/intel-sgx-deb.key | apt-key add - && \
    add-apt-repository "deb https://download.01.org/intel-sgx/sgx_repo/ubuntu bionic main" && \
    apt-get update && \
    apt-get install -y \
        libsgx-aesm-launch-plugin=$PSW_PKG_VERSION \
        libsgx-enclave-common=$PSW_PKG_VERSION \
        libsgx-epid=$PSW_PKG_VERSION \
        libsgx-launch=$PSW_PKG_VERSION \
        libsgx-quote-ex=$PSW_PKG_VERSION \
        libsgx-uae-service=$PSW_PKG_VERSION \
        libsgx-urts=$PSW_PKG_VERSION


USER aesmd
WORKDIR /opt/intel/sgx-aesm-service/aesm

ENV LD_LIBRARY_PATH=/opt/intel/sgx-aesm-service/aesm
ENV AESM_PATH=/opt/intel/sgx-aesm-service/aesm

VOLUME /var/run/aesmd

CMD /opt/intel/sgx-aesm-service/aesm/linksgx.sh && \
	mkdir -p /var/run/aesmd/ && chown -R aesmd:aesmd /var/run/aesmd/ && chmod 0755 /var/run/aesmd/ && \
	chown -R aesmd:aesmd /var/opt/aesmd/ && chmod 0750 /var/opt/aesmd/ && \
	./aesm_service --no-daemon
