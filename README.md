<div align="center">
    <img width="100" height="100" src="Images/512@2x.png" style="margin-right: -15px;">
</div>
<h1>Feather</h1>
<p>
    Feather is a free on-device iOS application manager/installer built with UIKit for quality.
</p>

#### README In Other Languages

- [Deutsch🇩🇪](https://github.com/khcrysalis/Feather/blob/main/README_de.md)
- [Polski🇵🇱](https://github.com/khcrysalis/Feather/blob/main/README_pl.md)
- [Русский🇷🇺](https://github.com/khcrysalis/Feather/blob/main/README_ru.md)

## Features

- **Altstore repo support**. *Supporting Legacy and 2.0 repo structures*
- **Import your own `.ipa`'s**.
- **Inject tweaks when signing apps**.
- **Install applications straight to your device seamlessly over the air**.
- **Allows multiple certificate imports for easy switching**.
- **Configurable signing options**. *(name, bundleid, version, other plist options)*
- **Meant to be used with Apple Accounts that are apart of `ADP` (Apple Developer Program)**. *however other certificates can also work!*
- **Easy resigning**! *If you have another certificate you would like to use on an app you may resign and reinstall that same app!*
- **No tracking, analytics, or any of the sort**. *Your information such as UDID and certificates will never leave the device.*

> [!IMPORTANT]
> **Tweak support is in beta**, make sure your tweaks work on the [Ellekit](https://theapplewiki.com/wiki/ElleKit) hooking platform, and built with the latest version of theos.
> 
> **Some tweaks, not all, should work with Feather.** However, don't expect tweaks to work out of the box. As we will not change any dylib load command that isn't CydiaSubstrate.

## Links
 → [Visit the Feather Wiki here!](https://github.com/khcrysalis/Feather/wiki)\
 → [Visit the roadmap here!](https://github.com/khcrysalis/Feather/issues/26)

## Screenshots

| <p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="Images/Repos.png"><source media="(prefers-color-scheme: light)" srcset="Images/Repos_L.png"><img alt="Pointercrate-pocket." src="Images/Repos_L.png" width="200"></picture></p> | <p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="Images/Store.png"><source media="(prefers-color-scheme: light)" srcset="Images/Store_L.png"><img alt="Pointercrate-pocket." src="Images/Store_L.png" width="200"></picture></p> | <p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="Images/Library.png"><source media="(prefers-color-scheme: light)" srcset="Images/Library_L.png"><img alt="Pointercrate-pocket." src="Images/Library_L.png" width="200"></picture></p> | <p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="Images/Sign.png"><source media="(prefers-color-scheme: light)" srcset="Images/Sign_L.png"><img alt="Pointercrate-pocket." src="Images/Sign_L.png" width="200"></picture></p> |
|:--:|:--:|:--:|:--:|
| **Sources** | **Store** | **Library** | **Signing** |
> [!Tip]
> Go into lightmode to see lightmode screenshots!

## How it Works

Feather allows you to import a `.p12` and a `.mobileprovision` pair to sign the application with (you will need a correct password to the p12 before importing). [Zsign](https://github.com/zhlynn/zsign) is used for the signing aspect, feather feeds it the certificates you have selected in its certificates tab and will sign the app on your device - after its finished it will now be added to your signed applications tab. When selected, it will take awhile as its compressing and will prompt you to install it.

## FAQ

> What does Feather use for its server?

It uses the [localhost.direct](https://github.com/Upinel/localhost.direct) certificate and [Vapor](https://github.com/vapor/vapor) to self host an HTTPS server on your device - all itms services really needs is a valid certificate and a valid HTTPS server. Which allows iOS to accept the request and install the application.

> Does Feather bundle its own certificate for the server

Yes, to be able to install applications on device the server needs to be HTTPS. Which, we use a localhost.direct certificate for when turning on the server while attempting to install.

We have an option to download a new certificate to make this server be able to run in the far future but no guarentees. It entirely depends on the owners of localhost.direct to be able to provide a certificate for use. If it does expire and theres a new one available, hopefully we'll be there to update the files in the background so Feather is able to retrieve those.

> Why does Feather append a random string on the bundle ID?

New ADP (Apple Developer Program) memberships created after June 6, 2021, require development and ad-hoc signed apps for iOS, iPadOS, and tvOS to check with a PPQ (Provisioning Profile Query Check) service when the app is first launched. The device must be connected to the internet to verify.

PPQCheck checks for a similar bundle identifier on the App Store, if said identifier matches the app you're launching and is happened to be signed with a non-appstore certificate, your Apple ID may be flagged and even banned from using the program for any longer.

This is why we prepend the random string before each identifier, its done as a safety meassure - however you can disable it if you *really* want to in Feathers settings page.

*NOTE: IF YOU WANT TO KEEP APPLICATION DATA THROUGH REINSTALLS, MAKE SURE YOU HAVE THE SAME BUNDLEID.*

> What is remove dylib inside of options

There's a very specific reason its there, for those wanting to remove pre-existing injected dylibs inside but it really serves no other practical use other than that. Don't use this if you have no idea what you're doing.

> What about free developer accounts?

Sadly Feather is unlikely to ever support those as there are plenty of alternatives that exist! Here's a few: [Altstore](https://altstore.io), [Sideloadly](https://sideloadly.io/)

## Building

```sh
git clone https://github.com/khcrysalis/feather # Clone
cd feather
make package SCHEME="'feather (Release)'" # Build
```
> [!Tip]
> Use `SCHEME="'feather (Debug)'"` for debug build

## Sponsors

| Thanks to all my [sponsors](https://github.com/sponsors/khcrysalis)!! |
|:-:|
| <img src="https://raw.githubusercontent.com/khcrysalis/github-sponsor-graph/main/graph.png"> |
| _**"samara is cute" - Vendicated**_ |

## Star History

<a href="https://star-history.com/#khcrysalis/feather&Date">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=khcrysalis/feather&type=Date&theme=dark" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=khcrysalis/feather&type=Date" />
   <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=khcrysalis/feather&type=Date" />
 </picture>
</a>

## Acknowledgements

- [localhost.direct](https://github.com/Upinel/localhost.direct) - localhost with public CA signed SSL certificate
- [Vapor](https://github.com/vapor/vapor) - A server-side Swift HTTP web framework.
- [Zsign](https://github.com/zhlynn/zsign) - Allowing to sign on-device, reimplimented to work on other platforms such as iOS.
- [Nuke](https://github.com/kean/Nuke) - Image caching.
- [Asspp](https://github.com/Lakr233/Asspp) - Some code for setting up the http server.

<!-- - [plistserver](https://github.com/QuickSign-Team/plistserver) - Hosted on https://api.palera.in
> NOTE: The original license to plistserver is [GPL](https://github.com/nekohaxx/plistserver/commit/b207a76a9071a695d8b498db029db5d63a954e53), so changing the license is NOT viable as technically it's irrevocable. We are allowed to host it on our own server for use in Feather by technicality.  -->

## Contributions

They are welcome! :)

