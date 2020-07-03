# Accounting Service

The design of the accounting service for Advanca is aimed at providing an accurate reporting of the services provided. Specifically, the accounting service has to protect both the user and worker against each other from malicious tampering and mis-reporting.

**There are several limitations that we have to work around:**

* There is no trusted time service within Intel SGX enclaves
* There is no trusted way to measure elapsed time or cpu cycles in SGX1
  * RDTSC is available in SGX2There is no trusted IO available for the enclave

  **Accounting information which we are interested in:**

  * Uptime
  * Storage in/out/size
  * Data in/out

  With that in mind, we propose the design where the worker provides evidence of the accounting information which is verifiable by any third party. The provided evidence allows the user to verify that the worker has indeed provided the resources as claimed in the accounting information. It also allows the worker to assert to third parties that it has indeed provided the required resources in case a dispute arises with the user.

  **The current design works as follows:**
  For uptime, the worker can prove that it is online for a particular block by using the block’s hash as a challenge. Since Intel SGX ensures the code integrity of the enclave, for both storage and data statistics, the enclave can account for them by keeping track of the requests made to the enclave and the responses of the enclave. The enclave can then generate an evidence containing all required information and sign on it using the worker's task private key which is known only to the enclave, preventing modifications by any other party. 

  Note that this is insufficient as a malicious worker(untrusted) can overclaim uptime by going back in history and collecting all the finalized block hashes, providing them to the enclave, and obtaining the evidence. In order to address this problem, we will need to enforce a temporal constraint on the creation of the evidence. As the enclave does not have any trusted time, we will need to have a source of trusted time. 

  Currently, we utilize a trusted time service which is provided by Advanca Attestation Service (AAS). Specifically, the trusted time service takes some data, provides a timestamp and signs over both the data and timestamp. By verifying the signature, external parties can ensure that the timestamp provided is indeed what it is supposed to be. Note that this trusted time service can be provided by any provider which the community trusts and need not be constrained to that of AAS.

  Once the task is completed/aborted or at any point in time which the worker prefers, it can submit the evidence for the task onto the chain to enable third party and/or the user to verify that it as provided the reported resources.
