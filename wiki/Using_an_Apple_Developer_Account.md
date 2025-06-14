This page will guide you to getting the proper files from your account associated with `ADP` (Apple Developer Program)

## Gathering Files

### Obtaining the `.p12`

1. Open up keychain access on your macOS device
    * Find Certificate Assistant
    * Request a Certificate from a Certificate Authority

    Input a personal email address into the user email address section, enter a common name, and enter the email associated with your apple developer account under the CA address section. Select saved to disk, and then proceed.

2. Head over to the apple developer portal, go to the certificates section, select apple distribution, and then upload your certificate request (we generated this in the previous step)
    * Download your `.cer` file after this step

3. Import the `.cer` file into keychain access (drag and drop works fine)

4. You will now be able to select the certificate and export as a `.p12` file. (This step will have you make a password, remember this for the end)

#
### Obtaining the `.mobileprovision`

1. Go back to the apple developer profile and under identifiers, create a new app id. Make this app id explicit rather than wildcard, land enter your preferred reverse-domain name string (com.blank.yourshere as an example), enable the push notification capability, and now you've got your app id.
2. If you haven't already, add your iOS device under the devices section with your UDID.
    * Use iTunes to find your UDID
    * Or use [udid.tech](https://udid.tech) to see what your UDID is, has to be downloaded on device
3. Under profiles, register one under adhoc distribution, select your app id that you have created previously, and select your iOS device of which you have added under the devices tab
    * Click continue and you will obtain your `.mobileprovision`

#
### Obtaining the Feather `.ipa`

1. Download the latest Feather ipa from <https://github.com/khcrysalis/Feather/releases>

## Installation

1. Go to [sign.kravasign.com](https://sign.kravasign.com) (this must be done on your mobile device)
    * Upload all the neccessary files
        * `.p12`, `.mobileprovision`, `.ipa`, and type in the certificate password
    * Press `sign`, and it will proceed to install.

## Usage 

This will guide you on how you will import your certificates to Feather

1. Make sure Feather is installed and on your homescreen
2. Open Feather and go to the settings tab in the bottom left corner, scroll down to signing and add your files
    * Password for this certificate will be the one you entered earlier

Congratulations, you can now sign and install any ipa with Feather
