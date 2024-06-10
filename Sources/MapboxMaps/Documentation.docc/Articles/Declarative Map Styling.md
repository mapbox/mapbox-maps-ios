# Declarative Map Styling

Simplify runtime style manipulation with declarative syntax.

## Overview

Starting from version `11.4.0-beta.1` of Mapbox Maps SDK you can now use a declarative approach to add or update style primitives such as Sources, Layers, Images, and Lights at runtime. This paradigm simplifies working with all Mapbox styles at runtime and works well in SwiftUI and UIKit applications.

### Getting Started

As these features are experimental, there may be breaking changes between minor versions. In this period, we are especially interested in hearing feedback from developers like you! To provide feedback please open an issue in [mapbox-maps-ios](https://github.com/mapbox/mapbox-maps-ios/issues) repository. To opt-in, import MapboxMaps with the experimental SPI:

```swift
@_spi(Experimental) import MapboxMaps
```

- Note: Declarative styling is available starting from iOS 13.

Then, you can use the ``StyleManager/setMapStyleContent(content:)`` method, which is available in ``MapboxMap`` and ``Snapshotter`` instances.

```swift
// UIKit
let mapView = MapView()
mapView.mapboxMap.setMapStyleContent {
    VectorSource(id: "traffic-source")
        .tiles(["..."])

    LineLayer(id: "traffic-layer", source: "traffic-source")
        .lineColor(.red)
}
```

In SwiftUI applications, simply place the style primitives inside the ``Map`` content:
```swift
// SwiftUI
Map {
    VectorSource(id: "traffic")
        .tiles(["..."])

    LineLayer(id: "traffic-layer", source: "traffic")
        .lineColor(.red)
}
```

- Important: You don't need to observe any events to modify the map style. Changes will be automatically applied when the map style is loaded.

### Map Style Primitives

Style primitives are pieces of map content that can be added, updated, and removed at runtime. These primitives represent the data sources and visualization choices for your map.

#### Building Style Primitives

You can use a builder syntax to modify the properties of your style primitives when you add them to your map. If you update these properties the changes will be reflected on your map.

```swift
// Create a atmosphere primitive and set properties for range, start intensity, and color
Atmosphere()
    .range(start: 0, end: 12)
    .horizonBlend(0.1)
    .starIntensity(0.2)
    .color(StyleColor(red: 240, green: 196, blue: 152, alpha: 1)!)
    .highColor(StyleColor(red: 221, green: 209, blue: 197, alpha: 1)!)
    .spaceColor(StyleColor(red: 153, green: 180, blue: 197, alpha: 1)!)
```

#### Available Style Primitives

Category     | Types supported
------------ | -------------------------------------
`Source`     | ``VectorSource``, ``RasterSource``, ``RasterDemSource``, ``GeoJSONSource``, ``ImageSource``, ``Model``, ``CustomGeometrySource`` (partial), ``CustomRasterSource`` (partial)
`Layer`      | ``FillLayer``, ``LineLayer``, ``SymbolLayer``, ``CircleLayer``, ``HeatmapLayer``, ``FillExtrusionLayer``, ``RasterLayer``, ``HillshadeLayer``, ``BackgroundLayer``, ``LocationIndicatorLayer``, ``SkyLayer``, ``ModelLayer``, ``SlotLayer``, ``CustomLayer`` (partial)
`Lights`     | ``FlatLight``, ``AmbientLight``, ``DirectionalLight``
`Map properties` | ``Projection``, ``Atmosphere``, ``Terrain``, ``TransitionOptions-struct``
`Fragments` | ``StyleImport``

### Adding Style Primitives Conditionally

You can also use conditionals to add and remove map style primitives. In the example below, `useTerrain` is a variable controlled by your code, perhaps toggled when a user selects a button or changes a setting. When true, the Style Projection is set to Globe, terrain data is added to a RasterDem source and visualized with a Terrain map content. When toggled false, the terrain source and content are removed and the project is set to Mercator. Other content on the map is not affected by this change so updates are lightweight.

@TabNavigator {
    @Tab("Swift UI") {
    ```swift
    @State var useTerrain = true

    var body: some View {
        Map {
            if useTerrain {
                StyleProjection(name: .globe)
                RasterDemSource(id: "mapbox-dem")
                    .url("mapbox://mapbox.mapbox-terrain-dem-v1")
                    .maxzoom(14.0)
                Terrain(sourceId: "mapbox-dem")
                    .exaggeration(5)
            } else {
                StyleProjection(name: .mercator)
            }
        }
    }
    ```
    }
    @Tab("UI Kit") {
    ```swift
    var useTerrain = true

    // To change your style content you should set new map primitives using
    // ``StyleManager/setMapStyleContent(content:)`` like below.
    // This will fully change the displayed style content,
    // so be sure to include all the content you want.
    func updateStyle(useTerrain: Bool) {
        mapView.mapboxMap.setMapStyleContent{
            if useTerrain {
                StyleProjection(name: .globe)
                RasterDemSource(id: "mapbox-dem")
                    .url("mapbox://mapbox.mapbox-terrain-dem-v1")
                    .maxzoom(14.0)
                Terrain(sourceId: "mapbox-dem")
                    .exaggeration(5)
            } else {
                StyleProjection(name: .mercator)
            }
        }
    }
    ```
    }
}

### Building Custom Style Primitives

You can create your own primitives in addition to Mapbox style primitives. Defining your own primitives gives you greater control over when the content is updated, and allows for cleaner organization of your code. To create a primitive, declare a new struct which conforms to ``MapStyleContent`` and add your primitives to the `body` property.

For example, the code below creates a `CarModelPrimitive` which manages all you need to display a sport care Model on your map: the ``GeoJSONSource`` for the data, the ``Model`` to display, and the ``ModelLayer`` used to position the model. Add your `CarModelPrimitive` to your style body just like Mapbox style primitives.

> Warning: We recommend not using @State or @Binding as part of your custom primitives. @State will only work as part of root view that contain ``Map``. @Binding may work in your components, but it will break content recalculation logic and will lead to worse performance.

```swift
struct CarModelPrimitive: MapStyleContent {
    var body: some MapStyleContent {
        GeoJSONSource(id: "models-geojson")
            .data(.featureCollection(carFeatureCollection))

        Model(
            id: "car",
            uri: Bundle.main.url(forResource: "sportcar", withExtension: "glb")!
        )

        ModelLayer(id: "models", source: "models-geojson")
            .modelId(Exp(.get) { "model" })
            .modelType(.common3d)
            .modelScale([40, 40, 40])
            .modelTranslation([0, 0, 0])
            .modelRotation([0, 0, 90])
            .modelOpacity(0.7)
    }
}

...

Map {
    /// other map primitives
    CarModelPrimitive()
    /// other map primitives
}
```

### Content positioning

Our aim was to establish a single source of truth for all content displayed on the map through our declarative approach. Moreover, we invested significant efforts in automating the heavy lifting of manual layer positioning, seamlessly incorporating it into the declarative description.

Essentially, this means that all layers defined in the declarative description will be positioned on the map relative to each other, following a similar pattern as [SwiftUI's ZStack](https://developer.apple.com/documentation/swiftui/zstack).

```swift
let coordinate = CLLocationCoordinate2D(latitude: 60.167488, longitude: 24.942747)

var body: some View {
    Map(initialViewport: .camera(center: .init(latitude: 27.2, longitude: -26.9), zoom: 1.53, bearing: 0, pitch: 0)) {
        MapViewAnnotation(coordinate: coordinate) {
            Circle()
                .fill(.purple)
                .frame(width: 40, height: 40)
        }

        PolygonAnnotation(polygon: Polygon(center: coordinate, radius: 8 * 100, vertices: 60))
            .fillColor(StyleColor(.yellow))


        GeoJSONSource(id: "source")
            .data(.geometry(.polygon(Polygon(center: coordinate, radius: 4 * 100, vertices: 60))))

        FillLayer(id: "fill-id", source: "source")
            .fillColor(.green)
            .fillOpacity(0.7)
    }
}
```

Referring back to the example above, the order of layers will be: [default map style layers] -> [yellow polygon] -> [green polygon]. It's worth noting that MapViewAnnotation doesn't participate in layer ordering and will always be displayed above any layers.

In contrast to the imperative API, we intentionally removed the ability to set layer positions using the `.position` modifier for `MapStyleContent`. This emphasizes that the order of layer declarations should precisely reflect the actual layer ordering. As a result, in the declarative API you cannot add runtime layers between style layers already in the Style.

So, despite the elegance of declarative ordering, there are scenarios where it falls short:

1. Placing layers between style layers that were not added at runtime.
2. Interoperability with traditional imperative APIs.
3. Slots API.

To address these scenarios, we introduced ``SlotLayer``, which slightly disrupts the elegance of declarative ordering but provides a crucial mechanism and single entry point for more advanced layer ordering cases. This ensures that the impact of this disruption to ordering remains minimal.

The following example demonstrates how ``SlotLayer`` allows the addition of runtime slots, facilitating interactions with imperative APIs and dividing existing slots into more granular groups.

```swift
mapView.mapboxMap.mapStyle = .standard
mapView.mapboxMap.setMapStyleContent {
    GeoJSONSource(id: "square-data")
        .data(.feature(Feature(geometry: square)))

    /// The MapStyleContent defines the desired layers positions.
    /// ... bottom layers ...
    /// "middle" slot
    ///    - "annotation-placeholder" slot
    ///    - "polygon" layer
    /// ... top layers layers ...
    SlotLayer(id: "annotation-placeholder")
        .slot(.middle)
    FillLayer(id: "square", source: "square-data")
        .fillColor(.systemPink)
        .fillOpacity(0.8)
        .slot(.middle)
}

/// The annotation uses slot `annotation-placeholder` so it will be rendered below the polygon:
/// ... bottom layers ...
/// "middle" slot
///    - triangle annotation
///    - "annotation-placeholder" slot
///    - "square" layer
/// ... top layers layers ...
/// If any other layers or annotations are added to the `annotation-placeholder` slot, they will appear above the triangle annotation, but below the square layer.
let manager = mapView.annotations.makePolygonAnnotationManager()
manager.slot = "annotation-placeholder"
manager.annotations = [
    PolygonAnnotation(polygon: triangle).fillColor(StyleColor(.yellow))
]

```

Another important feature of ``SlotLayer`` is that it's the only ``MapStyleContent`` component with a .position modifier, allowing developers to set a custom ``LayerPosition``. This effectively resolves the scenario where a developer needs to insert a runtime-added layer between style layers that are part of the Style JSON.
Please note that setting both `.slot()` and `.position()` for ``SlotLayer`` is incorrect and `slot` will always have priority over the `position`.

```swift
Map {
    SlotLayer(id: "below-roads")
        .position(.below("roads"))

    GeoJSONSource(id: "square-data")
        .data(.feature(Feature(geometry: square)))

    FillLayer(id: "square", source: "square-data")
        .fillColor(.systemPink)
        .slot(Slot(rawValue: "below-roads")
}
.mapStyle(.streets)
```

In the example above ``FillLayer`` will be added below "roads" layer from Mapbox Streets style.

### Performance Optimizations

Custom style primitives can be used to optimize performance for resource-heavy tasks like loading a large GeoJson. For example, you may want to load a GeoJSON of point data only if a user selects a certain setting and only update it when explicitly desired. In this case, you can add a `showPoints` variable. When toggled to true, an instance of your custom `LazyGeoJSON` struct conforming to `MapStyleContent` is added. This approach means that the features you add (in this case three points) will only be assessed for changes if the `features` reference is changed. This prevents unnecessary computation when the underlying GeoJSON data has not changed.

@TabNavigator {
    @Tab("Swift UI") {
    ```swift
    @State var showPoints = true

    var pinFeatures: FeaturesRef {
        FeaturesRef([
            Feature(geometry: .point(Point(CLLocationCoordinate2D(latitude: 51.5073219, longitude: -0.1276474)))),
            Feature(geometry: .point(Point(CLLocationCoordinate2D(latitude: 52.5170365, longitude: 13.3888599)))),
            Feature(geometry: .point(Point(CLLocationCoordinate2D(latitude: 60.167488, longitude: 24.942747)))),
        ])
    }

    var body: some View {
        Map {
            if showPoints {
                LazyGeoJSON(id: "points", features: pinFeatures)
                SymbolLayer(id: "pin", source: "points")
                    .iconImage("pin-icon")
            }
        }
    }

    ...

    struct LazyGeoJSON: MapStyleContent {
        let id: String
        let features: FeaturesRef

        var body: some MapStyleContent {
            // The body gets called and the GeoJSON source data is updated only when the `features` reference is changed.
            GeoJSONSource(id: id)
                .data(.featureCollection(FeatureCollection(features: features.features)))
        }
    }

    /// A reference wrapper over the array of features.
    class FeaturesRef {
        let features: [Feature]
        init(_ features: [Feature]) { self.features = features }
    }

    ```
    }
    @Tab("UI Kit") {
    ```swift
    var showPoints = true

    var pinFeatures: FeaturesRef {
        FeaturesRef([
            Feature(geometry: .point(Point(CLLocationCoordinate2D(latitude: 51.5073219, longitude: -0.1276474)))),
            Feature(geometry: .point(Point(CLLocationCoordinate2D(latitude: 52.5170365, longitude: 13.3888599)))),
            Feature(geometry: .point(Point(CLLocationCoordinate2D(latitude: 60.167488, longitude: 24.942747)))),
        ])
    }

    func updateStyle(useTerrain: Bool) {
        mapView.mapboxMap.setMapStyleContent {
            if showPoints {
                LazyGeoJSON(id: "points", features: pinFeatures)
                SymbolLayer(id: "pin", source: "points")
                    .iconImage("pin-icon")
            }
        }
    }

    ...

    struct LazyGeoJSON: MapStyleContent {
        let id: String
        let features: FeaturesRef

        var body: some MapStyleContent {
            // The body gets called and the GeoJSON source data is updated only when the `features` reference is changed.
            GeoJSONSource(id: id)
                .data(.featureCollection(FeatureCollection(features: features.features)))
        }
    }

    /// A reference wrapper over the array of features.
    class FeaturesRef {
        let features: [Feature]
        init(_ features: [Feature]) { self.features = features }
    }
    ```
    }
}

For a full implementation of custom style primitives, see the [DynamicStylingExample](https://github.com/mapbox/mapbox-maps-ios/blob/main/Apps/Examples/Examples/Swift%20UI%20Examples/DynamicStyleExample.swift) in our examples application.
