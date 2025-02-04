# YubiKey alternatieven
Voor geautomatiseerde certificaat uitgifte zoals gedaan in [PoC met de YubiKey](./yubikey-poc.md) is het nodig om zeker te weten dat een private key ook echt private is aangemaakt.

Dit kan met zogeheten "remote key attestation". Een huidige lijst van apparaten die hiervoor de mogelijkheid bieden staat op https://pkic.org/remote-key-attestation/.

# Praktische alternatieven nu zijn dus:
Praktische alternatieven zijn nu:
* TPM
  Dit is een module die in de laptop, desktop of server zit. Windows 11 vereist dit, de meeste moderne computers hebben dit.
  Dit is computer gebonden.
  
* HSM's en cloud-HSM's op de lijst
  Deze staan normaal gesproken in een datacentrum / serverrack.
  Hierbij kan een identiteit dus op een server worden opgeslagen en zal met andere regels uitgeschreven moeten zijn waarom en hoe hier een sleutel aangemaakt wordt voor een gebruiker en het gebruik beperkt is tot deze ene persoon.
  
* Yubico en smartcards
  Dit zijn pasjes, NFC of USB sticks die de gebruiker zelf bij zich kan dragen - zoals de UZI-pas nu - Waarop de private key aangemaakt kan worden.
  Deze techniek werkt op basis van de [PIV standaard](https://csrc.nist.gov/projects/piv/piv-standards-and-supporting-documentation)

  Tot en met juli 2024 was de PIV standaard voor RSA beperkt tot en met 2048 bits lengte. Wat niet overeen komt met de NCSC richtlijn en de [Zorg-CSP CPS](https://www.zorgcsp.nl/certification-practice-statement-cps).
  Hierin wordt 4096 bits vereist.

  Aangezien hardware tokens normaal gesproken geen firmware updates toestaan - vanuit security overwegingen - is het meestal alleen mogelijk om devices die daarna ontworpen/uitgeleverd zijn te gebruiken in compliance met de hierboven genoemde regelgeving.

# Conclusie
* Applicaties op telefoons en tablets kunnen gebruik maken van apple en android remote key attestation
* Applicaties op computers kunnen gebruik maken van TPM of tokens en smartcards
* Applicaties op servers kunnen gebruik maken van (cloud)HSM's
