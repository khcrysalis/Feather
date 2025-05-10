# Contributing

Feather is a sideloading app meant to be used on stock versions, to keep compatibility we have to utililize stock features to keep it working. As such, we have specific contribution rules in place to maintain this and Feathers integrity.

Any contributions should follow the [Code of Conduct](./CODE_OF_CONDUCT.md).

## Rules

- **No usage of any exploits of any kind**.
- **No contributions related to retrieving any signing certificates owned by companies**.
- **Modifying any hardcoded links should be discussed before changing**.
- **If you're planning on making a large contribution, please [make an issue](https://github.com/khcrysalis/Feather) beforehand**.
- **Your contributions should be licensed appropriately**. 
  - Feather: GPLv3
  - AltSourceKit: MIT
  - NimbleKit: MIT 
  - Zsign: MIT
- **Typo contributions are okay**, just make sure they are appropriate.
- **Code cleaning contributions are okay**.

## Contributing to Feather

#### Compiling requirements

- Xcode 16.0
- Swift 6.0
- iOS 16.0

1. Clone repository
    ```sh
    git clone https://github.com/khcrysalis/Feather --recursive
    ```
    - `Zsign` is a submodule, recursive is required.

2. Opening with Xcode
    ```sh
    cd Feather && open Feather.xcworkspace
    ```

#### Making a pull request

- Make sure your contributions stay isolated in their own branch, and not `main`.
- When contributing don't be afraid of any reviewers requesting changes or judging how you wrote something, it's all to keep the project clean and tidy.

## Contributing to Zsign

When contributing to Zsign, head over to [khcrysalis/Zsign-Package](https://github.com/khcrysalis/Zsign-Package/tree/package) and make your contributions.

Any contributions to here will be immediately updated to here, to keep things consistent.