// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let commonVersion = "23.7.0-7fa37a087805f1f045c68bfc65dbf7f281055117-SNAPSHOT"
let commonChecksum = "6d25fc4b89cc0b8a951a838959d7b72e2c8a18719187b3777ef55d42fe8083ad"

let coreVersion = "10.15.0"
let coreChecksum = "97d1523212abf482deae5874bc8844663d89051cdaf737e941e1f8aff9e0ff9e"

func folder(_ version: String) -> String { version.contains("SNAPSHOT") ? "snapshots" : "releases" }

let mapboxMapsPath: String? = nil
let mapboxMapsTestsPath: String? = nil

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
        // We keep MME dependency for compatibility reasons
        .package(name: "MapboxMobileEvents", url: "https://github.com/mapbox/mapbox-events-ios.git", .exact("1.0.10")),
        .package(name: "Turf", url: "https://github.com/mapbox/turf-swift.git", from: "2.0.0"),
        .package(name: "CocoaImageHashing", url: "https://github.com/ameingast/cocoaimagehashing", .exact("1.9.0"))
    ],
    targets: [
        .binaryTarget(
            name: "MapboxCoreMaps",
            url: "https://api.mapbox.com/downloads/v2/mobile-maps-core/\(folder(coreVersion))/ios/packages/\(coreVersion)/MapboxCoreMaps.xcframework-dynamic.zip",
            checksum: coreChecksum
        ),
        .binaryTarget(
            name: "MapboxCommon",
            url: "https://api.mapbox.com/downloads/v2/mapbox-common/\(folder(commonVersion))/ios/packages/\(commonVersion)/MapboxCommon.zip",
            checksum: commonChecksum
        ),
        .target(
            name: "MapboxMaps",
            dependencies: ["MapboxCoreMaps", "Turf", "MapboxCommon"],
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
