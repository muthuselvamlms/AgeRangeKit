// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AgeRangeKit",
    platforms: [
        .iOS(.v14),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "AgeRangeKit",
            targets: ["AgeRangeKit"]
        ),
    ],
    targets: [
        .target(
            name: "AgeRangeKit",
            path: "AgeRangeKit",
            exclude: [],
            resources: [],
            publicHeadersPath: nil
        ),
        .testTarget(
            name: "AgeRangeKitTests",
            dependencies: ["AgeRangeKit"],
            path: "AgeRangeKitTests"
        )
    ]
)
