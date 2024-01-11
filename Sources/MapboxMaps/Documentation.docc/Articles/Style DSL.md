# Style DSL

Use declarative syntax to modify your Mapbox Style at runtime. 

## Overview

In version `11.2.0-beta.1` of MapboxMaps we introduced an experimental Style DSL to make runtime styling easier to manage. With the Style DSL you can add or edit Sources, Layers, Images, and other map style elements with ease in both Swift UI- and UIKit-based implementations. This paradigm works with Mapbox Standard, classic Mapbox styles like Streets and Dark, and any custom styles that you've built with Mapbox Studio. As this feature is experimental, you will need to import `MapboxMaps` with the experimental API enabled. 

### Getting started

To start using the Style DSL you need to import `MapboxMaps` with `@_spi(Experimental)`. This way you can try the new APIs that have experimental support. Note that as these APIs are experimental there may be breaking changes between minor versions.

```swift
@_spi(Experimental) import MapboxMaps
```

### Adding map content at runtime

With the Style DSL you can declare additions or changes to Sources, Layers, Images, Terrain, Atmosphere, and Projections of your style from within the Map().mapStyle() declaration. For example, if you wanted to add a new line layer based off of vector tiles from a third-party source you would make the below declaration. This code creates a Standard style map, adds the needed vector source with min and max zoom levels, and then adds a line layer with styling information to be placed in the "bottom" slot. 

@TabNavigator {
    @Tab("Swift UI") {
    ```swift
    var body: some View {
        Map()
            .mapStyle(.standard {
                VectorSource(id: "mapillary")
                    .tiles(["https://tiles.mapillary.com/maps/vtp/mly1_public/2/{z}/{x}/{y}?access_token=MLY%7C4142433049200173%7C72206abe5035850d6743b23a49c41333"])
                    .minzoom(5)
                    .maxzoom(14)
                LineLayer(id: "mapillary", source: "mapillary")
                    .sourceLayer("sequence")
                    .lineColor(.constant(.init(.random)))
                    .lineOpacity(.constant(0.6))
                    .lineWidth(.constant(2.0))
                    .lineCap(.constant(.round))
                    .slot("bottom")
            })
    }
    ```
    }
    @Tab("UIKit") {
    ```swift
    mapView.mapboxMap.mapStyle = .standard {
        VectorSource(id: "mapillary")
            .tiles(["https://tiles.mapillary.com/maps/vtp/mly1_public/2/{z}/{x}/{y}?access_token=MLY%7C4142433049200173%7C72206abe5035850d6743b23a49c41333"])
            .minzoom(5)
            .maxzoom(14)
        LineLayer(id: "mapillary", source: "mapillary")
            .sourceLayer("sequence")
            .lineColor(.constant(.init(.random)))
            .lineOpacity(.constant(0.6))
            .lineWidth(.constant(2.0))
            .lineCap(.constant(.round))
            .slot("bottom")
    }
    ```
    }
}

### Modifying the Map Style dynamically 

As seen, you can modify source and layer properties with a builder pattern. This pattern can be used for all properties of Sources, Layers, Images, Terrain, Atmosphere, and Projections. Additionally, you can update these properties at runtime and have the change visually reflected on the map. Further, you can remove map content from the map by resetting a new map style. Only the content that has been modified or removed will be updated. 

@TabNavigator {
    @Tab("Swift UI") {
    ```swift
    @State var useTerrain = true
    
    var body: some View {
        Map()
            .mapStyle(.standard {
                if useTerrain {
                    StyleProjection(name: .globe)
                    RasterDemSource(id: "mapbox-dem")
                        .url("mapbox://mapbox.mapbox-terrain-dem-v1")
                        .tileSize(514)
                        .maxzoom(14.0)
                    Terrain(sourceId: "mapbox-dem")
                        .exaggeration(.constant(5))
                } else {
                    StyleProjection(name: .mercator)
                }
            }
        )
    }
    ```
    }
    @Tab("UI Kit") {
    ```swift
    var useTerrain = true
    
    func updateStyle(useTerrain: Bool) {
        mapboxMap.mapStyle = .standard {
        if useTerrain {
            StyleProjection(name: .globe)
            RasterDemSource(id: "mapbox-dem")
                .url("mapbox://mapbox.mapbox-terrain-dem-v1")
                .tileSize(514)
                .maxzoom(14.0)
            Terrain(sourceId: "mapbox-dem")
                .exaggeration(.constant(5))
        } else {
            StyleProjection(name: .mercator)
        }
    }
    ```
    }
}

For a full implementation, see the [DynamicStylingExample](https://github.com/mapbox/mapbox-maps-ios/blob/main/Apps/Examples/Examples/Swift%20UI%20Examples/DynamicStyleExample.swift) in our examples application.
