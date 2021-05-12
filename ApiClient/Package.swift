// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "ApiClient",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "ApiClient",
            targets: ["ApiClient"]),
        .library(
            name: "ApiClientLive",
            targets: ["ApiClientLive"])
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "ApiClient",
            dependencies: []),
        .testTarget(
            name: "ApiClientTests",
            dependencies: ["ApiClient"]),
        
        .target(
            name: "ApiClientLive",
            dependencies: ["ApiClient"]),
    ]
)
