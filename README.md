<h1>Advanca <span><a href="https://web3.foundation/grants/"><img align="right" src="docs/images/web3-grants-badge.png" alt="web3-grant3-badge" width="115px"/></a></span></h1>

<p align="center">
  <a href="https://www.advanca.network"><img src="docs/images/advanca-logo.png"  width="300"></a>
</p>

<p align="center">A privacy-preserving general-purpose compute/storage infrastructure for Dapps.</p>

## Getting Started

To quickly see Advanca running, try it out with [Docker Compose](https://docs.docker.com/compose/install/) locally. 

> **Note**: To run the following demo successfully, make sure your machine [supports SGX](https://github.com/advanca/advanca-worker/tree/v0.3.0#intel-sgx-linux-driver) and [have Intel SGX Linux Driver installed](https://github.com/advanca/advanca-worker/tree/v0.3.0#sgx-hardware). If not, you can try the previous [`v0.2.0`](https://github.com/advanca/advanca/tree/v0.2.0) version with SGX simulation mode.

```bash
git clone https://github.com/advanca/advanca.git
cd advanca
docker-compose up --no-start
```

Start the `node` and `aesm` first. It will run in the background.

```bash
docker-compose start node aesm
```

Bring up the `worker`. Logs will be printed.

```bash
docker-compose up worker
```

In a new terminal session, bring up the `client`.

```bash
docker-compose up client
```

Finally, stop and clean up.

```bash
docker-compose stop
docker-compose rm
```

## Documentation

To understand how Advanca works, read our [docs](docs/README.md).

## Changelog

### v0.3 (latest)

* [Advanca Worker v0.3](https://github.com/advanca/advanca-worker/releases/tag/v0.3.0)

  * upgrade to [apache/incubator-teaclave-sgx-sdk `1.1.2`](https://github.com/apache/incubator-teaclave-sgx-sdk/releases/tag/v1.1.2), [Intel SGX for Linux `2.9.1`](https://github.com/intel/linux-sgx/tree/sgx_2.9.1), and rust-toolchain `nightly-2020-04-07`.
  * complete remote attestation through [Advanca Attestation Service `v0.1.0`](https://github.com/advanca/advanca-attestation-service/tree/v0.1.0).
  * refactor the cryptography using [advanca-sgx-helper `v0.1.0`](https://github.com/advanca/advanca-sgx-helper/tree/v0.1.0).
  * change the default build to HW mode in [`advanca/advanca-worker`](https://hub.docker.com/r/advanca/advanca-worker) docker image (**breaking change**).
  * improve the SGX-related documentation in [`README.md`](https://github.com/advanca/advanca-worker/blob/v0.3.0/README.md).

* [Advanca Client v0.3](https://github.com/advanca/advanca-worker/releases/tag/v0.3.0)
  * refactor the cryptography using [advanca-sgx-helper `v0.1.0`](https://github.com/advanca/advanca-sgx-helper/tree/v0.1.0)

* [Advanca Attestation Service v0.1](https://github.com/advanca/advanca-attestation-service/tree/v0.1.0)
  * add a reference implementation providing attestation service for [Advanca Worker](https://github.com/advanca/advanca-worker)
  * add an [`attestee-client` example](https://github.com/advanca/advanca-attestation-service/tree/v0.1.0/examples/attestee-client)
  * add a service [gRPC protocol](https://github.com/advanca/advanca-attestation-service/blob/v0.1.0/aas-protos/protos/aas.proto)

* [AESM Dockerfile](https://github.com/advanca/advanca/tree/v0.3.0/aesm/)
  * build a container for Intel AESM service
  * published at Docker Hub [`advanca/aesm`](https://hub.docker.com/r/advanca/aesm)

* [Demo Documentation v0.3](https://github.com/advanca/advanca/tree/v0.3.0/docs#single-node-and-single-worker)

### v0.2

* [Advanca Worker v0.2](https://github.com/advanca/advanca-worker/releases/tag/v0.2.0)
  * use Square-Root ORAM as storage backend

* [Advanca Client v0.2](https://github.com/advanca/advanca-worker/releases/tag/v0.2.0)
  * update demo usecase

* [oram v0.1](https://github.com/advanca/oram/releases/tag/v0.1.0)
  * Square-Root ORAM
  * SGX Protected FS

* [Demo Documentation v0.2](https://github.com/advanca/advanca/tree/v0.2.0/docs#single-node-and-single-worker)

### v0.1

* [Advanca Node v0.1](https://github.com/advanca/advanca-node/releases/tag/v0.1.0)
  * Substrate-based runtime and node implementation
  * `advanca-core` runtime module for Advanca control-plane functions
  * node APIs based on Substrate RPC

* [Advanca Worker v0.1](https://github.com/advanca/advanca-worker/releases/tag/v0.1.0)
  * encrypted storage service in trusted enclave
  * worker APIs based on gRPC

* [Advanca Client v0.1](https://github.com/advanca/advanca-worker/releases/tag/v0.1.0)
  * demo implementation

* [Demo Documentation v0.1](https://github.com/advanca/advanca/tree/v0.1.0/docs#single-node-and-single-worker)

## Acknowledgements

This project is sponsored by [Web3 Foundation Grants Program](https://web3.foundation/grants/).


## License

[Apache 2.0](./LICENSE)
