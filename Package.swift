// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "SwiftCache",
    platforms: [.macOS(.v10_11), .iOS(.v11), .tvOS(.v10)],
    products: [
        .library(name: "SwiftCache", targets: ["SwiftCache"])
    ],
    dependencies: [],
    targets: [
        .target(name: "SwiftCache"),
        .testTarget(name: "SwiftCacheTests", dependencies: ["SwiftCache"])
    ]
)
