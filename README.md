# What is the project *Toekomstbestendig maken UZI*?
## Introduction 
This coordination repository is for explaining, managing and coordinating test efforts for the project [Toekomstbestendig maken UZI](https://www.gegevensuitwisselingindezorg.nl/uzi-middelen). 
This documentation also provides step-by-step instructions on how to get up and running setting up the uzi repositories. By following these guidelines, you have a structured way of contributing to the project.  

## Brief explanation
In short, this entire project should make it possible to retrieve UZI attributes without always having to use an UZI-card.
This means the project supports a number of different login methods. If login is successful, it redirects to the disclosure page.
The disclosure page allows you to scan a QR code with a digital wallet App called Yivi. After following the steps in the app,
you can use the app as one of the login methods.
The available login methods are as follows:  
- UZI-card: The UZI card is a certificate contained on a physical (smart)card. You can insert this in a card reader and is secured through a pincode.
- DigiD: Everyone knows about DigiD ofcourse. There is however also a DigiD Mock login option for testing purposes which is good to know about.
- Yivi: Yivi is the digital wallet. If you want to use this for your first time logging in, it offers a setup process in which it will then ask you to confirm your identity with DigiD or your UZI card.
It asks this on your phone, so in practice it is easier to use UZI card/DigiD Mock to log in. Then load the QR code into the Yivi app as described above.

 The available methods are configurable in the 
`nl-rdo-max` repository `max.conf` (more on that in the README there). By default, with a local development set up,
the following methods are enabled: `digid_mock`, `uzipas` and `irma` (irma has since been rebranded to Yivi, still needs to be updated in some places).
That means only the non-mock DigiD login method is disabled.

If you wish to read up on the individual repositories, they are briefly explained at the bottom of this README.

## Setup
**Prerequisites:**  
Before setting up the uzi repositories, ensure that you have the following prerequisites installed on your system:
1. Git: Version control system for cloning the repositories.
2. Python: Programming language used in the uzi repositories (Python 3.8).
3. Pip: Package installer for Python libraries.
4. PHP: Programming language used in the uzi repositories.
5. Docker: Software used to create light weight virtual machines.
6. Homebrew: Open source package management system (Only for MacOS and Linux).
7. Yivi: Mobile app (digital wallet) required to use the Yivi login method. Can be installed from most app stores.  
**IMPORTANT! At the time of writing developer mode needs to be enabled for Yivi. To do this open the app and go to 
"Meer/More" (the three dots in the bottom right). And keep tapping the small text in the footer (App-ID....) until
you get a notification that developer mode is enabled.**

You will also need to generate a (GitHub) personal access token to access private repositories that are part of the project dependencies. You can do that [here](https://github.com/settings/tokens/new).
At least the "repo" scope that says "Full control of private repositories" needs to be enabled. Save your resulting token, it will be asked for in a later step.

**Get up and running:**  
Follow the steps below to get the right repositories needed for the POC:

**Step 1: Clone & set up the Repositories**  
1. Open a terminal or command prompt.
2. Navigate to the directory where you want to clone the repositories. It is recommended to create a sub-folder for this.
3. Clone the coordination repo into the folder:  
   ```
   git clone git@github.com:minvws/nl-rdo-uzi-coordination.git
   ```
4. **(Only for MacOS and Linux)** You might run into a problem running the project due to an [issue](https://github.com/xmlsec/python-xmlsec/issues/254) with certain dependancies update. Please refer to the [recommended workaround](https://github.com/xmlsec/python-xmlsec/issues/254#issuecomment-1726249435) to resolve the problem.

5. Navigate to the coordination repo folder in your terminal and run the `make setup` command.  
   ```
   cd nl-rdo-uzi-coordination
   make setup
   ```
   This command will clone all the required repositories and will do most of the setting up for you.
   During this step it will ask for the token you generated earlier. Paste it in the terminal and press enter
6. **(optional)** If you want to use the UZI card login method you need to add your UZI number to the `mock_register.json` in
the `nl-uzipoc-register-api` repository. If you do not know your UZI number yet, you should be able to get it from
[here](https://acceptatie.zorgcsp.nl/zoeken/UitgegevenUziPassen). Alternatively you can use the 
[VWS pUzi library](https://github.com/minvws/pUzi-python/) to read the data on your card which includes the UZI number. The
Python library refers to this field as `UziNumber`. Note that your UZI number is NOT written on the physical card itself. 
The first entry in the `mock_register.json` is for a card registered to a person. The second one is a card not registered 
to a person. Simply replace the `uzi_id` fields (999991772/900020108) with your UZI number.
7. **(only if you did 6)** When using the UZI card login method you will also need a certificate to verify the UZI card certificate called
`uzi-staging-clientca.pem`. The easiest would be asking a coworker for this file, but alternatively you can follow these steps yourself:
   1. Go to [https://acceptatie.zorgcsp.nl/ca-certificaten](https://acceptatie.zorgcsp.nl/ca-certificaten) and download the needed certificates.
      - Always:
         - TEST Zorg CSP Root CA G3
      - When you need to allow `Zorgverlever` or `Medewerker op naam` passes you need:
         - TEST Zorg CSP Level 2 Persoon CA G3
         - TEST UZI-register Zorgverlener CA G3 (for `Zorgverlever` passes)
         - TEST UZI-register Medewerker op naam CA G3 (for  `Medewerker op naam` passes)
      - When you need to allow `Medewerker niet op naam` passes you need:
         - TEST Zorg CSP Level 2 Services CA G3
         - TEST UZI-register Medewerker niet op naam CA G3
   2. Convert the resulting `.cer` files to `.pem`. For example: `openssl x509 -inform der -in certificate.cer -out certificate.pem`
   3. Paste all the files underneath each other in a single file called `uzi-staging-clientca.pem` and place it in `nl-uzi-login-controller/secrets`
8. **(optional)** If you want to use the DigiD Mock functionality you need to make sure the BSN you want to use is in the
`nl-rdo-max/tests/resources/uzi_data.json`. Read more on this in the [DigiD Mock - UZI testing Data](#digid-mock---uzi-testing-data)
paragraph.

**Step 2: Run the project**    
Running the project is as simple as going into each of the repositories and executing `make run` in a terminal.
1. Start by running the front-end. Open a terminal and navigate to the `nl-uzi-yivi-disclosure-web` repository. Execute `make run` here. 
2. Open a new terminal and navigate to the `nl-uzi-login-controller` repository. Execute `make run` here.
3. Repeat step 2 but for the `nl-uzipoc-register-api` repository.
4. Repeat step 2 again for the `nl-rdo-max` repository.

The project should be up and running now!

## Additional Information
### LOA - Level of Assurance
The Level of Assurance specifies how sure the system is of any identity. The definitions of this are specified by the
EU and you can read more about this [here](https://ec.europa.eu/digital-building-blocks/wikis/display/DIGITAL/eIDAS+Levels+of+Assurance).
Within the UZI stack, there are three possible values (note: these are not links you can access in your browser):  
- low: `http://eidas.europa.eu/LoA/low`
- substantial: `http://eidas.europa.eu/LoA/substantial`
- high: `http://eidas.europa.eu/LoA/high`

To successfully login you will at least need a LOA of substantial, login attempts with a LOA of low will fail.

Furthermore, there are two types:
- `loa_authn`: this specifies how sure the system is that you are who you claim to be during you login attempt. This is
directly tied to which login method you use. For instance, the DigiD app is considered less secure than logging in with
DigiD through your username, password and confirmation text message.
- `loa_uzi`: this specifies the LOA for the user data object or "zorgidentiteit". This tells us how much the system trusts 
how the data was created. For instance, if you load your data into Yivi the creation of your data has a lower loa_uzi 
value then when you apply for a DigiD.   
Although it is good to know loa_uzi exists and is included in some responses, within this project only loa_authn is 
really relevant.

### Revocation  
When generating a digital login 'card' in Yivi, it is also possible to revoke the data it contains. You would do this
when there has been a change in your personal data (maybe your roles, or something else has changed). Revoking the data
will tell Yivi that your digital card contains legitimate data, but that it is outdated. Because this is passed as an
attribute it needs to be checked for its value. There is a config variable in the `nl-uzi-login-controller/app.conf` called 
`irma_revocation`. When this is set to `true` it means that the login controller will check whether a Yivi card contains
revoked data, blocking the login. To revoke Yivi data, you need to talk to the Yivi binary itself. Below is an example on 
how to do that:  
`curl --header "Content-Type: application/json" --request POST --data '{"@context": "https://irma.app/ld/request/revocation/v1","type": "irma-demo.uzipoc-cibg.uzi-2","revocationKey": "uziId-900020118-ura-87654321"}' http://localhost:8088/revocation`
The `revocationKey` tells Yivi which data to revoke, and the host `localhost:8088` is the Yivi binary. At
the moment however, a local setup process for this is not included.

### DigiD Mock - UZI testing Data
When using the DigiD Mock login option, MAX will use the `nl-rdo-max/tests/resources/uzi_data.json` file by default to return mocked UZI data.
The file path can be configured in the (MAX) .conf with the following var:  
`mocked_uzi_data_file_path = tests/resources/uzi_data.json`  
The system retrieves entries from this file by looking for an object with the entered BSN as key. 
On acceptance this file is managed by operations, and changes to this file (tests/resources/uzi_data.json) will not affect
any returned data. 

Entries in this file should adhere to the following scheme:
```Python
class UziAttributes(BaseModel):
    initials: str
    surname_prefix: str
    surname: str
    loa_authn: str
    loa_uzi: str
    uzi_id: str
    relations: List[Relation]
    
class Relation(BaseModel):
    ura: str
    entity_name: str
    roles: List[str]
```
If the requesting (front-end) client is NOT a disclosure client, it will filter any relations not belonging to this specific client using the `ura` field.
A URA is a unique code used to identify healthcare providers in electronic communication regarding healthcare data. In other words, an ID. 
This means that only relevant roles/relations for the specific client are passed through.

**Important!**  
If you want to load a set of data from the DigiD Mock functionality into Yivi, so you can log in with that too: you will also
need to add an entry for this in the `nl-uzipoc-register-api/mock_register.json` (Getting up and running - step 5)! In this case
the key of the newly added json object is your DigiD Mock BSN and your uzi_id can be something different (should be the same as the uzi_id you used in the `uzi_data.json`).

### Issuers
For creating or rather issuing a new Yivi card to log in with, a Yivi issuer is required. The current (demo/pilot/acceptance) ones can be found
[here](https://github.com/privacybydesign/irma-demo-schememanager/tree/master/uzipoc-cibg/Issues). They are managed by Yivi
themselves. Production issuers are managed in a different repository.

Changing or adding a new issuer requires you to fork the linked repository and create a pull request back to the original.
When trying to merge a pull request, the pipeline requires you to sign your modified files. For this you need [irmago](https://github.com/privacybydesign/irmago/releases).
It is recommended to just download the correct binary for your OS from the latest release, so that you can sign your schemas by simply running:
`./irma-darwin-amd64 scheme sign` in your `irma-demo-schememanager` folder (I used this one on MacOS).

# Flow overview
![UZI-inlogmiddelen flows-combination-flow-diagram](https://user-images.githubusercontent.com/12181969/229889972-aba96faf-34ba-4283-8c20-e9fcf558032f.png)

# Certificates
The applications communicate through signed and optional encrypted jwt tokens.
Every application has its own set of keys en needs the certificates of the applications for which it needs to validate the received messages.
Since running `make setup` will set up all required certificates in the correct locations for development, there isn't much to explain here.
If you still want a more detailed overview of all certificates, you can read more on them in the `README - OPS.md`. 

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

# Open Source Strategy

This project, including all required components, is open source and is managed by the Ministry of
Health, Welfare and Sport. The project is open source to allow for transparency and to allow for
contributions from the community.

The various repositories (see [repository-overview.md](documentation/repository-overview.md)) are
opensourced using a private - public model. This means that the repositories are private by
default. Whenever a release is made, the main branch of the private repository will be synced with
the public repository. This way, the public repository will always be up to date with the latest
releases.

This does not mean that the public repository will represent the active version on the production
environment. It will be more likely that the public repository will be ahead of the production
environment.

## Issues

If there is an issue with an open source repository an issue can be created in the public
repository. This issue will be reviewed by the development team and will be prioritized. If the
issue is accepted, it will be added to the backlog and will be added to the planning.

## Contributing

If you want to contribute to the project, you can create a pull request in the public repository.
The pull request will be reviewed by the development team and will be pulled in or copied to the 
private repository. The development team will try to preserve the original author of the pull
request in the commit history. But this is not always possible.
