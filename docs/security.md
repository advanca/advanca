# Security Design Review

## Trust Model

The initial trust model under the perspective of the user is:

* User trusts itself
* User trusts AAS
* User does not trust worker (enclave and app)

The worker performs attestation with AAS. AAS trusts the enclave portion of worker and obtains a shared secret with it forming a secure channel. The trust is extended to the worker enclave resulting in the new trust model:

* User trusts itself
* User trusts AAS
* User trusts worker enclave
* User does not trust worker app

## Attestation Process

The function `aas_remote_attest` in advanca-worker implements the attestation of the enclave between the worker and the attesting party as outlined in the Intel® Software Guard Extensions Developer Reference for Linux* OS. Specifically, [this](https://github.com/advanca/advanca-worker/blob/f2e843b0f4bdadfad423f69da7635c3bd5839ea5/app/src/main.rs#L114-L190) implements the standard Intel EPID-based attestation using a linkable quote. The corresponding part for remote attestation in AAS can be found in the function `remote_attest`. Derivation of the required information is done using Intel provided APIs that minimize mis-implementation. Examples of such APIs are, but not limited to, `sgx_ra_proc_msg1`, `sgx_ra_proc_msg2`, `sgx_get_extended_epid_group_id`, `sgx_ra_get_msg1`. The APIs are called via the rust-sgx-sdk which provides rust shim functions to Intel provided C++ SGX libraries. 

The result of remote attestation establishes both trust and a shared secret between AAS and the worker enclave. This shared secret is used to establish a secure channel between AAS and the worker. The secure channel is then used by the worker to request for a vouch from the AAS of its public keys ([code](https://github.com/advanca/advanca-worker/blob/f2e843b0f4bdadfad423f69da7635c3bd5839ea5/enclave/src/lib.rs#L281-L292)). The MAC ensures that only someone who knows the shared secret constructed the message. By verifying the MAC, AAS can be sure that the public keys are sent by the enclave since the shared secret is only known by both of them. AAS then signs over the public keys and sends it back to the enclave. At this point in time, the enclave can publish the signed public keys and any person who wants to use it can check for its authenticity by verifying the signature with that of AAS’s public key. Note that only the trusted worker enclave knows the corresponding private keys to the published public key. The untrusted worker app (or any third party) cannot modify the published public key since they do not know the shared secret.

Further, AAS’s public key is being embedded into the enclave binary ([code](https://github.com/advanca/advanca-worker/blob/f2e843b0f4bdadfad423f69da7635c3bd5839ea5/enclave/src/lib.rs#L69-L81)) and this acts as a trust anchor. This public key is used to verify the authenticity of AAS during the attestation process and is not modifiable by the attacker since the enclave binary has to be signed using Advanca’s Intel SGX signing keys.

**Cryptographic Libraries Review:**

All of the required cryptographic functionalities are provided by 3rd-party libraries that are, to a degree, accepted by the community, including but not limited to:

* **AES-128** - Intel Cryptographic Library
* **secp256r1** - Intel Cryptographic Library
* **RSA** - Intel Cryptographic Library
* **sr25519** - Parity’s Schnorrkel Rust Library
* **TLS/SSL** - Openssl, Ring (BoringSSL), Rustls (Ring)

**Usage of cryptographic primitives:**

For secure communication between the enclave and any other party, [AES128-GCM](https://github.com/advanca/advanca-sgx-helper/blob/d4818dd4db2e63a521ef7c2fa6e29363ffdec4ad/advanca-crypto/src/advanca_cryptolib/mod.rs#L56-L96) is used to provide both confidentiality and integrity. Using an AEAD cipher provides protection against malleability attacks. The usage of AES128-GCM is in accordance with NIST SP 800-38D.  Nonce is set to a random 96 bits (12 bytes) value ([code](https://github.com/advanca/advanca-sgx-helper/blob/d4818dd4db2e63a521ef7c2fa6e29363ffdec4ad/advanca-crypto/src/advanca_cryptolib/mod.rs#L65)) as described in section 8.2.2 of 800-38D. For freshness of key, ephemeral asymmetric task keys are generated for each task ([code](https://github.com/advanca/advanca-worker/blob/f2e843b0f4bdadfad423f69da7635c3bd5839ea5/enclave/src/lib.rs#L317-L318)) and hence each task has a separately derived secret key for use in AES128-GCM. However, care has to be taken to ensure that keys are renewed before the maximum number of operations allowed for a single key in AES128-GCM by NIST (2^32 transactions).

Both secp256r1 and sr25519 are used as asymmetric ciphers to establish a shared secret between the enclave and any other party it communicates with using ECDH. The keys used in ECDH are ephemeral keys generated only for the particular session. As such, it provides perfect forward secrecy to any communication done via the secure channel. Intel’s secp256r1 signature is a fixed-length (PKCS#11-style) ECDSA signature.

Currently there is no usage of RSA primitives in the code.

## Task Confidentiality and Integrity

User publishes its identity public keys onto the chain using its blockchain identity ([code](https://github.com/advanca/advanca-worker/blob/f2e843b0f4bdadfad423f69da7635c3bd5839ea5/client/src/main.rs#L187-L191)). This binds the identity public keys to the blockchain account. Worker_enclave performs a similar operation and binds its identity public key to the worker’s blockchain account. User publishes a Task onto the chain with its task public keys signed using its identity private keys. Worker_enclave then accepts the task and posts its task public keys onto the chain. Note that both user and worker_enclave can use the identity public keys on chain to verify the integrity of the task pubkeys obtained. The shared secret can then be derived using their secret task private key with the other party’s task public key. Note that in this construction, only public keys are broadcasted and only the two participants with their respective private keys are able to derive the same shared secret value. The validity of the public keys can also be verified using identity keys. 

Note that the scheme is resistant to even an eclipse attack on the blockchain to affect the public keys that the participants see. All enclave public keys published on the blockchain have a single root of trust rooted in the attestation server, in the demo’s case, AAS’s public key. Hence all modifications must come from an attested enclave which is guaranteed to be executing in an expected manner. Although malicious actors can modify the user’s published public keys on the chain, this will result in a different secret being derived by the enclave, compared to that of the user, resulting in a failed authentication when decryption of the encrypted messages are attempted.

## Security Conditions

### Untrusted domain reading trusted memory regions

Memory integrity of trusted memory regions are guaranteed by Intel SGX via the hardware. The enclave’s code and data is stored in Processor Reserved Memory (PRM), which is a subset of DRAM that cannot be directly accessed by other software, including system software and System Management Module code (Ring 2). Direct Memory Access targeting the PRM is also rejected by the CPU in order to protect the enclave from other peripherals. Specifically, the sensitive data is encrypted and MAC-ed by the Memory Encryption Engine (MEE). Further, any access of the PRM from untrusted code will result in the hardware MMU swapping in an abort page preventing the access. A demo showcasing this in action can be found in [here](https://github.com/advanca/advanca-worker/blob/37e5fd0acd56cee645e6325ff019f11f3e71ad12/enclave/src/lib.rs#L535-L555) and [here](https://github.com/advanca/advanca-worker/blob/37e5fd0acd56cee645e6325ff019f11f3e71ad12/app/src/main.rs#L552-L562).

### Untrusted domain reading communication between enclave and user

As described in the task confidentiality review, a shared secret only known to the enclave and user can be derived securely. Since all secure communication is performed by encrypting the message using aes128-gcm, which is an AEAD, any attempts to modify the message will result in a failed integrity check (MAC mismatch). Decryption of the message without knowing the shared secret would also fail. A demonstration of it can be found [here](https://github.com/advanca/advanca-worker/blob/37e5fd0acd56cee645e6325ff019f11f3e71ad12/app/src/grpc.rs#L110-L118).
