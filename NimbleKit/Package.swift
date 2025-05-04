// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "NimbleKit",
	platforms: [
		.iOS(.v16),
		.tvOS(.v16)
	],
	products: [
		.library(name: "NimbleExtensions", targets: ["NimbleExtensions"]),
		.library(name: "NimbleJSON", targets: ["NimbleJSON"]),
		.library(name: "NimbleViews", targets: ["NimbleViews"]),
	],
	targets: [
		.target(
			name: "NimbleViews",
			dependencies: ["NimbleExtensions"]
		),
		.target(
			name: "NimbleExtensions",
			dependencies: []
		),
		.target(name: "NimbleJSON",
			dependencies: []
		)
	]
)
