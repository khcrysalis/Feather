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

> [!WARNING]
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

> Was verwendet Feather für seinen Server?

Es verwendet das [localhost.direct](https://github.com/Upinel/localhost.direct)-Zertifikat und [Vapor](https://github.com/vapor/vapor), um selbst einen HTTPS-Server auf deinem Gerät zu hosten - Alles, was die itms-Dienste wirklich benötigen, ist ein gültiges Zertifikat und ein gültiger HTTPS-Server. Dadurch kann iOS die Anfrage annehmen und die Anwendung installieren.

> Warum hängt Feather eine zufällige Zeichenfolge an die Bundle-ID an?

Neue ADP-Mitgliedschaften (Apple Developer Program), die nach dem 6. Juni 2021 erstellt wurden, erfordern, dass Entwicklungs- und Ad-hoc-signierte Apps für iOS, iPadOS und tvOS beim ersten Start der App mit einem PPQ-Dienst (Provisioning Profile Query Check) überprüft werden. Zur Überprüfung muss das Gerät mit dem Internet verbunden sein.

PPQCheck sucht im App Store nach einer ähnlichen Bundle-ID. Wenn diese ID mit der von dir gestarteten App übereinstimmt und zufällig mit einem Nicht-Appstore-Zertifikat signiert ist, wird deine Apple-ID möglicherweise markiert und sogar für die Nutzung des Programms gesperrt für lange Zeit.

Aus diesem Grund stellen wir eine Zufallszeichenfolge vor jeder Kennung aus Sicherheitsgründen voran. Du kannst sie jedoch auf der Einstellungsseite von Feathers *wirklich* deaktivieren, wenn du unbedingt willst.

*HINWEIS: Wenn du Anwendungsdaten auch bei Neuinstallationen behalten möchtest, stelle sicher, dass Sie über dieselbe BundleID verfügt.*

## Aufbau

```sh
git clone https://github.com/khcrysalis/feather # Clone
cd feather
make package SCHEME="'feather (Release)'" # Build
```
> Nutze `SCHEME="'feather (Debug)'"` für Debug-Build

## Danksagungen

- [localhost.direct](https://github.com/Upinel/localhost.direct) - localhost mit öffentlichem, von einer Zertifizierungsstelle signiertem SSL-Zertifikat
- [Vapor](https://github.com/vapor/vapor) - Ein serverseitiges Swift HTTP-Webframework.
- [Zsign](https://github.com/zhlynn/zsign) - Ermöglicht das Signieren auf dem Gerät, neu implementiert für die Arbeit auf anderen Plattformen wie iOS.
- [Nuke](https://github.com/kean/Nuke) - Bild-Zwischenspeicher.
- [Asspp](https://github.com/Lakr233/Asspp) - Etwas Code zum Einrichten des http-Servers.

<!-- - [plistserver](https://github.com/QuickSign-Team/plistserver) - Gehostet auf https://api.palera.in
> HINWEIS: Die Originallizenz für plistserver ist [GPL](https://github.com/nekohaxx/plistserver/commit/b207a76a9071a695d8b498db029db5d63a954e53), eine Änderung der Lizenz ist daher NICHT sinnvoll, da sie technisch gesehen unwiderruflich ist. Aus technischen Gründen ist es uns gestattet, es auf unserem eigenen Server zur Verwendung in Feather zu hosten.  -->

## Star History

<a href="https://star-history.com/#khcrysalis/feather&Date">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=khcrysalis/feather&type=Date&theme=dark" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=khcrysalis/feather&type=Date" />
   <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=khcrysalis/feather&type=Date" />
 </picture>
</a>

## Mitwirkung

Sie sind willkommen! :)

## Geschichte

Es gab ein Tool namens ESign (Easy Sign), mit dem Sie Anwendungen nahtlos auf das Gerät laden konnten. Es wurde jedoch festgestellt, dass es Analysen leider an einen anderen Ort sendet. Es gab Dinge, die angeblich die Analyse entfernt haben, aber es ist schwer zu entschlüsseln, ob das Problem dadurch tatsächlich behoben wurde.

Deshalb habe ich beschlossen, eine Alternative mit ähnlichen Funktionen zu entwickeln, damit ich dieses Tool nicht zusammen mit anderen verwenden muss. Es wurde viel Forschung betrieben, um dies zum Laufen zu bringen und vor ein paar Monaten hat es zum ersten Mal funktioniert! Natürlich können Sie ohne die Hilfe von Dhinakg bei der Entdeckung tatsächlich einen lokalen Server verwenden, um eine App auf deinem Gerät bereitzustellen!

Und jetzt sind wir da! Hoffentlich stellt dies die meisten Leute zufrieden, die mit ihrem Entwicklerkonto oder allgemein einen Sideload durchführen möchten!
