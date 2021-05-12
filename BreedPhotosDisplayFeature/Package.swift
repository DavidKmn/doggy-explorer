// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "BreedPhotosDisplayFeature",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "BreedPhotosDisplayFeature",
            targets: ["BreedPhotosDisplayFeature"]),
    ],
    dependencies: [
        .package(path: "../ImageRetrievalClient"),
        .package(path: "../ApiClient"),
        .package(path: "../iOSUIComponents")
    ],
    targets: [
        .target(
            name: "BreedPhotosDisplayFeature",
            dependencies: [
                .product(name: "ImageRetrievalClient", package: "ImageRetrievalClient"),
                .product(name: "ApiClient", package: "ApiClient"),
                .product(name: "iOSUIComponents", package: "iOSUIComponents")
            ]),
        .testTarget(
            name: "BreedPhotosDisplayFeatureTests",
            dependencies: ["BreedPhotosDisplayFeature"]),
    ]
)
