<div align="center">
    <img width="100" height="100" src="Images/512@2x.png" style="margin-right: -15px;">
</div>
<h1>Feather</h1>
<p>
    Feather is a free on-device iOS application manager/installer built with UIKit for quality.
</p>





## Features
- Altstore repo support, supporting Legacy and 2.0 repo structures
- Import your own `.ipa`'s
- Inject tweaks when signing apps
- Install applications straight to your device seemlessly over the air
- Allows multiple certificate imports for easy switching
- Configurable signing options (name, bundleid, version, other plist options)
- Meant to be used with Apple Accounts that are apart of `ADP` (Apple Developer Program), however other certificates can also work!
- No tracking, analytics, or any of the sort. Your information such as udid and certificates will never leave the device.

## GET IT NOW

<p align="center">
<a href="https://github.com/khcrysalis/feather/releases">>>>> Get Feather From Releases <<<<</a>
</p>

## How it Works

Feather allows you to import a `.p12` and a `.mobileprovision` pair to sign the application with (you will need a correct password to the p12 before importing). [Zsign]() is used for the signing aspect, feather feeds it the certificates you have selected in its certificates tab and will sign the app on your device - after its finished it will now be added to your signed applications tab. When selected, it will take awhile as its compressing and will prompt you to install it.

> What does feather use for its server?

It uses the [localhost.direct](https://github.com/Upinel/localhost.direct) certificate and [Http.swift](https://swiftpackageindex.com/BiAtoms/Http.swift) to self host an HTTPS server on your device - all itms services really needs is a valid certificate and a valid HTTPS server. Which allows iOS to accept the request and install the application.

> Why Does Feather Append a Random String on the Identifier?

New ADP (Apple Developer Program) memberships created after June 6, 2021, require development and ad-hoc signed apps for iOS, iPadOS, and tvOS to check with a PPQ (Provisioning Profile Query Check) service when the app is first launched. The device must be connected to the internet to verify.

PPQCheck checks for a similar bundle identifier on the App Store, if said identifier matches the app you're launching and is happened to be signed with a non-appstore certificate, your Apple ID may be flagged and even banned from using the program for any longer.

This is why we prepend the random string before each identifier, its done as a safety meassure - however you can disable it if you *really* want to in Feathers settings page.

## Building

```sh
git clone https://github.com/khcrysalis/feather # Clone
cd feather
make package SCHEME="'feather (Release)'" # Build
```
> Use `SCHEME="'feather (Debug)'"` for debug build

## Acknowledgements

- [localhost.direct](https://github.com/Upinel/localhost.direct) - localhost with public CA signed SSL certificate
- [Http.swift](https://github.com/BiAtoms/Http.swift) - A tiny HTTP server engine written in swift.
- [Zsign](https://github.com/zhlynn/zsign) - Allowing to sign on-device, reimplimented to work on other platforms such as iOS.
- [Nuke](https://github.com/kean/Nuke) - Load images from different sources and display them in your app using simple and flexible APIs. Take advantage of the powerful image processing capabilities and a robust caching system.
- [Markdownosaur](https://github.com/christianselig/Markdownosaur) - Allows markdown parsing for changelogs

- [plistserver](https://github.com/QuickSign-Team/plistserver) - Hosted on https://api.palera.in
> NOTE: The original license to plistserver is [GPL](https://github.com/nekohaxx/plistserver/commit/b207a76a9071a695d8b498db029db5d63a954e53), so changing the license is NOT viable as technically it's irrevocable. We are allowed to host it on our own server for use in Feather by technicality. 

## Contributions

They are welcome! :)
