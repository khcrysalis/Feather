Welcome to the Feather wiki!\
This wiki is a work in progress, contributors feel free to edit and modify the wiki to add/update information.

## About

Feather is an on-device signing tool designed to be able to install apps on your device with ease, provided you have valid certificates to be able to sideload to your device (i.e. from the Apple Developer Program).

> [!TIP]
> If you're using a DNS method to sign, please do not blacklist `*.backloop.dev`, as it would interfere with installation

## Table of Contents

* [**Home**](https://github.com/khcrysalis/Feather/wikie)
    * [**About**](https://github.com/khcrysalis/Feather/wiki#about)
    * [**Table of Contents**](https://github.com/khcrysalis/Feather/wiki#table-of-contents)
    * [**Contributing**](https://github.com/khcrysalis/Feather/wiki#contributing)
* [**Using an Apple Developer Account**](https://github.com/khcrysalis/Feather/wiki/Using-an-Apple-Developer-Account)
    * [**Gathering Files**](https://github.com/khcrysalis/Feather/wiki/Using-an-Apple-Developer-Account#gathering-files)
    * [**Installation**](https://github.com/khcrysalis/Feather/wiki/Using-an-Apple-Developer-Account#installation)
    * [**Usage**](https://github.com/khcrysalis/Feather/wiki/Using-an-Apple-Developer-Account#usage)
* [**Using an Apple Developer Account Non-Mac**](https://github.com/khcrysalis/Feather/wiki/Apple-Developer-Account-Non%E2%80%90Mac)
    * [**Gathering Files**](https://github.com/khcrysalis/Feather/wiki/Apple-Developer-Account-Non%E2%80%90Mac#gathering-files)
    * [**Installation**](https://github.com/khcrysalis/Feather/wiki/Apple-Developer-Account-Non%E2%80%90Mac#installation)
    * [**Usage**](https://github.com/khcrysalis/Feather/wiki/Apple-Developer-Account-Non%E2%80%90Mac#usage)
* [**Using KravaSign Certs**](https://github.com/khcrysalis/Feather/wiki/Using-KravaSign-Certs)
    * [**Gathering Files**](https://github.com/khcrysalis/Feather/wiki/Using-KravaSign-Certs#gathering-files)
    * [**Installation**](https://github.com/khcrysalis/Feather/wiki/Using-KravaSign-Certs#installation)
    * [**Usage**](https://github.com/khcrysalis/Feather/wiki/Using-KravaSign-Certs#usage)
* [**Using Signulous Certs**](https://github.com/khcrysalis/Feather/wiki/Using-Signulous-Certs)
    * [**Gathering Files**](https://github.com/khcrysalis/Feather/wiki/Using-Signulous-Certs#gathering-files)
    * [**Installation**](https://github.com/khcrysalis/Feather/wiki/Using-Signulous-Certs#installation)
    * [**Usage**](https://github.com/khcrysalis/Feather/wiki/Using-Signulous-Certs#usage)
* [Apple Developer Account + Local + Open Source](https://github.com/khcrysalis/Feather/wiki/Apple-Developer-Account---Local---Open-Source)

## Contributing

1. Clone the repository to your machine

```sh
git clone https://github.com/khcrysalis/feather
cd feather
```

2. Build to your device
    * `make package SCHEME="'feather (Debug)'"`
    * OR use Xcode to deploy Feather to your device

3. Edit the code; and after testing and found your changes are good and ready, you may move on to the next step

4. [Create a pull request](https://github.com/khcrysalis/Feather/pulls) so your changes can be integrated info Feather
     * Make sure you read the [Code of Conduct](https://github.com/khcrysalis/Feather?tab=coc-ov-file) before contributing
     * Any large requests please create an issue first before doing so
