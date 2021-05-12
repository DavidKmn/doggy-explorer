// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "iOSUIComponents",
    platforms: [.iOS(.v10)],
    products: [
        .library(
            name: "iOSUIComponents",
            targets: ["iOSUIComponents"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "iOSUIComponents",
            dependencies: []),
        .testTarget(
            name: "iOSUIComponentsTests",
            dependencies: ["iOSUIComponents"]),
    ]
)
