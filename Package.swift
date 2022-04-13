// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Sliders",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13)
    ],
    products: [
        .library(name: "Sliders", targets: ["Sliders"]),
    ],
    targets: [
        .target(name: "Sliders", path: "Sources"),
        .testTarget(name: "SlidersTests", dependencies: ["Sliders"]),
    ]
)
