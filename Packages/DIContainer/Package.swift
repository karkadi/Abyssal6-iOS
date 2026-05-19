// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "DIContainer",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .watchOS(.v6),
        .tvOS(.v13),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "DIContainer",
            targets: ["DIContainer"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "DIContainer",
            dependencies: [],
            path: "Sources/DIContainer",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "DIContainerTests",
            dependencies: ["DIContainer"],
            path: "Tests/DIContainerTests"
        )
    ]
)
