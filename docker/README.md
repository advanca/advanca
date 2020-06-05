# Docker

This directory contains files for running advanca using locally built images.

This is suitable for testing local changes using docker.

## Get SGX ready

Thanks to Docker we have minimized the requirements on the host machine, but [Intel SGX Linux Driver](https://github.com/intel/linux-sgx-driver/tree/sgx_driver_2.6#build-and-install-the-intelr-sgx-driver) is still needed, and the device `/dev/isgx` needs to be there.

To check if the device is ready, run:

```
$ file /dev/isgx
/dev/isgx: character special (10/56)
```

If anything different shows up, you might need to re-install the driver.

## Build Images

The following images will be built through `docker-compose build`

- `advanca-node:latest`
- `advanca-worker:latest`
- `advanca-client:latest`
- `aas:latest`
- `aesm:latest`

To build them, simply run:

```bash
docker-compose build
```

Depending on your machine, the build may take a while to finish.

## Prepare Secrets

Add the required secret files into `./aas-secretes`. Check [Advanca Attestation Service](https://github.com/advanca/advanca-attestation-service) for more information. Be careful that you don't commit these secrets into the version control.

## Run

Create the containers first.

```bash
docker-compose up --no-start
```

You can check the contaienrs `docker-compose ps`. Note that the containers are not started yet at this step.

```console
$ docker-compose ps
     Name                    Command               State    Ports
-----------------------------------------------------------------
docker_aas_1      /usr/local/bin/aas-server        Exit 0
docker_aesm_1     /bin/sh -c ./aesm_service  ...   Exit 0
docker_client_1   /usr/local/bin/advanca-cli ...   Exit 0
docker_node_1     /usr/local/bin/advanca-nod ...   Exit 0
docker_worker_1   /usr/local/bin/advanca-wor ...   Exit 0
```

Launch `node`, `aas`, and `aesm` at the background first.

```console
$ docker-compose start node aas aesm
Starting node ... done
Starting aesm ... done
Starting aas  ... done
```

Then bring `worker` up in the foreground with the logs followed.

```
$ docker-compose up worker
docker_aas_1 is up-to-date
docker_node_1 is up-to-date
docker_aesm_1 is up-to-date
Starting docker_worker_1 ... done
Attaching to docker_worker_1
worker_1  | [WARN ] token file enclave.token not found
worker_1  | [DEBUG] creating enclave ...
worker_1  | [DEBUG] enclave created
...
worker_1  | [INFO ] registering worker ...
worker_1  | [INFO ] registered worker (extrinsic=0x09fa46a553fd0c4bc887d4d608e0ab59499a1e30a02a9cfb3c3257a0f0d84e60)
worker_1  | [INFO ] listening for new task ...
```

It should wait at `listening for new task`. Now we bring `client` up in a new terminal session.

```
$ docker-compose up client
docker_node_1 is up-to-date
Starting docker_client_1 ... done
Attaching to docker_client_1
client_1  | [INFO ] sr25519 keypair generated: 12a3e16358406910ecb210a14ce1936bd5080700bea1a384dbe82821de0cb04d
client_1  | [INFO ] funded account 12a3e16358406910ecb210a14ce1936bd5080700bea1a384dbe82821de0cb04d (5CV9QFhn...)
...
```

Both `worker` and `client` will proceed until the end.

You can retrive the container logs through `docker-compose log <name>`:

* `docker-compose logs worker`
* `docker-compose logs client`
* `docker-compose logs node`
* `docker-compose logs aas`
* `docker-compose logs aesm`

In the end, remember to stop all the containers.

```console
$ docker-compose stop
Stopping docker_node_1 ... done
Stopping docker_aesm_1 ... done
Stopping docker_aas_1  ... done
```

Also you can clean everything up if that's what you need.

```console
$ docker-compose rm
Going to remove docker_client_1, docker_worker_1, docker_node_1, docker_aesm_1, docker_aas_1
Are you sure? [yN] y
Removing docker_client_1 ... done
Removing docker_worker_1 ... done
Removing docker_node_1   ... done
Removing docker_aesm_1   ... done
Removing docker_aas_1    ... done
```

