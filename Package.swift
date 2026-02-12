// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "PowerKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10),
        .tvOS(.v17),
        .visionOS(.v1)
    ],
    products: [
        .library(name: "PowerKit", targets: ["PowerKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/markbattistella/SimpleLogger", from: "25.0.0")
    ],
    targets: [
        .target(
            name: "PowerKit",
            dependencies: ["SimpleLogger"],
            swiftSettings: [.enableExperimentalFeature("StrictConcurrency")]
        ),
        .testTarget(
            name: "PowerKitTests",
            dependencies: ["PowerKit"]
        )
    ]
)
