// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "contacts-cli",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.7.0"),
    ],
    targets: [
        .executableTarget(
            name: "contacts-cli",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "contacts-cli-tests",
            dependencies: ["contacts-cli"],
            path: "Tests"
        ),
    ]
)
