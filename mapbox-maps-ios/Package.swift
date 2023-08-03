// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MapboxMaps",
    defaultLocalization: "en",
    platforms: [.iOS(.v12)],
    products: [
        .library(
            name: "MapboxMaps",
            targets: ["MapboxMaps"]),
        .library(
            name: "MapboxMapsSwiftUI",
            targets: ["MapboxMapsSwiftUI"])
    ],
    dependencies: [
        .package(url: "https://github.com/mapbox/mapbox-core-maps-ios.git", exact: "11.0.0-beta.2"),
        .package(url: "https://github.com/mapbox/mapbox-common-ios.git", exact: "24.0.0-beta.2"),
        .package(url: "https://github.com/mapbox/turf-swift.git", exact: "2.6.1"),
    ],
    targets: [
        .target(
            name: "MapboxMaps",
            dependencies: [
                .product(name: "MapboxCoreMaps", package: "mapbox-core-maps-ios"),
                .product(name: "MapboxCommon", package: "mapbox-common-ios"),
                .product(name: "Turf", package: "turf-swift")
            ],
            exclude: [
                "Info.plist",
            ],
            resources: [
                .copy("MapboxMaps.json"),
            ]
        ),
        .target(
            name: "MapboxMapsSwiftUI",
            dependencies: ["MapboxMaps"]
        ),
        .testTarget(
            name: "MapboxMapsTests",
            dependencies: [
                "MapboxMaps",
            ],
            exclude: [
                "Info.plist",
            ],
            resources: [
                .copy("MigrationGuide/Fixtures/polygon.geojson"),
                .copy("Helpers/MapboxAccessToken"),
                .copy("Resources/empty-style-chicago.json"),
                .copy("Snapshot/testDoesNotShowAttribution().png"),
                .copy("Snapshot/testDoesNotShowLogo().png"),
                .copy("Snapshot/testDoesNotShowLogoAndAttribution().png"),
                .copy("Snapshot/testShowsLogoAndAttribution().png"),
                .copy("Snapshot/testSnapshotAttribution-100.png"),
                .copy("Snapshot/testSnapshotAttribution-150.png"),
                .copy("Snapshot/testSnapshotAttribution-200.png"),
                .copy("Snapshot/testSnapshotAttribution-250.png"),
                .copy("Snapshot/testSnapshotAttribution-300.png"),
                .copy("Snapshot/testSnapshotAttribution-50.png"),
                .copy("Snapshot/testSnapshotLogoVisibility.png"),
                .copy("Snapshot/testSnapshotOverlay.png"),
                .process("Resources/MapInitOptionsTests.xib"),
            ]
        ),
        .testTarget(
            name: "MapboxMapsSwiftUITests",
            dependencies: [
                "MapboxMapsSwiftUI",
                "MapboxMaps"
            ])
    ]
)
