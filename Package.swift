// swift-tools-version:5.4
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
//        .package(name: "MapboxCoreMaps", url: "https://github.com/mapbox/mapbox-core-maps-ios.git", .exact("10.8.0")),
        .package(name: "MapboxCommon", url: "https://github.com/mapbox/mapbox-common-ios.git", .exact("23.0.0")),
        .package(name: "MapboxMobileEvents", url: "https://github.com/mapbox/mapbox-events-ios.git", .exact("1.0.9")),
        .package(name: "Turf", url: "https://github.com/mapbox/turf-swift.git", from: "2.0.0"),
        .package(name: "CocoaImageHashing", url: "https://github.com/ameingast/cocoaimagehashing", .exact("1.9.0"))
    ],
    targets: [
        .binaryTarget(name: "MapboxCoreMaps",
                      url: "https://api.mapbox.com/downloads/v2/mobile-maps-core/snapshots/ios/packages/10.8.0-rc.1-0889c5af12-SNAPSHOT/MapboxCoreMaps.xcframework-dynamic.zip",
                      checksum: "d6bfd0fc1f1a3dc10bb0b01f4d2f0eb61afc691c6d79ee77e6ebfb9d10837be0"),
        .target(
            name: "MapboxMaps",
            dependencies: ["MapboxCoreMaps", "Turf", "MapboxMobileEvents", "MapboxCommon"],
            exclude: [
                "Info.plist"
            ],
            resources: [
                .copy("MapboxMaps.json")
            ]
        ),
        .testTarget(
            name: "MapboxMapsTests",
            dependencies: ["MapboxMaps", "CocoaImageHashing"],
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
