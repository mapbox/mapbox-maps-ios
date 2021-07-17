// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "DepsValidator",
    platforms: [.macOS(.v10_13)],
    products: [
        .executable(name: "depsvalidator", targets: ["DepsValidator"]),
        .library(name: "DepsValidatorLibrary", targets: ["DepsValidatorLibrary"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.4.3"),
        .package(url: "https://github.com/jpsim/Yams", from: "4.0.6"),
        .package(url: "https://github.com/Carthage/Carthage", from: "0.38.0"),
    ],
    targets: [
        .target(
            name: "DepsValidator",
            dependencies: [
                .target(name: "DepsValidatorLibrary"),
            ]),
        .target(
            name: "DepsValidatorLibrary",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Yams", package: "Yams"),
                .product(name: "CarthageKit", package: "Carthage"),
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
