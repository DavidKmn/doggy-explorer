// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BreedsListFeature",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "BreedsListFeature",
            targets: ["BreedsListFeature"]),
    ],
    dependencies: [
        .package(path: "../ImageRetrievalClient"),
        .package(path: "../ApiClient"),
        .package(path: "../iOSUIComponents")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "BreedsListFeature",
            dependencies: [
                .product(name: "ImageRetrievalClient", package: "ImageRetrievalClient"),
                .product(name: "ApiClient", package: "ApiClient"),
                .product(name: "iOSUIComponents", package: "iOSUIComponents")
            ]),
        .testTarget(
            name: "BreedsListFeatureTests",
            dependencies: ["BreedsListFeature"]),
    ]
)
