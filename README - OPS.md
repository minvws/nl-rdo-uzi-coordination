# OPS Documentation
## Introduction
This documentation will contain relevant information for OPS on how to configure the UZI project. More generic information
regarding what the UZI project is and does can be found in the regular `README.md`.

## Yivi - Revocation
Yivi is the digital wallet used as one of the possible login methods within the UZI project. Data that is disclosed or
inserted into this wallet can be revoked. This means the data is marked as "outdated", but that does not make it 
impossible to login just yet. There is a config variable in the `nl-uzi-login-controller/app.conf` called 
`irma_revocation` (still needs to be renamed to Yivi). When this is set to `true` it means that the login controller will 
check whether a Yivi card contains revoked data, only then does it block the login.

Revocation does not work out of the box in Yivi itself either, and needs to be enabled in the configuration. 
Per the Yivi docs:  
(Note: The Yivi docs themselves still talk about IRMA, the former name of Yivi)
   > In IRMA, revocation is enabled per credential type in the IRMA scheme. If so, when properly configured 
   > (more on that below) the issuer's IRMA server will issue revocation-enabled credentials of that type. During 
   > disclosures the IRMA app can then prove nonrevocation (but it will only do so if explicitly asked for by the 
   > requestor).  
   > ...  
   > Revocation for a credential type is enabled in the scheme by including at least one RevocationServer XML tag and a
   > separate Attribute XML tag with a revocation="true" attribute inside description.xml:
```xml
<IssueSpecification version="4">
  <RevocationServers>
    <RevocationServer>http://example.com/</RevocationServer>
  </RevocationServers>
  <!-- ... -->
  <Attributes>  
    <Attribute id="xyz" >
      <!-- ... -->
    </Attribute>
    <!-- ... -->
    <Attribute revocation="true" />
  </Attributes>
</IssueSpecification>   
```
A command to then revoke a card would look like:  
`curl --header "Content-Type: application/json" --request POST --data '{"@context": "https://irma.app/ld/request/revocation/v1","type": "irma-demo.uzipoc-cibg.uzi-2","revocationKey": "uziId-900020118-ura-87654321"}' http://localhost:8088/revocation`  
In case you need more info on this, Yivi's documentation on revocation can be found [here](https://irma.app/docs/revocation/).

