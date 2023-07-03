// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let coreVersion = "11.0.0-SNAPSHOT.0630T0845Z.a04a20c"
let coreChecksum = "b69aa030a7a6901605abc9f43d2551cf8377aa9478b4950445f2f664a74f1849"
let commonVersion = "24.0.0-SNAPSHOT.0628T1118Z.b052007"
let commonChecksum = "67812f0744b9ee4e1d96a6afc36de759d2696ba2de9ec9e4b1ef63dce87a9c85"

func folder(_ version: String) -> String { version.contains("SNAPSHOT") ? "snapshots" : "releases" }

let mapboxMapsPath: String? = nil
let mapboxMapsTestsPath: String? = nil

let package = Package(
    name: "MapboxMaps",
    defaultLocalization: "en",
    platforms: [.iOS(.v12)],
    products: [
        .library(
            name: "MapboxMaps",
            targets: ["MapboxMaps"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/mapbox/turf-swift.git", from: "2.0.0"),
    ],
    targets: [
        .binaryTarget(
            name: "MapboxCoreMaps",
            url: "https://api.mapbox.com/downloads/v2/mobile-maps-core-internal/\(folder(coreVersion))/ios/packages/\(coreVersion)/MapboxCoreMaps.xcframework-dynamic.zip",
            checksum: coreChecksum
        ),
        .binaryTarget(
            name: "MapboxCommon",
            url: "https://api.mapbox.com/downloads/v2/mapbox-common/\(folder(commonVersion))/ios/packages/\(commonVersion)/MapboxCommon.zip",
            checksum: commonChecksum
        ),
        .target(
            name: "MapboxMaps",
            dependencies: [
                "MapboxCoreMaps",
                .product(name: "Turf", package: "turf-swift"),
                "MapboxCommon",
            ],
            path: mapboxMapsPath,
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
                "MapboxMaps",
            ],
            path: mapboxMapsTestsPath,
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
        ),
    ]
)
