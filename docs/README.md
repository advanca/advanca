# Documentation

## Architecture

In the current design, Advanca has two different planes, control plane and compute/storage plane.

The control plane is the coordinator to outsource tasks and distribute rewards to compute/storage plane, as well as manages the registration in control and compute/storage plane with stakes and evaluates the performance of these nodes.

The compute/storage plane is for compute/storage nodes to accept and accomplish computational/storage tasks assigned by the control plane. Any machine that meets the requirements like a high volume disk and a trusted hardware such as Intel SGX or Arm TrustZone, can join Advanca to become a compute/storage worker.

### Advanca Node

[Advanca node](https://github.com/advanca/advanca-node) is the implementation of the control plane. In Advanca, all the nodes in the control plane will work together to maintain the consensus of the managed states, including worker and user registration, task managements, reward distribution, resource accounting, staking and reputation.

#### API

Nodes provide APIs for the public to join the network and for the registered entities to interact with the control plane. 

You can find the rust docs for the core module `advanca-core` [here](https://advanca.github.io/advanca-node/advanca_core/).

### Advanca Worker

[Advanca Worker](https://github.com/advanca/advanca-worker) is the implementation of the compute/storage plane where a trusted enclave is created for private task execution. The worker also provides APIs for the user to directly interact with the outsourced tasks.

#### API

Workers provide a set of APIs accessible to authenticated users, who are the owners of the outsourced tasks. The API is implemented with gRPC and protobuf, making it easy to use in a broad range of [languages](https://grpc.io/docs/tutorials/).

Currently, the definition of storage API can be found at [advanca-worker/protos/storage.proto](https://github.com/advanca/advanca-worker/blob/master/protos/storage.proto).

## Deployment Example

### Single Node and Single Worker

Here's the single-node, single-worker demo included in Advanca v0.1. The figure below presents the interaction sequences between programs and modules in the form of RPC calls, function calls, enclave trusted calls and events subscription, etc.

> Note: The diagram is simplified and may not reflect the latest implementation in the code.

![image](images/workflow-v0.1.png)

<p align="center"><i>Figure: Single-Node Single-Worker Workflow</i></p>

Three main parties are:

* **advanca-client**: the user who request encrypted stroage resource
* **advanca-node**: the consensus node providing control-plane core functions and states storage
* **advanca-worker**: the resource provider with trusted hardware, where two componensts are selectively shown in the worflow:
  * **enclave**: the trusted execution environment processing the encrypted request
  * **sealed-storage**: the sealed (or encrypted) storage stored outside of the enclave

Now let's look at the workflow from different angles.

#### Registration

At the beginning, the `advanca-node` manages no user and workers, nor any tasks. Users and workers need to make the registration with the signle-node chain and lock some fund as the deposit. This is done by submitting a signed extrisinic using the registration functions.

The worker registration involves some preparation beforehand, and this is where it differs from user registration. As a worker with trusted hardware, remote attestation will be done first with official authorities. As a result, the attestation report will be made public for anyone to verify its claim, i.e. a trusted environment. In Advanca, this report is stored on chain as part of the registration.

#### Task Management

The tasks are compute and storage resource request created by users. `advanca-node` manages task metadata and lifecycle information on chain to maintain the transparency. Users submit tasks to the chain, and workers accept the task and start the task execution. Users and workers, like customers and providers, will start the engagement first through the chain, before they talk to the other side for the task details.

Not all task information stored on chain are publicly viewable. For example, the worker's service endpoint `worker_url` is stored as ciphertext encrpyted by the task owner's public key when the worker accepts a task. It provides certain protection for the worker and more protections like this come in the future.

More details about task management are not covered here as the protocol is evolving rapidly. Keep an eye on the `advanca-core` module in our `advanca-code` repository.

#### Task Execution

The execution of the task begins when the worker accepts the task submitted previously by the user. In this particular example, the worker provides secure storage service, which allows direct user interaction in an end-to-end secure manner. And for simplicity, asymmetric encryption is used to encrypt the request by the user and the response by the enclave, however it can be switched to other mechanisms like standard TLS.

Outside the enclave, the sealed storage is where the user data is stored. As per the design of the trusted hardware, disk storage is typically outside of the security perimeter. So the sealed storage upgrades the capacity of the secured data through a encrypted secure dump of the user data involved. It can be reloaded into the enclave anytime when the user needs to access it.
