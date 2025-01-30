
# Feather
[![GitHub Release](https://img.shields.io/github/v/release/khcrysalis/feather?include_prereleases)](https://github.com/khcrysalis/feather/releases)
[![GitHub Downloads (all assets, all releases)](https://img.shields.io/github/downloads/khcrysalis/feather/total)](https://github.com/khcrysalis/feather/releases)
[![GitHub License](https://img.shields.io/github/license/khcrysalis/feather?color=%23C96FAD)](https://github.com/khcrysalis/feather/blob/main/LICENSE)

Feather allows you to use an Apple Developer Account to sign and install applications on device without needing a computer on stock iOS versions, while allowing easy management with its applications.

Due to limitations, it's hard to tell if the application is actually installed, so you will need to keep track of whats on your device. This is an entirely stock application and uses built-in features to be able to do this!

## Features

- Altstore repo support.
- Import your own `.ipa`'s.
- Inject tweaks when signing apps.
- Install applications straight to your device seamlessly over the air.
- Allows multiple certificate imports for easy switching.
- Configurable signing options.
- Meant to be used with Apple Accounts that are apart of `ADP` (Apple Developer Program).
- No tracking, analytics, or any of the sort.

## Preview

| <p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="Images/Repos.png"><source media="(prefers-color-scheme: light)" srcset="Images/Repos_L.png"><img alt="Pointercrate-pocket." src="Images/Repos_L.png" width="200"></picture></p> | <p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="Images/Store.png"><source media="(prefers-color-scheme: light)" srcset="Images/Store_L.png"><img alt="Pointercrate-pocket." src="Images/Store_L.png" width="200"></picture></p> | <p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="Images/Library.png"><source media="(prefers-color-scheme: light)" srcset="Images/Library_L.png"><img alt="Pointercrate-pocket." src="Images/Library_L.png" width="200"></picture></p> | <p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="Images/Sign.png"><source media="(prefers-color-scheme: light)" srcset="Images/Sign_L.png"><img alt="Pointercrate-pocket." src="Images/Sign_L.png" width="200"></picture></p> |
|:--:|:--:|:--:|:--:|
| **Sources** | **Store** | **Library** | **Signing** |

## Building

#### Minimum requirements

- Xcode 15
- Swift 5.9
- iOS 15

Feather is not exactly as light as a feather as it needs to include an entire server framework so it can host it's server locally, totaling around 40mb~ when successfully compiled. While this is annoying to me, it doesn't really matter at the end as it does it's job.

1. Clone repository
    ```sh
    git clone https://github.com/khcrysalis/Feather
    ```

2. Compile
    ```sh
    cd Feather
    gmake package SCHEME="'feather (Release)'" # Build, Use `SCHEME="'feather (Debug)'"` for debug build
    ```

3. Updating
    ```sh
    git pull
    ```

Using the makefile will automatically create an unsigned ipa inside the packages directory, using this to debug or report issues is not recommend. When making a pull request or reporting issues, it's generally advised you've used Xcode to debug your changes properly.

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

- ~~[localhost.direct](https://github.com/Upinel/localhost.direct) - localhost with public CA signed SSL certificate~~
- [*.backloop.dev](https://backloop.dev/) - localhost with public CA signed SSL certificate
- [Vapor](https://github.com/vapor/vapor) - A server-side Swift HTTP web framework.
- [Zsign](https://github.com/zhlynn/zsign) - Allowing to sign on-device, reimplimented to work on other platforms such as iOS.
- [Nuke](https://github.com/kean/Nuke) - Image caching.
- [Asspp](https://github.com/Lakr233/Asspp) - Some code for setting up the http server.
- [plistserver](https://github.com/nekohaxx/plistserver) - Hosted on https://api.palera.in

## License 

This project is licensed under the GPL-3.0 license. You can see the full details of the license [here](https://github.com/khcrysalis/Feather/blob/main/LICENSE). It's under this specific license because I wanted to make a project that is transparent to the user thats related to Apple Developer Account sideloading, before this project there weren't any open source projects that filled in this gap.

By contributing to this project, you agree to license your code under the GPL-3.0 license as well, ensuring that your work, like all other contributions, remains freely accessible and open.

