<h1>Advanca <span><a href="https://web3.foundation/grants/"><img align="right" src="docs/images/web3-grants-badge.png" alt="web3-grant3-badge" width="115px"/></a></span></h1>

<p align="center">
  <a href="https://www.advanca.network"><img src="docs/images/advanca-logo.png"  width="300"></a>
</p>

<p align="center">A privacy-preserving general-purpose compute/storage infrastructure for Dapps.</p>

## Getting Started

To quickly see Advanca running, try it out with [Docker Compose](https://docs.docker.com/compose/install/) locally.

```
git clone https://github.com/advanca/advanca.git
cd advanca
docker-compose up --no-start
```

Start the node first. It will run in the background.

```
docker-compose start node
```

Bring up the worker and client. Logs will be printed. 

```
docker-compose up worker client
```

Finally, stop and clean up.

```
docker-compose stop
docker-compose rm
```

## Documentation

To understand how Advanca works, read our [docs](docs/README.md).

## Roadmap

### v0.2 (latest)

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
