// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "PowerKit",
  platforms: [
    .iOS(.v17),
    .macOS(.v14),
    .watchOS(.v10),
    .tvOS(.v17),
    .visionOS(.v1),
  ],
  products: [
    .library(name: "PowerKit", targets: ["PowerKit"])
  ],
  dependencies: [
    .package(url: "https://github.com/markbattistella/SimpleLogger", from: "26.0.0")
  ],
  targets: [
    .target(
      name: "PowerKit",
      dependencies: ["SimpleLogger"],
      swiftSettings: [
        .swiftLanguageMode(.v6)
      ]
    ),
    .testTarget(
      name: "PowerKitTests",
      dependencies: ["PowerKit"],
      swiftSettings: [
        .swiftLanguageMode(.v6)
      ]
    ),
  ],
  swiftLanguageModes: [.v6]
)
