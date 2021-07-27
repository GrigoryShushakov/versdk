// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "VerSDK",
    platforms: [
            .iOS(.v13)
        ],
    products: [
        .library(
            name: "VerSDK",
            targets: ["VerSDK"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "VerSDK",
            dependencies: []),
        .testTarget(
            name: "VerSDKTests",
            dependencies: ["VerSDK"]),
    ]
)
