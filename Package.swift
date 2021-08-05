// swift-tools-version:5.3
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
    dependencies: [
        .package(name: "MapboxCoreMaps", url: "https://github.com/mapbox/mapbox-core-maps-ios.git", .exact("10.0.0-rc.6")),
        .package(name: "MapboxMobileEvents", url: "https://github.com/mapbox/mapbox-events-ios.git", .exact("1.0.2")),
        .package(name: "MapboxCommon", url: "https://github.com/mapbox/mapbox-common-ios.git", .exact("16.2.0")),
        .package(name: "Turf", url: "https://github.com/mapbox/turf-swift.git", .exact("2.0.0-rc.1")),
        .package(name: "CocoaImageHashing", url: "https://github.com/ameingast/cocoaimagehashing", .exact("1.9.0"))
    ],
    targets: [
        .target(
            name: "MapboxMaps",
            dependencies: ["MapboxCoreMaps", "Turf", "MapboxMobileEvents", "MapboxCommon"],
            exclude: [
                "Info.plist"
            ]
        ),
        .testTarget(
            name: "MapboxMapsTests",
            dependencies: ["MapboxMaps", "CocoaImageHashing"],
            exclude: [
                "Info.plist",
                "Foundation/Integration Tests/HTTP/HTTPIntegrationTests.swift",
            ],
            resources: [
                .copy("Foundation/GeoJSON/Fixtures/point.geojson"),
                .copy("Foundation/GeoJSON/Fixtures/multipoint.geojson"),
                .copy("Foundation/GeoJSON/Fixtures/multiline.geojson"),
                .copy("Foundation/GeoJSON/Fixtures/geometry-collection.geojson"),
                .copy("Foundation/GeoJSON/Fixtures/featurecollection.geojson"),
                .copy("Foundation/GeoJSON/Fixtures/featurecollection-no-properties.geojson"),
                .copy("Foundation/GeoJSON/Fixtures/simple-line.geojson"),
                .copy("Foundation/GeoJSON/Fixtures/polygon.geojson"),
                .copy("Foundation/GeoJSON/Fixtures/multipolygon.geojson"),
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
