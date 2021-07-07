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
        .package(name: "MapboxCoreMaps", url: "https://github.com/mapbox/mapbox-core-maps-ios.git", .exact("10.0.0-rc.4")),
        .package(name: "MapboxMobileEvents", url: "https://github.com/mapbox/mapbox-events-ios.git", .exact("1.0.2")),
        .package(name: "MapboxCommon", url: "https://github.com/mapbox/mapbox-common-ios.git", .exact("15.0.0")),
        .package(name: "Turf", url: "https://github.com/mapbox/turf-swift.git", .exact("2.0.0-beta.1")),
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
            dependencies: ["MapboxMaps"],
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
                .copy("Resources/Snapshot-Asset.png"),
                .process("Resources/MapInitOptionsTests.xib"),
            ]
        )
    ]
)
