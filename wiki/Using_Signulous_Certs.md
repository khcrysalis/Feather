This page is about how to import Signulous/UDID registrations certificates

## Gathering Files

### Obtaining the `.p12` & `.mobileprovision`

1. Purchase signulous at [signulous.com](https://signulous.com)
    * Wait the time period (usually 72 hrs)
2. Once the wait time is up, go to [udidregistrations.com](https://udidregistrations.com), go to check order, put in your udid)
    * Use [udid.tech](https://udid.tech) to see what your UDID is
3. Press `explicit and ad hoc provisioning`, and download the following files:
    * `.p12` (certificate)
    * `.mobileprovision` (provisioning profile)

#
### Obtaining the Feather `.ipa`

1. Download the latest Feather ipa from <https://github.com/khcrysalis/Feather/releases>

## Installation Guide

1. Go to signulous and..
    * Go to `upload app`
    * Select the ipa you just downloaded
    * Press `upload`, and after its finished, download the IPA
    * Press `open in iTunes` on the pop up
    * Lastly, press `install`, and it will proceed to install

Congratulations! You've installed Feather on your device, now, you will need to import your certificates to be able to use Feather. The guide below will help you achieve that.

## Usage 

This will guide you on how you will import your certificates to Feather

1. Make sure Feather is installed and on your homescreen
2. Open Feather and go to the settings tab in the bottom left corner, scroll down to signing and add your files
   * Password for signulous certificate is `123456`

Congratulations, you can now sign and install any ipa with Feather
