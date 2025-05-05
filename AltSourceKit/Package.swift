// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AltSourceKit",
	platforms: [
		.iOS(.v14),
		.tvOS(.v14),
		.custom("xros", versionString: "1.3")
	],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AltSourceKit",
            targets: ["AltSourceKit"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "AltSourceKit"),

    ]
)
