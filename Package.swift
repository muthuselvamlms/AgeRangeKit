// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DeclaredAgeRangeKit",
    platforms: [
        .iOS(.v14),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "DeclaredAgeRangeKit",
            targets: ["DeclaredAgeRangeKit"]
        ),
    ],
    targets: [
        .target(
            name: "DeclaredAgeRangeKit",
            path: "DeclaredAgeRangeKit",
            exclude: [],
            resources: [],
            publicHeadersPath: nil
        ),
        .testTarget(
            name: "DeclaredAgeRangeKitTests",
            dependencies: ["DeclaredAgeRangeKit"],
            path: "DeclaredAgeRangeKitTests"
        )
    ]
)
