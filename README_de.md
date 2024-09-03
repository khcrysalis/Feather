<div align="center">
    <img width="100" height="100" src="Images/512@2x.png" style="margin-right: -15px;">
</div>
<h1>Feather</h1>
<p>
    Feather ist ein kostenloser iOS-Anwendungsmanager/Installer auf dem Gerät, der mit UIKit für Qualität entwickelt wurde.
</p>

#### README in anderen Sprachen
- [English🇬🇧](https://github.com/khcrysalis/Feather/blob/main/README.md)
- [Русский🇷🇺](https://github.com/khcrysalis/Feather/blob/main/README_ru.md)




## Funktionen
- **Altstore-Quellen-Unterstützung**. *Unterstützung von Legacy- und 2.0-Quellen-Strukturen*

- **Importiere deine eigenen `.ipa`'s**.
- **Tweaks beim Signieren von Apps injizieren**.
- **Installiere Anwendungen direkt auf Ihrem Gerät "over-the-air"**.
- **Ermöglicht mehrere Zertifikatsimporte für einen einfachen Wechsel**.
- **Konfigurierbare Signaturoptionen**. *(Name, BundleID, Version, andere Plist-Optionen)*
- **Soll mit Apple-Accounts verwendet werden, die Teil von `ADP` (Apple Developer Program) sind**. *Aber auch andere Zertifikate können funktionieren!*
- **Einfache Wieder-Signierung**! *Wenn du ein anderes Zertifikat hast, das du für eine App verwenden möchtest, kannst du dieselbe App neu installieren!*
- **Kein Tracking, keine Analysen oder der Art**. *Ihre Informationen wie UDID und Zertifikate werden das Gerät nie verlassen.*

> [!WICHTIG]
> **Tweak-Unterstützung befindet sich in der Beta-Phase**, stelle sicher, dass deine Optimierungen auf der [Ellekit](https://theapplewiki.com/wiki/ElleKit) Hooking-Plattform funktioniert und mit der neuesten Version von Theos gebaut wurde.
> 
> **Einige Optimierungen, nicht alle, sollten mit Feather funktionieren.** Erwarte jedoch nicht, dass Optimierungen sofort funktionieren. Da wir keinen dylib-Load-Befehl ändern werden, der nicht CydiaSubstrate ist.

## Fahrplan

[Schau den Fahrplan hier an](https://github.com/khcrysalis/Feather/issues/26)

## Bildschirmfotos

| <p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="Images/Repos.png"><source media="(prefers-color-scheme: light)" srcset="Images/Repos_L.png"><img alt="Pointercrate-pocket." src="Images/Repos_L.png" width="200"></picture></p> | <p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="Images/Store.png"><source media="(prefers-color-scheme: light)" srcset="Images/Store_L.png"><img alt="Pointercrate-pocket." src="Images/Store_L.png" width="200"></picture></p> | <p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="Images/Library.png"><source media="(prefers-color-scheme: light)" srcset="Images/Library_L.png"><img alt="Pointercrate-pocket." src="Images/Library_L.png" width="200"></picture></p> | <p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="Images/Sign.png"><source media="(prefers-color-scheme: light)" srcset="Images/Sign_L.png"><img alt="Pointercrate-pocket." src="Images/Sign_L.png" width="200"></picture></p> |
|:--:|:--:|:--:|:--:|
| **Quellen** | **Store** | **Mediathek** | **Signierung** |
> Tipp: Gehe in den Hell-Modus, um Bildschirmfotos im Hell-Modus zu sehen!

## Wie es funktioniert

Mit Feather können Sie ein `.p12`- und ein `.mobileprovision`-Paar importieren, um die Anwendung zu signieren (Du benötigst vor dem Import ein korrektes Passwort für p12). [Zsign](https://github.com/zhlynn/zsign) wird für den Signaturaspekt verwendet, Feather fügt die Zertifikate ein, die in der Registerkarte "Zertifikate" ausgewählt wurden und signiert die App auf Ihrem Gerät - nachdem sie abgeschlossen ist, wird sie nun zu deiner Registerkarte "Signierte Anwendungen" hinzugefügt. Wenn es ausgewählt ist, dauert es eine Weile, da es komprimiert wird, und du wirst aufgefordert, es zu installieren.

## FAQ

> What does feather use for its server?

It uses the [localhost.direct](https://github.com/Upinel/localhost.direct) certificate and [Vapor](https://github.com/vapor/vapor) to self host an HTTPS server on your device - all itms services really needs is a valid certificate and a valid HTTPS server. Which allows iOS to accept the request and install the application.

> Why does Feather append a random string on the bundle ID?

New ADP (Apple Developer Program) memberships created after June 6, 2021, require development and ad-hoc signed apps for iOS, iPadOS, and tvOS to check with a PPQ (Provisioning Profile Query Check) service when the app is first launched. The device must be connected to the internet to verify.

PPQCheck checks for a similar bundle identifier on the App Store, if said identifier matches the app you're launching and is happened to be signed with a non-appstore certificate, your Apple ID may be flagged and even banned from using the program for any longer.

This is why we prepend the random string before each identifier, its done as a safety meassure - however you can disable it if you *really* want to in Feathers settings page.

*NOTE: IF YOU WANT TO KEEP APPLICATION DATA THROUGH REINSTALLS, MAKE SURE YOU HAVE THE SAME BUNDLEID.*

## Building

```sh
git clone https://github.com/khcrysalis/feather # Clone
cd feather
make package SCHEME="'feather (Release)'" # Build
```
> Use `SCHEME="'feather (Debug)'"` for debug build

## Acknowledgements

- [localhost.direct](https://github.com/Upinel/localhost.direct) - localhost with public CA signed SSL certificate
- [Vapor](https://github.com/vapor/vapor) - A server-side Swift HTTP web framework.
- [Zsign](https://github.com/zhlynn/zsign) - Allowing to sign on-device, reimplimented to work on other platforms such as iOS.
- [Nuke](https://github.com/kean/Nuke) - Image caching.
- [Asspp](https://github.com/Lakr233/Asspp) - Some code for setting up the http server.

<!-- - [plistserver](https://github.com/QuickSign-Team/plistserver) - Hosted on https://api.palera.in
> NOTE: The original license to plistserver is [GPL](https://github.com/nekohaxx/plistserver/commit/b207a76a9071a695d8b498db029db5d63a954e53), so changing the license is NOT viable as technically it's irrevocable. We are allowed to host it on our own server for use in Feather by technicality.  -->

## Star History

<a href="https://star-history.com/#khcrysalis/feather&Date">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=khcrysalis/feather&type=Date&theme=dark" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=khcrysalis/feather&type=Date" />
   <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=khcrysalis/feather&type=Date" />
 </picture>
</a>

## Contributions

- Deutsche Lokalisierung und README_DE von t0mi (https://x.com/t0mi292)

## Geschichte

Es gab ein Tool namens ESign (Easy Sign), mit dem Sie Anwendungen nahtlos auf das Gerät laden konnten. Es wurde jedoch festgestellt, dass es Analysen leider an einen anderen Ort sendet. Es gab Dinge, die angeblich die Analyse entfernt haben, aber es ist schwer zu entschlüsseln, ob das Problem dadurch tatsächlich behoben wurde.

Deshalb habe ich beschlossen, eine Alternative mit ähnlichen Funktionen zu entwickeln, damit ich dieses Tool nicht zusammen mit anderen verwenden muss. Es wurde viel Forschung betrieben, um dies zum Laufen zu bringen und vor ein paar Monaten hat es zum ersten Mal funktioniert! Natürlich können Sie ohne die Hilfe von Dhinakg bei der Entdeckung tatsächlich einen lokalen Server verwenden, um eine App auf deinem Gerät bereitzustellen!

Und jetzt sind wir da! Hoffentlich stellt dies die meisten Leute zufrieden, die mit ihrem Entwicklerkonto oder allgemein einen Sideload durchführen möchten!
