// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "DepsValidator",
    platforms: [.macOS(.v10_15)],
    products: [
        .executable(name: "depsvalidator", targets: ["DepsValidator"]),
        .library(name: "DepsValidatorLibrary", targets: ["DepsValidatorLibrary"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.4.3"),
        .package(url: "https://github.com/jpsim/Yams", from: "4.0.6"),
    ],
    targets: [
        .executableTarget(
            name: "DepsValidator",
            dependencies: [
                .target(name: "DepsValidatorLibrary"),
            ]),
        .target(
            name: "DepsValidatorLibrary",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Yams", package: "Yams"),
            ]),
        .testTarget(
            name: "DepsValidatorTests",
            dependencies: [
                "DepsValidatorLibrary",
            ],
            resources: [
                .copy("Example Manifests/Package.swift.example"),
                .copy("Example Manifests/Example.podspec"),
            ]),
    ]
)