## Yivi - Issuers
For creating or rather issuing a new Yivi card an Yivi issuer is required. The current ones used in this project (demo/pilot/acceptance) can be found
[here](https://github.com/privacybydesign/irma-demo-schememanager/tree/master/uzipoc-cibg/Issues). When configuring a new
issuer this needs to be updated across the .conf of three repositories and the revocation server(?) where `<issuer>` could be
`uzi-acceptance`, `uzi-2`, ...:  
1. nl-rdo-max   
`irma_prefix = irma-demo.uzipoc-cibg.<issuer>`
2. nl-uzi-login-controller  
`irma_disclose_prefix = irma-demo.uzipoc-cibg.<issuer>`
3. nl-uzi-yivi-disclosure-web  
`YIVI_DISCLOSURE_PREFIX=irma-demo.uzipoc-cibg.<issuer>`

The issuers themselves are managed by Yivi. And any changes to them need to go through their relevant repositories.

## nl-rdo-max - clients.json
MAX, the login "portal", has a file called [clients.json.example](https://github.com/minvws/nl-rdo-max/blob/main/clients.json.example). 
A copy of this file needs to be created called `clients.json`. This is handled by `make setup`, but for a deployment it needs
some additional configuration. The field called `redirect_uris` contains uris to which the front-end is allowed to redirect to. 
By default, this will have uri(s) containing `localhost`. This should ofcourse be replaced by the correct host name, which 
in this case should refer to the [nl-uzi-yivi-disclosure-web](https://github.com/minvws/nl-uzi-yivi-disclosure-web) repository.

## nl-rdo-max - Mocked DigiD/UZI data
When logging in with the DigiD Mock method the system will retrieve data from a custom .json file. This file is managed by OPS.

## nl-uzi-login-controller - Yivi Status checks
When logging in using Yivi, there has to be a continuous check if the Yivi session has been started successfully. The Yivi Javascript client does this
first by using Server Sent Events. If this fails it falls back to http polling. This needs to be configured
in the Yivi instance as well as the front-end:

**Yivi instance/binary**  
For the Yivi binary SSE is disabled by default. It needs to be enabled by either adding this to the config or by appending the `--sse`
flag when starting the server.
E.g.:
`ExecStart=/usr/local/yivi/current/yivi-linux-amd64 server -c /etc/rdo/yivi.env.json --sse`

**Front-end**  
The rate at which Yivi checks the status by default is once every 500ms (polling). Config variables have been added to 
the login-controller .conf to configure this. The rate limiter (acceptance, prod.) will only accept requests every 1000ms, 
so the session_polling_interval should never be set lower than 1000. If these variables are not present in the config below values are used as fallback:
```
# Whether the front-end will try to connect over Server Sent Events instead of http polling. 
session_server_events = False
# If it can not connect to the SSE's, after how long it should stop trying
session_server_events_timeout = 2000
# If SSE is disabled or fails, it will fallback to polling. It should check every ...ms for the status.
session_polling_interval = 1000
```

If SSE is disabled in the Yivi binary but enabled on the front-end, Yivi will return an error saying SSE is disabled and immediately fallback to polling.

## nl-uzi-yivi-disclosure-web - Yivi validity period
When Yivi issues a new card it has a validity period. This is configurable in `nl-uzi-yivi-disclosure-web/.env`:
`YIVI_VALIDITY_PERIOD_IN_WEEKS=12`

## Certificates
The applications communicate through signed and optional encrypted jwt tokens.
Every application has its own set of keys and needs the certificates of the applications for which it needs to validate the received messages.

### nl-rdo-max
Signs messages to:
- nl-uzi-login-controller
- nl-uzipoc-register-api

### nl-uzi-login-controller
Signs messages to:
- nl-rdo-max

### nl-uzipoc-register-api
Signs messages to:
- nl-uzi-login-controller  

Decrypts messages from:
- nl-rdo-max


Below is a list of the required certificates to run this project locally. It may look a bit cluttered but if signing and/or decrypting is going 
wrong and you're not sure why, you could use this list to cross-reference the certs on acceptance.
1. For MAX there is a .conf variable `jwe_sign_crt_path`. For me locally the value of this is `secrets/nl-rdo-max.crt`.
This `nl-rdo-max.crt` occurs in the following locations:
   - `nl-rdo-max/secrets/nl-rdo-max.crt`, referenced by `jwe_sign_crt_path`
   - `nl-rdo-max/jwks-certs/nl-rdo-max.crt`, referenced by nothing. It exposes all certs in this folder through an endpoint.
   - `nl-uzi-login-controller/secrets/nl-rdo-max.crt`, referenced by `jwt_issuer_crt_path`
   - `nl-uzipoc-register-api/secrets/nl-rdo-max.crt` (This is a mock uzi register. 
   For acceptance this should be handled with the CIBG and their respective register)
2. For MAX there is a .conf variable `jwe_sign_priv_key_path`. For me locally the value of this is `secrets/nl-rdo-max.key`.
This `nl-rdo-max.key` occurs in the following locations: 
   - `secrets/nl-rdo-max.key`, referenced by `jwe_sign_priv_key_path`
3. For the login controller there is a variable in the `httpd-ssl.conf` called `SSLCertificateFile`. For me locally the 
value of this is `"/usr/local/secrets/nl-uzi-login-controller.crt"`. This `nl-uzi-login-controller.crt` occurs in the following locations: 
   - `nl-uzi-login-controller/secrets/nl-uzi-login-controller.crt`, referenced by `httpd-ssl.conf` - `SSLCertificateFile`
   - `nl-uzipoc-register-api/secrets/nl-uzi-login-controller.crt` (This is the fake uzi register. 
   For acceptance this should be handled with the CIBG and their respective register)
4. For the login controller there is a variable in the `httpd-ssl.conf` called `SSLCertificateKeyFile`. For me locally the 
value of this is `"/usr/local/secrets/nl-uzi-login-controller.key"`. This `nl-uzi-login-controller.key` occurs in the following locations: 
   - `nl-uzi-login-controller/secrets/nl-uzi-login-controller.key`, referenced by `httpd-ssl.conf` - `SSLCertificateKeyFile`
5. For the nl-uzipoc-register-api repository there are certificates as well. As said before, this repository is not used on acceptance. 
The CIBG has their own UZI register in place for that instead. It might still be relevant to know what certificates the nl-uzipoc-register-api app has,
since the way the certificates work should not be that different between the two. So, there is a
.conf variable called `jwt_sign_crt_path`. For me locally the values of this is `secrets/nl-uzipoc-register-api.crt`.
This `nl-uzipoc-register-api.crt` occurs in the following locations:
   - `nl-uzipoc-register-api/secrets/nl-uzipoc-register-api.crt` referenced by, `jwt_sign_crt_path`
   - `nl-rdo-max/secrets/jwks-certs/nl-uzipoc-register-api.crt` referenced by nothing. It exposes all certs in this folder through an endpoint.
6. For the uzipoc-register there is a .conf variable called `jwt_sign_priv_key_path`. For me locally the value of this is `secrets/nl-uzipoc-register-api.key`
This `nl-uzipoc-register-api.key` occurs in the following locations:
   - `nl-uzipoc-register-api/secrets/nl-uzipoc-register-api.key` 
7. For the Yivi disclosure client there is a .env variable called `OIDC_DECRYPTION_KEY_PATH`. For me locally the value of this is `../secrets/nl-uzi-irma-disclosure-web.key`
This `nl-uzi-yivi-disclosure-web.key` occurs in the following locations:
   - `nl-uzi-yivi-disclosure-web/secrets/nl-uzi-yivi-disclosure-web.key` referenced by, `OIDC_DECRYPTION_KEY_PATH`
   - Last but not least. The Yivi disclosure web also has a `secrets/nl-uzipoc-register-api.crt`. This is not referenced by the client itself, but
does also exist as `nl-rdo-max/secrets/clients/test_client/test_client.crt`
   
Alternatively, you can check the `setup-secrets.sh` and `copy-projects.sh` scripts to see how the certs are created and copied for locally running the project.
