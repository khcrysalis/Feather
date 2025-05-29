## Gathering Files

### Obtaining the `.p12`

1. Make sure that openssl is set up on your computer

2. Run these two commands to generate a .csr and .key file (fill out a password for the .key file), you will be prompted to put in some information after running
  - `openssl genrsa -out csr.key 2048`
  - `openssl req -new -key csr.key -out csr.csr`

3. Head over to the apple developer portal, go to the certificates section, select apple distribution, and then upload your certificate request (we generated this in the previous step)
download your `.cer` file here

4. Run this command after changing the .cer path for your own, this converts the file into a different format for the next step (.pem)
`openssl x509 -in <path/to/cer.cer> -inform DER -out distribution.pem -outform PEM`

5. Run this command after changing the .key path for your own, and the .pem path for your own (we generated this in the previous step)
`openssl pkcs12 -export -inkey </path/to/key.key> -in <path/to/pem.pem> -out distribution.p12`

    YOU MUST MAKE A PASSWORD FOR YOUR .P12, YOU WILL BE REQUIRED TO INPUT THE PASSWORD YOU MADE FOR THE .KEY TO DO SO

Now that you have your .p12, everything else can be done through the apple development portal

#
### Obtaining the `.mobileprovision`

1. Go back to the apple developer profile and under identifiers, create a new app id. Make this app id explicit rather than wildcard, and enter your preferred reverse-domain name string (com.blank.yourshere as an example), enable the push notification capability, and now you've got your app id.
2. If you haven't already, add your iOS device under the devices section with your UDID.
    * Use iTunes to find your UDID
    * Or use [udid.tech](https://udid.tech) to see what your UDID is, has to be downloaded on device
3. Under profiles, register one under adhoc distribution, select your app id that you have created previously, and select your iOS device of which you have added under the devices tab
    * Click continue and you will obtain your `.mobileprovision`

#
### Obtaining the Feather `.ipa`

1. Download the latest Feather ipa from <https://github.com/khcrysalis/Feather/releases>

## Installation

1. Go to [sign.kravasign.com](https://sign.kravasign.com)
    * Upload all the neccessary files
        * `.p12`, `.mobileprovision`, `.ipa`, and type in the certificate password
    * Press `sign`, and it will proceed to install.

## Usage 

This will guide you on how you will import your certificates to Feather

1. Make sure Feather is installed and on your homescreen
2. Open Feather and go to the settings tab in the bottom left corner, scroll down to signing and add your files
    * Password for this certificate will be the one you entered earlier

Congratulations, you can now sign and install any ipa with Feather
