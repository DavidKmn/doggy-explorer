// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "ImageRetrievalClient",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "ImageRetrievalClient",
            targets: ["ImageRetrievalClient"]),
        .library(
            name: "ImageRetrievalClientLive",
            targets: ["ImageRetrievalClientLive"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/onevcat/Kingfisher.git",
            from: "6.3.0"
        )
    ],
    targets: [
        .target(
            name: "ImageRetrievalClient",
            dependencies: []),
        .testTarget(
            name: "ImageRetrievalClientTests",
            dependencies: ["ImageRetrievalClient"]),
        
        .target(
            name: "ImageRetrievalClientLive",
            dependencies: [
                "Kingfisher",
                "ImageRetrievalClient"
            ]),
    ]
)
