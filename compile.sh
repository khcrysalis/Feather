#!/bin/bash

name="Feather"
platform="iphoneos"
schemes=(
    "Feather"
    "Feather (idevice)"
)

tmp=$TMPDIR/$name
stage="$tmp/stage"
app="$tmp/Build/Products/Release-$platform"

rm -rf $stage
rm -rf packages

if [ "$1" == "--clean" ]; then
    echo "Cleaning build files..."
    rm -rf $tmp
    rm -rf packages
    rm -rf Payload
    exit 0
fi

for scheme in "${schemes[@]}"; do
    echo "Building $name for $scheme..."
    xcodebuild \
        -project Feather.xcodeproj \
        -scheme "$scheme" \
        -configuration Release \
        -arch arm64 \
        -sdk $platform \
        -derivedDataPath $tmp \
        -skipPackagePluginValidation \
        CODE_SIGNING_ALLOWED=NO \
        ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES=NO # \
        # GCC_PREPROCESSOR_DEFINITIONS="\$(inherited) NIGHTLY=1" \
        # SWIFT_ACTIVE_COMPILATION_CONDITIONS="\$(inherited) NIGHTLY"

    rm -rf Payload
    rm -rf $stage/
    mkdir -p $stage/Payload

    echo $tmp
    echo $stage
    echo "$app/$scheme.app"

    mv "$app/$scheme.app" "$stage/Payload/$scheme.app"

    rm -rf "$stage/Payload/$scheme.app/_CodeSignature"
    ln -s "$stage/Payload" Payload
    
    mkdir -p packages

    zip -r9 "packages/$scheme-$platform.ipa" Payload
done
