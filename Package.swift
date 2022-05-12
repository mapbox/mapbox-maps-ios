// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MapboxMaps",
    defaultLocalization: "en",
    platforms: [.iOS(.v11)],
    products: [
        .library(
            name: "MapboxMaps",
            targets: ["MapboxMaps"]),
    ],
    // when upgrading to swift tools version 5.6 or later,
    // replace `.package(name:url:_: .exact())` with `.package(url:exact:)`
    dependencies: [
        .package(name: "mapbox-core-maps-ios", url: "https://github.com/mapbox/mapbox-core-maps-ios.git", .exact("10.5.1")),
        .package(name: "mapbox-common-ios", url: "https://github.com/mapbox/mapbox-common-ios.git", .exact("21.3.0")),
        .package(name: "mapbox-events-ios", url: "https://github.com/mapbox/mapbox-events-ios.git", .exact("1.0.8")),
        .package(url: "https://github.com/mapbox/turf-swift.git", from: "2.0.0"),
        .package(url: "https://github.com/ameingast/cocoaimagehashing", from: "1.9.0"),
    ],
    targets: [
        .target(
            name: "MapboxMaps",
            dependencies: [
                .product(name: "MapboxCoreMaps", package: "mapbox-core-maps-ios"),
                .product(name: "Turf", package: "turf-swift"),
                .product(name: "MapboxMobileEvents", package: "mapbox-events-ios"),
                .product(name: "MapboxCommon", package: "mapbox-common-ios"),
            ],
            exclude: [
                "Info.plist",
            ],
            resources: [
                .copy("MapboxMaps.json"),
            ]
        ),
        .testTarget(
            name: "MapboxMapsTests",
            dependencies: [
                .target(name: "MapboxMaps"),
                .product(name: "CocoaImageHashing", package: "cocoaimagehashing"),
            ],
            exclude: [
                "Info.plist",
                "Integration Tests/HTTP/HTTPIntegrationTests.swift",
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
        )
    ]
)
