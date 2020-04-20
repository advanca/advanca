# Docker

This directory contains files for running advanca using locally built images.

This is suitable for testing local changes in `advanca-node` or `advanca-worker` using docker.

## Build and Test

To build the image `advanca-node:latest`, `advanca-worker:latest`, `advanca-client:latest`

```shell
docker-compose build
```

Then follow the [Getting Started](../README.md#getting-started) instructions to complete the testing workflow.
