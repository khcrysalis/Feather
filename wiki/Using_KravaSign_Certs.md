This page is about how to import KravaSign certificates

## Gathering Files

### Obtaining the `.p12` & `.mobileprovision`

1. Purchase KravaSign at [kravasign.com](https://kravasign.com),
    * Wait the time (usually 72 hours)
    * Join the discord and make a ticket with your receipt/order number
2. Once the wait time is up, you will recieve a download link to a zip file containing three files: 
    * `.p12` (certificate)
    * `.mobileprovision` (provisioning profile)
    * Folder titled with the certificate password

#
### Obtaining the Feather `.ipa`

1. Download the latest Feather ipa from <https://github.com/khcrysalis/Feather/releases>

## Installation Guide
1. Go to [sign.kravasign.com](https://sign.kravasign.com)
    * Upload all the neccessary files
        * `.p12`, `.mobileprovision`, `.ipa`, and type in the certificate password
    * Press `sign`, and it will proceed to install.

## Usage 

This will guide you on how you will import your certificates to Feather

1. Make sure Feather is installed and on your homescreen
2. Open Feather and go to the settings tab in the bottom left corner, scroll down to signing and add your files
    * Password for KravaSign certificate is the same one you used to sign Feather initially

Congratulations, you can now sign and install any ipa with Feather
