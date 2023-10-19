// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let commonVersion = "24.0.0-beta.6"
let coreVersion = "11.0.0-beta.6"
let coreChecksum = "d378a8264840341b768a08f16175288dcb04b89bfe310dab2550971ba59fad95"

func folder(_ version: String) -> String { version.contains("SNAPSHOT") ? "snapshots" : "releases" }

let mapboxMapsPath: String? = nil

let package = Package(
    name: "MapboxMaps",
    defaultLocalization: "en",
    platforms: [.iOS(.v12)],
    products: [
        .library(
            name: "MapboxMaps",
            targets: ["MapboxMaps"]),
    ],
    dependencies: [
        .package(url: "https://github.com/mapbox/mapbox-common-ios.git", exact: Version(stringLiteral: commonVersion)),
        .package(url: "https://github.com/mapbox/turf-swift.git", exact: "2.7.0"),
    ],
    targets: [
        .binaryTarget(
            name: "MapboxCoreMaps",
            url: "https://api.mapbox.com/downloads/v2/mobile-maps-core/\(folder(coreVersion))/ios/packages/\(coreVersion)/MapboxCoreMaps.xcframework-dynamic.zip",
            checksum: coreChecksum
        ),
        .target(
            name: "MapboxMaps",
            dependencies: [
                "MapboxCoreMaps",
                .product(name: "MapboxCommon", package: "mapbox-common-ios"),
                .product(name: "Turf", package: "turf-swift")
            ],
            path: mapboxMapsPath,
            exclude: [
                "Info.plist",
            ],
            resources: [
                .copy("MapboxMaps.json"),
                .copy("PrivacyInfo.xcprivacy"),
            ]
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
        )
    ]
)
