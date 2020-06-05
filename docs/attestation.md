# Attestation

The process of establishing trust and verifying the software and hardware is known as **attestation**. Advanca uses Intel SGX to provide the trusted computing platform and Intel provides a remote attestation protocol based on a group signature scheme known as EPID. The **remote attestation** protocol is designed for the use of a trusted service provider attesting that the software requesting service is indeed running the proper software and hardware. However, this is different in the use-case of Advanca where the roles are reversed (user requesting service is attesting that the service provider is running in a trusted setting). How this affects the design of the attestation process will be highlighted in a subsequent section.

## Remote Attestation Protocol

A high level overview of the remote attestation protocol is as follows:

> **Definitions**:
>
> * **ISV Application** (or **App**): Application running on enclave. It has both trusted and untrusted parts.
> * **ISV Remote Attestation Server** (or **Provider**): Service provider to ISV app, usually author of said ISV app.
> * **Intel Attestation Service** (or **IAS**): Intel’s remote attestation service
> * **SigRL**: Signature revocation list
>
> At any point if verification fails or the reply is negative, attestation is terminated.

1. ISV Application (**App**) request for a service / secret from the service provider (**Provider**).
2. **Provider** challenges **App** to prove that it is running the proper enclave on a genuine SGX platform.
3. **App** obtains the extended group id (**ExGID**) and sends to **Provider**.
4. **Provider** replies if **ExGID** is accepted or not.
5. **App** generates an ephemeral secp256r1 keypair and sends `msg1` to **Provider**.
6. **Provider** sends a request for **SigRL** to **IAS** using an Intel API key bound to its account.
7. **IAS** provides the **SigRL** to **Provider**
8. **Provider** processes `msg1`, generates `msg2` and sends it to **App**.
   1. Verifies `msg1` using public key (non-ephemeral secp256r1) of **App**.
9. **App** processes `msg2`, generates `msg3` and sends it to **Provider**.
   1. Get **Provider**'s ephemeral public key from `msg2`
   2. Derive shared secret using **Provider**'s ephemeral public key and **App**'s ephemeral private key.
   3. Verifies `msg2` using derived secret. 
10. **Provider** extracts the attestation report from `msg3` and send it to **IAS** for verification using API key.
11. **IAS** verifies the attestation report using the CPU key, signs it using Inte's private key and sends it back to **Provider**.
12. **Provider** verifies the signature of the report (with Intel's public key) and inspects the quote to verify the authenticity of both software and hardware.
13. **App** is either attested or not:
    1. If attested, communication can be done using the derived shared secrets.
    2. If not attested, rejection message is sent to **App**.

<p align="center"><a href="https://software.intel.com/content/www/us/en/develop/articles/code-sample-intel-software-guard-extensions-remote-attestation-end-to-end-example.html"><img src="https://software.intel.com/content/dam/develop/external/us/en/images/guard-extensions-remote-attestation-end-to-end-example-fig3-781729.png"></a></p>

<p align="center"><i>Figure: Intel Remote Attestation Flow (<a href="https://software.intel.com/content/www/us/en/develop/articles/code-sample-intel-software-guard-extensions-remote-attestation-end-to-end-example.html">source</a>)</i></p>

### Design Choices

In Advanca’s case, there are 3 entities involved in the framework. **User**, **Worker** and **Node**. **User** wants to attest that **Worker** is indeed running on trustworthy software and hardware before sending the sensitive data or performs sensitive computation. The requests and accounting are made on a public ledger maintained by one or multiple **Nodes**.

Possible attestation designs differ with who is the challenger:

* **User**: If **User** is made the challenger, then Intel’s remote attestation process can be used before the request is made. The request can then be done using the derived shared secret which is bound to the attestation and known only to the enclave.
* **Worker**: If **Worker** is made the challenger, then rather than attesting to the challenger, **Worker** would generate the report and bind it with its public ledger identity. The public ledge identity must be generated within the enclave and known only to the enclave. The report is sent to **IAS** for Intel to verify. The Intel signed report can then be made public and used to prove that it is indeed running on a trusted platform. The report can be verified using Intel’s public key. This is the approach which [SubstraTEE](https://github.com/scs/substraTEE) uses.
* **Node**: If **Node** is made the challenger, then the remote attestation process occurs when the **Worker** wants to register itself on the public ledger. When **Worker** wants to register itself on the public ledger, **Node** will challenge **Worker** using Intel’s remote attestation protocol. Once **Worker** is attested by **Node**, the intel signed report can be uploaded as attestation evidence.

## Advanca Attestation Service

[Advanca Attestation Service](https://github.com/advanca/advanca-attestation-service) (**AAS**) is a reference implementation of the deputy attestation service.

### Trust Establishment

First, **AAS** remotely attests that **Worker** is indeed trusted. **Worker** generates a secp256r1 keypair used to identify itself for this attested session. Note that the private portion of the keypair is known only to the enclave. 

After attestation, **Worker** binds the public portion (`worker_attested_pubkey`) of the keypair with the derived secret from the attestation and sends it to **AAS**. **AAS** can verify that the public portion of the key indeed comes from the enclave by using the shared secret as only **AAS** and the trusted part (enclave) of **Worker** knows it. **AAS** then signs the public key with nonce or trusted time. **AAS** sends the signed report back to **Worker** where it can publish it on the public ledger. Any **User** which trusts **AAS** can verify the authenticity of the report by verifying the signature.