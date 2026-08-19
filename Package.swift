// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "workation2026",
    platforms: [
        .macOS(.v13),
    ],
    dependencies: [
        .package(url: "https://github.com/tomieq/SwiftAgent.git", branch: "master"),
    ],
    targets: [
        .executableTarget(
            name: "workation2026",
            dependencies: [
                .product(name: "SwiftAgent", package: "SwiftAgent"),
            ]
        ),
        .testTarget(
            name: "workation2026Tests",
            dependencies: ["workation2026"]
        ),
    ]
)
