# acme-challenge flow

We are implementing a custom ACME-challenge, based on the projects requirements. ACME is a protocol, Automated Certificate Management Environment, that handles specific challenge validation and management of X.509 certificates. Usualy, this is for domains. In our scenario this is for personal identity.

## Flow

```mermaid
sequenceDiagram

participant YUBISIGN_POC as YUBISIGN_POC (ACME-client)
participant YUBIKEY

participant BOULDER as BOULDER_FORK (ACME-server)

loop per PIV slot (order 1,2,3,4)
    YUBISIGN_POC ->> YUBIKEY: Create private key
    YUBIKEY ->> YUBISIGN_POC: Return private key id

    YUBISIGN_POC ->> BOULDER: Create order
    BOULDER -->> YUBISIGN_POC: Return challenge-url

    YUBISIGN_POC ->> BOULDER: Fetch challenge URL
    BOULDER -->> YUBISIGN_POC: Return a random token, saving the challenge details
end

create participant MAX as MAX (OIDC Provider)

YUBISIGN_POC ->> MAX: User logs in at MAX, passing in the acme_tokens (random tokens from challenges)
MAX -->> YUBISIGN_POC: Returning user information, saving the users' JWT

YUBISIGN_POC ->> YUBISIGN_POC: Save the f9 certificate from the YubiKey

loop Per PIV slot (order 4,3,2,1) in the YubiKey
    YUBISIGN_POC ->> YUBIKEY: Request attestation certificate for the slot
    YUBIKEY ->> YUBISIGN_POC: Save the attestation certificate
    YUBISIGN_POC ->> YUBIKEY: Create certificate request
    YUBIKEY ->> YUBISIGN_POC: Certificate request

    YUBISIGN_POC ->> BOULDER: Send request with the users' JWT to finalize challenges
    YUBISIGN_POC ->> BOULDER: Send certificate request
    activate BOULDER
    Note right of YUBISIGN_POC: The userS' JWT has acme_tokens in it: <br> the random tokens from the challenges per PIV-slot


    BOULDER ->> BOULDER: Validate if the acme tokens are <br> contained in the challenges

    BOULDER -->> YUBISIGN_POC: OK
    YUBISIGN_POC ->> BOULDER: Request certificate
    BOULDER ->> YUBISIGN_POC: Certificate
    deactivate BOULDER
    YUBISIGN_POC ->> YUBIKEY: Save certificate
end
```
