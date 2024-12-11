## FAQ

Q: How does feather work?

A: Feather allows you to import a `.p12` and a `.mobileprovision` pair to sign the application with (you will need a correct password to the p12 before importing). [Zsign](https://github.com/zhlynn/zsign) is used for the signing aspect, feather feeds it the certificates you have selected in its certificates tab and will sign the app on your device - after its finished it will now be added to your signed applications tab. When selected, it will take awhile as its compressing and will prompt you to install it.

#

**Q: What does Feather use for its server?**

A: It uses the [localhost.direct](https://github.com/Upinel/localhost.direct) certificate and [Vapor](https://github.com/vapor/vapor) to self host a HTTPS server on your device - all itms services really needs is a valid certificate and a valid HTTPS server. Which allows iOS to accept the request and install the application.

#

**Q: Does Feather bundle its own certificate for the server?**

A: Yes, to be able to install applications on device the server needs to be HTTPS. Which, we use a localhost.direct certificate for when turning on the server while attempting to install.

We have an option to download a new certificate to make this server be able to run in the far future but no guarantees. It entirely depends on the owners of localhost.direct to be able to provide a certificate for use. If it does expire and theres a new one available, hopefully we'll be there to update the files in the background so Feather is able to retrieve those.

#

**Q: Notifications aren't working**

A: This is because of a default setting applied when using Feather, read below.

#

**Q: Why does Feather append a random string on the bundle ID?**

A: New ADP (Apple Developer Program) memberships created after June 6, 2021, require development and ad-hoc signed apps for iOS, iPadOS, and tvOS to check with a PPQ (Provisioning Profile Query Check) service when the app is first launched. The device must be connected to the internet to verify.

PPQCheck checks for a similar bundle identifier on the App Store, if said identifier matches the app you're launching and is happened to be signed with a non-appstore certificate, your Apple ID may be flagged and even banned from using the program for any longer.

This is why we prepend the random string before each identifier, its done as a safety meassure - however you can disable it if you *really* want to in Feathers settings page.

#

**Q: What is remove dylib inside of options?**

A: There's a very specific reason its there, for those wanting to remove pre-existing injected dylibs inside but it really serves no other practical use other than that. Don't use this if you have no idea what you're doing.

#

**Q: What about free developer accounts?**

A: Sadly Feather is unlikely to ever support those as there are plenty of alternatives that exist! Here's a few: [Altstore](https://altstore.io), [Sideloadly](https://sideloadly.io/)

#