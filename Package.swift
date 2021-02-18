// swift-tools-version:5.3
 // The swift-tools-version declares the minimum version of Swift required to build this package.

 import PackageDescription

 let package = Package(
     name: "MapboxMaps",
     platforms: [.iOS(.v11)],
     products: [
         .library(
             name: "MapboxMaps",
             targets: ["MapboxMaps"]),
     ],
     dependencies: [
        .package(name: "MapboxCommon", url: "https://github.com/mapbox/mapbox-common-ios.git", .exact("10.0.0-beta.11")),
        .package(name: "MapboxCoreMaps", url: "https://github.com/mapbox/mapbox-core-maps-ios.git", .exact("10.0.0-beta.15")),
        .package(name: "MapboxMobileEvents", url: "https://github.com/mapbox/mapbox-events-ios.git", .exact("0.12.0-alpha.1")),
        .package(name: "Turf", url: "https://github.com/mapbox/turf-swift.git", "1.2.0"..<"2.0.0"),
     ],
     targets: [
         .target(
             name: "MapboxMaps",
            dependencies: ["MapboxCommon", "MapboxCoreMaps", "Turf", "MapboxMobileEvents"],
            exclude: [
                "MapboxMaps/Info.plist",
                "MapboxMapsStyle/README.md",
                "MapboxMapsAnnotations/Info.plist",
                "MapboxMapsStyle/Info.plist",
                "MapboxMapsSnapshot/Info.plist",
                "MapboxMapsFoundation/Info.plist",
                "MapboxMapsOrnaments/OrnamentsLocalizable.strings",
                "MapboxMapsOffline/Info.plist",
                "MapboxMapsLocation/Info.plist",
                "MapboxMapsOrnaments/Info.plist",
                "MapboxMapsGestures/Info.plist"
            ]
         ),
        .testTarget(name: "MapboxMapsTests",
                    dependencies: ["MapboxMaps"],
                    exclude: ["MapboxMapsTests/Info.plist",
                              "MapboxMapsStyleTests/Info.plist",
                              "MapboxMapsGesturesTests/Info.plist",
                              "MapboxMapsAnnotationsTests/Info.plist",
                              "MapboxMapsLocationTests/Info.plist",
                              "MapboxMapsFoundationTests/Info.plist",
                              "MapboxMapsOfflineTests/Info.plist",
                              "MapboxMapsOrnamentsTests/Info.plist",
                              "MapboxMapsTests/Info.plist",
                              "MapboxMapsSnapshotTests/Info.plist"
                    ],
                    resources: [
                        .copy("MapboxMapsFoundationTests/GeoJSON/Fixtures/point.geojson"),
                        .copy("MapboxMapsFoundationTests/GeoJSON/Fixtures/multipoint.geojson"),
                        .copy("MapboxMapsFoundationTests/GeoJSON/Fixtures/multiline.geojson"),
                        .copy("MapboxMapsFoundationTests/GeoJSON/Fixtures/geometry-collection.geojson"),
                        .copy("MapboxMapsFoundationTests/GeoJSON/Fixtures/featurecollection.geojson"),
                        .copy("MapboxMapsFoundationTests/GeoJSON/Fixtures/featurecollection-no-properties.geojson"),
                        .copy("MapboxMapsFoundationTests/GeoJSON/Fixtures/simple-line.geojson"),
                        .copy("MapboxMapsFoundationTests/GeoJSON/Fixtures/polygon.geojson"),
                        .copy("MapboxMapsFoundationTests/GeoJSON/Fixtures/multipolygon.geojson"),
                        .copy("MapboxMapsTests/TestHelpers/MapboxAccessToken.token")
                        ]
                    )
     ]
 )
