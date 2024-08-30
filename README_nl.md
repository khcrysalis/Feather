<div align="center">
    <img width="100" height="100" src="Images/512@2x.png" style="margin-right: -15px;">
</div>
<h1>Feather</h1>
<p>
    Feather is een gratis iOS-applicatiebeheerder/installatieprogramma voor op het apparaat, gebouwd met UIKit voor kwaliteit.
</p>

#### README In Andere Talen
- [English🇬🇧](https://github.com/khcrysalis/Feather/blob/main/README.md)
- [Русский🇷🇺](https://github.com/khcrysalis/Feather/blob/main/README_ru.md)



## Functies
- **Altstore repo-ondersteuning**. *Ondersteuning voor Legacy en 2.0 repo-structuren*

- **Importeer uw eigen `.ipa`'s**.
- **Voeg tweaks bij het ondertekenen van apps**.
- **Installeer applicaties rechtstreeks en naadloos draadloos op uw apparaat**.
- **Maakt het mogelijk om meerdere certificaten te importeren voor eenvoudig schakelen**.
- **Configureerbare ondertekeningsopties**. *(naam, bundel-id, versie, andere plist-opties)*
- **Bedoeld voor gebruik met Apple-accounts die deel uitmaken van `ADP` (Apple Developer Program)**. *Maar andere certificaten kunnen ook werken!*
- **Eenvoudig opnieuw ondertekenen**! *Als u een ander certificaat wilt gebruiken voor een app, kunt u het certificaat opnieuw ondertekenen en dezelfde app opnieuw installeren!*
- **Geen tracking, analyse of iets dergelijks**. *Uw gegevens zoals UDID en certificaten verlaten het apparaat nooit.*

> [!IMPORTANT]
> **Tweak-ondersteuning is in bèta**, zorg ervoor dat je tweaks werken op het [Ellekit](https://theapplewiki.com/wiki/ElleKit) hooking-platform en gebouwd met de nieuwste versie van theos.
>
> **Sommige tweaks, niet alle, zouden moeten werken met Feather.** Verwacht echter niet dat tweaks direct werken. Omdat we geen enkele dylib load-opdracht zullen wijzigen die niet CydiaSubstrate is.

## Routekaart

[Bekijk hier de routekaart!](https://github.com/khcrysalis/Feather/issues/26)

## Screenshots

| <p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="Images/Repos.png"><source media="(prefers-color-scheme: light)" srcset="Images/Repos_L.png"><img alt="Pointercrate-pocket." src="Images/Repos_L.png" width="200"></picture></p> | <p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="Images/Store.png"><source media="(prefers-color-scheme: light)" srcset="Images/Store_L.png"><img alt="Pointercrate-pocket." src="Images/Store_L.png" width="200"></picture></p> | <p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="Images/Library.png"><source media="(prefers-color-scheme: light)" srcset="Images/Library_L.png"><img alt="Pointercrate-pocket." src="Images/Library_L.png" width="200"></picture></p> | <p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="Images/Sign.png"><source media="(prefers-color-scheme: light)" srcset="Images/Sign_L.png"><img alt="Pointercrate-pocket." src="Images/Sign_L.png" width="200"></picture></p> |
|:--:|:--:|:--:|:--:|
| **Bronnen** | **Winkel** | **Bibliotheek** | **Ondertekening** |
> Tip: Ga naar de lichtmodus om schermafbeeldingen van de lichtmodus te bekijken!

## Hoe het Werkt

Met Feather kunt u een `.p12` en een `.mobileprovision` paar importeren om de applicatie mee te ondertekenen (u hebt een correct wachtwoord voor de p12 nodig voordat u importeert). [Zsign](https://github.com/zhlynn/zsign) wordt gebruikt voor het ondertekeningsaspect, feather voedt het met de certificaten die u hebt geselecteerd in het tabblad Certificaten en ondertekent de app op uw apparaat - nadat het is voltooid, wordt het nu toegevoegd aan uw tabblad Ondertekende applicaties. Wanneer geselecteerd, duurt het even voordat het wordt gecomprimeerd en wordt u gevraagd het te installeren.

## FAQ

> Wat gebruikt Feather voor zijn server?

Het gebruikt het [localhost.direct](https://github.com/Upinel/localhost.direct) certificaat en [Vapor](https://github.com/vapor/vapor) om zelf een HTTPS-server op uw apparaat te hosten - alles wat itms-services echt nodig hebben is een geldig certificaat en een geldige HTTPS-server. Waarmee iOS het verzoek kan accepteren en de applicatie kan installeren.

> Waarom voegt Feather een willekeurige tekenreeks toe aan de bundel-ID?

Nieuwe ADP-lidmaatschappen (Apple Developer Program) die na 6 juni 2021 zijn gemaakt, vereisen dat ontwikkel- en ad-hoc ondertekende apps voor iOS, iPadOS en tvOS worden gecontroleerd met een PPQ-service (Provisioning Profile Query Check) wanneer de app voor het eerst wordt gestart. Het apparaat moet verbinding hebben met internet om dit te verifiëren.

PPQCheck controleert op een vergelijkbare bundel-ID in de App Store. Als deze ID overeenkomt met de app die u start en is ondertekend met een certificaat dat niet in de App Store staat, kan uw Apple ID worden gemarkeerd en zelfs worden geblokkeerd voor gebruik van het programma.

Daarom voegen we de willekeurige string toe vóór elke ID. Dit is een veiligheidsmaatregel. U kunt deze echter uitschakelen als u dat *echt* wilt op de instellingenpagina van Feathers.

*NOTE: ALS U UW APPLICATIEGEGEVENS WILT BEHOUDEN DOOR HERINSTALLATIES, ZORG DAN DAT U DEZELFDE BUNDEL-ID HEBT.*

## Bouwen

```sh
git clone https://github.com/khcrysalis/feather # Kloon
cd feather
make package SCHEME="'feather (Release)'" # Buow
```
> Gebruik `SCHEME="'feather (Debug)'"` voor debug-built

## Dankbetuigingen

- [localhost.direct](https://github.com/Upinel/localhost.direct) - localhost met openbaar CA-ondertekend SSL-certificaat
- [Vapor](https://github.com/vapor/vapor) - Een server-side Swift HTTP-webframework.
- [Zsign](https://github.com/zhlynn/zsign) - Maakt het mogelijk om op het apparaat te ondertekenen, opnieuw geïmplementeerd om te werken op andere platforms zoals iOS.
- [Nuke](https://github.com/kean/Nuke) - Imagecaching.
- [Asspp](https://github.com/Lakr233/Asspp) - Een code voor het instellen van de http-server.

<!-- - [plistserver](https://github.com/QuickSign-Team/plistserver) - Hosted on https://api.palera.in
> NOTE: The original license to plistserver is [GPL](https://github.com/nekohaxx/plistserver/commit/b207a76a9071a695d8b498db029db5d63a954e53), so changing the license is NOT viable as technically it's irrevocable. We are allowed to host it on our own server for use in Feather by technicality.  -->

## Ster Geschiedenis

<a href="https://star-history.com/#khcrysalis/feather&Date">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=khcrysalis/feather&type=Date&theme=dark" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=khcrysalis/feather&type=Date" />
   <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=khcrysalis/feather&type=Date" />
 </picture>
</a>

## Bijdragen

Ze zijn welkom! :)

## Geschiedenis

Er was een tool genaamd ESign (Easy Sign) waarmee je applicaties naadloos op het apparaat kon sideloaden, maar het werd helaas ontdekt dat het analytics naar een andere locatie stuurde. Er waren dingen die zogenaamd de analytics verwijderden, maar het is moeilijk te achterhalen of het probleem daadwerkelijk werd opgelost.

Dus besloot ik een alternatief te maken met vergelijkbare functies, zodat ik die tool niet meer hoef te gebruiken, samen met mij en anderen. Er is veel onderzoek gedaan om dit werkend te krijgen, en het werkte een paar maanden geleden voor het eerst! Natuurlijk zonder de hulp van Dhinakg bij het ontdekken dat je daadwerkelijk een lokale server kunt gebruiken om een ​​app op je apparaat te implementeren!

En nu zijn we hier! Hopelijk voldoet dit aan de meeste mensen die willen sideloaden met hun ontwikkelaarsaccount of in het algemeen!