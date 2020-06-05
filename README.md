<h1>Advanca <span><a href="https://web3.foundation/grants/"><img align="right" src="docs/images/web3-grants-badge.png" alt="web3-grant3-badge" width="115px"/></a></span></h1>

<p align="center">
  <a href="https://www.advanca.network"><img src="docs/images/advanca-logo.png"  width="300"></a>
</p>

<p align="center">A privacy-preserving general-purpose compute/storage infrastructure for Dapps.</p>

## Getting Started

To quickly see Advanca running, try it out with [Docker Compose](https://docs.docker.com/compose/install/) locally. 

> **Note**: To run the following demo successfully, make sure your machine [supports SGX](TODO:needs link) and have [Intel SGX Linux Driver](ttps://github.com/intel/linux-sgx-driver/tree/sgx_driver_2.6#build-and-install-the-intelr-sgx-driver) installed. If not, you can try the previous [`v0.2.0`](https://github.com/advanca/advanca/tree/v0.2.0) version with SGX simulation mode. 

```
git clone https://github.com/advanca/advanca.git
cd advanca
docker-compose up --no-start
```

Start the `node` first. It will run in the background.

```
docker-compose start node
```

Bring up the `worker`. Logs will be printed. 

```
docker-compose up worker
```

In a new terminal session, bring up the `client`.

```
docker-compose up client
```

Finally, stop and clean up.

```
docker-compose stop
docker-compose rm
```

## Documentation

To understand how Advanca works, read our [docs](docs/README.md).

## Chaneglog

### v0.3 (latest)

* [Advanca Worker v0.3](https://github.com/advanca/advanca-worker/releases/tag/v0.3.0)

* [Advanca Client v0.3](https://github.com/advanca/advanca-worker/releases/tag/v0.3.0)

* [Advanca Attestation Service v0.1](https://github.com/advanca/advanca-attestation-service/tree/v0.1.0)

* [Demo Documentation v0.3]()

### v0.2

* [Advanca Worker v0.2](https://github.com/advanca/advanca-worker/releases/tag/v0.2.0)
  * use Square-Root ORAM as storage backend

* [Advanca Client v0.2](https://github.com/advanca/advanca-worker/releases/tag/v0.2.0)
  * update demo usecase

* [oram v0.1](https://github.com/advanca/oram/releases/tag/v0.1.0)
  * Square-Root ORAM
  * SGX Protected FS

* [Demo Documentation v0.2](docs/README.md#single-node-and-single-worker)

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
