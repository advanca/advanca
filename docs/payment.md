# Payments and rewards

The payment/rewards system is typically one part of the system where different blockchain operators seek to customize and differentiate themselves. As such, what we hope to achieve in this milestone is an example on how a simple reward system can be built on top of the accounting information provided by the enclave.

**Simple reward/payment system:**

In this simple system, the user is charged for the duration which the enclave provides the service. The process is as follows:

* User submits task
* The maximum amount of tokens needed for the task is being reserved (lease * TOKEN\_PER\_BLOCK)
* If lease is unlimited, then 10 days worth of tokens is being reserved
* If the account lacks the amount of tokens, the submitted task is rejected
* Worker performs the submitted task
* User aborts the task early
* Worker submits accounting evidences to the chain
* Worker completes the submitted task
* For each of the submitted evidence, the node will verify authenticity of the evidence that it is indeed from the enclave is has not been tampered with.
* The amount (blocks\_alive * TOKEN\_PER\_BLOCK) is repatriated from the user's reserved amount to the worker
* The remaining reserved amount is released back to the user

