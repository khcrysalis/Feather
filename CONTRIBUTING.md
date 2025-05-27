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
  - This includes localizations
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

#### Localizations
- For localizations, you will need Xcode 15 or higher to edit the `Feather/Resources/Localizable.xcstrings` file, or some alternative software which allows you to edit an `.xcstrings` file. 
- We use a newer format for convenience, but at a cost of less accessibility when it comes to actually editing it.
  - **Disclaimer: do NOT edit by hand.**
- Some localizations were imported from V1, if they don't make sense please feel free to change them.
- After localizing, please have another person review your localizations (unless the owners have asked you personally to help translate). 
  - We want high quality localizations and have them actually make sense when in the application.
  - They will not be merged unless the latter was done.

#### Making a pull request

- Make sure your contributions stay isolated in their own branch, and not `main`.
- When contributing don't be afraid of any reviewers requesting changes or judging how you wrote something, it's all to keep the project clean and tidy.

## Contributing to Zsign

When contributing to Zsign, head over to [khcrysalis/Zsign-Package](https://github.com/khcrysalis/Zsign-Package/tree/package) and make your contributions.

Any contributions to here will be immediately updated to here, to keep things consistent.

## Contributing to the wiki
- If you want to add a page or suggest edits, make an issue with your proposed changes.
