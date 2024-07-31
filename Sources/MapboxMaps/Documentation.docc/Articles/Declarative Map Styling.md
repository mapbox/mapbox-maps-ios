# Declarative Map Styling

Simplify runtime style manipulation with declarative syntax.

## Overview

Starting from version `11.4.0-beta.1` of Mapbox Maps SDK you can now use a declarative approach to add or update style primitives such as Sources, Layers, Images, and Lights at runtime. This paradigm simplifies working with all Mapbox styles at runtime and works well in SwiftUI and UIKit applications.

- Note: Declarative styling is available starting from iOS 13.

## Getting Started

In UIKit applications you can use the ``StyleManager/setMapStyleContent(content:)`` method, which is available in ``MapboxMap`` and ``Snapshotter`` instances.

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

## Styling Primitives

Style primitives are pieces of ``MapStyleContent`` that can be added, updated, and removed at runtime. These primitives represent the data sources and visualization choices for your map:

Category     | Types supported
------------ | -------------------------------------
`Source`     | ``VectorSource``, ``RasterSource``, ``RasterDemSource``, ``GeoJSONSource``, ``ImageSource``, ``Model``, ``CustomGeometrySource`` (partial), ``CustomRasterSource`` (partial)
`Layer`      | ``FillLayer``, ``LineLayer``, ``SymbolLayer``, ``CircleLayer``, ``HeatmapLayer``, ``FillExtrusionLayer``, ``RasterLayer``, ``HillshadeLayer``, ``BackgroundLayer``, ``LocationIndicatorLayer``, ``SkyLayer``, ``ModelLayer``, ``SlotLayer``, ``CustomLayer`` (partial), ``ClipLayer``, ``RasterParticleLayer``.
`Lights`     | ``FlatLight``, ``AmbientLight``, ``DirectionalLight``
`Map properties` | ``Projection``, ``Atmosphere``, ``Terrain``, ``TransitionOptions-struct``
`Fragments` | ``StyleImport``

All of them can be used inside of ``MapStyleContentBuilder`` (UIKit) or ``MapContentBuilder`` (SwiftUI). You can use declarative syntax to modify the properties of your style primitives when you add them to your map. If you update these properties the changes will be reflected on your map.

```swift
/// Create an atmosphere primitive and set properties for range, start intensity, and color
Atmosphere()
    .range(start: 0, end: 12)
    .horizonBlend(0.1)
    .starIntensity(0.2)
    .color(StyleColor(red: 240, green: 196, blue: 152, alpha: 1)!)
    .highColor(StyleColor(red: 221, green: 209, blue: 197, alpha: 1)!)
    .spaceColor(StyleColor(red: 153, green: 180, blue: 197, alpha: 1)!)
```


### Using Style Primitives Conditionally

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
        mapView.mapboxMap.setMapStyleContent {
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

    > Tip: It is totally fine to call the ``StyleManager/setMapStyleContent(content:)`` every time you need to update just a part of the content. All updates are made incrementally, meaning that elements which haven't changed won't be re-added unnecessarily. If you experience a performance issue, please refer to the <doc:Declarative-Map-Styling#Performance-Optimization> section.
    }
}


### Building Custom Style Components

You can create your own style components in addition to build-in styling primitives. Defining your own components gives you greater control over when the content is updated, and allows for cleaner organization of your code.

> Tip: If you are familiar with SwiftUI principles, the custom style components follow the same pattern.

To create a custom style component, declare a new struct which conforms to ``MapStyleContent`` and add your primitives to the ``MapStyleContent/body`` property.

```swift
/// A custom style component
struct CarModel: MapStyleContent {
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

/// Usage:
Map {
    CarModel()
}
```

The code above creates a `CarModel` component which in turn contains all primitives to display a sport care Model on your map: the ``GeoJSONSource`` for the data, the ``Model`` to display, and the ``ModelLayer`` used to position the model. Add your `CarModelPrimitive` to your style body just like Mapbox style primitives.

> Warning: We don' recommend to use `@State` or `@Binding` in your custom component. Instead, use `@State` in the SwiftUI views and pass data to custom components as properties.

## Content positioning

One of the most important properties of declarative styling is stable content ordering. Essentially, this means that all layers defined in the declarative description will be positioned on the map relative to each other, following a similar pattern as [SwiftUI's ZStack](https://developer.apple.com/documentation/swiftui/zstack).

```swift
let coordinate = CLLocationCoordinate2D(latitude: 60.167488, longitude: 24.942747)

var body: some View {
    Map(initialViewport: .camera(center: .init(latitude: 27.2, longitude: -26.9), zoom: 1.53, bearing: 0, pitch: 0)) {
        MapViewAnnotation(coordinate: coordinate) {
            Circle()
                .fill(.purple)
                .frame(width: 40, height: 40)
        }

        if showYellowPolygon {
            PolygonAnnotation(polygon: Polygon(center: coordinate, radius: 8 * 100, vertices: 60))
                .fillColor(StyleColor(.yellow))
        }


        GeoJSONSource(id: "source")
            .data(.geometry(.polygon(Polygon(center: coordinate, radius: 4 * 100, vertices: 60))))

        /// The green polygon is displayed on top of the yellow polygon.
        FillLayer(id: "green", source: "source")
            .fillColor(.green)
            .fillOpacity(0.7)
    }
}
```

In the example above, the position will be the following:
```
Basemap (Standard Style layers) <-- bottom
Yellow polygon
Green Polygon
Purple circle <-- top
```

The purple circle displayed on top of all content because View Annotations are always rendered on top of the ``Map`` view.  The yellow polygon is always displayed below the green one, even if the `showYellowPolygon` property was toggled.

In the declarative API there's no ``LayerPosition`` to override the positioning. Instead, use new ``SlotLayer`` and ``Slot`` constants to have a finer control.

For example, the Standard Style is shipped with pre-defined slots, such as ``Slot/middle``:
```swift
Map {
    /// The green polygon is displayd in the middle of Standard Style layers.
    FillLayer(id: "green", source: "green-source")
        .fillColor(.green)
        .slot(.middle)

    /// By default, this layer id displayed on top of other layers.
    FillLayer(id: "purple", source: "purple-source")
        .fillColor(.purple)
}
```

Using the custom slots let you alter the ordering:

```swift
Map {
    SlotLayer(id: "my-custom-slot")

    FillLayer(id: "green", source: "green-source")
        .fillColor(.green)

    FillLayer(id: "purple", source: "purple-source")
        .fillColor(.purple)
        .slot("my-custom-slot")
}
```

In the example above, the purple layer will be displayed below the green one, because it is assigned to the custom `my-custom-slot` that comes before the green polygon.

In general, the ordering rule is as follows:
1. First, the slot matters the most. All layers on the map are ordered by their slot position.
2. If there is more than one layer in the slot, they are ordered following the order in the code.

### Using Layer Position

In some rare use-cases you may want to use ``LayerPosition`` with declarative styling. The ``SlotLayer`` is the only layer that has layer position in the declarative styling API. This effectively resolves the scenario where you need to insert a runtime-added layer between style layers that are part of the Style JSON.
Please note that setting both ``SlotLayer/slot(_:)`` and ``SlotLayer/position(_:)`` in `SlotLayer` is incorrect and the `slot` will always have priority over the `position`.

```swift
Map {
    /// The "roads" layer id comes from the Streets Style.
    SlotLayer(id: "below-roads")
        .position(.below("roads"))

    FillLayer(id: "square", source: "square-data")
        .fillColor(.systemPink)
        .slot(Slot(rawValue: "below-roads")
}
.mapStyle(.streets)
```

In the example above the ``FillLayer`` will be placed below the `roads` layer from the Streets Style.

## Performance Optimization

To achieve the best performance, it is recommended to use custom components of ``MapStyleContent`` or ``MapContent`` to isolate components updates.

This is because whenever you update the ``MapStyleContent`` (via ``StyleManager/setMapStyleContent(content:)``) or ``MapContent`` (via SwiftUI `@State` change) internally the full content tree must be compared with its previous version to perform the most efficient update. Having a larger tree of components instead a flat list makes internal caching to be more efficient.

This is very important if you use a large json arrays inside of styling primitives. Lets consider the following example:


```swift
struct MyView: View {
    @State var features: FeatureCollection?
    @State var counter = 0

    var body: some View {
        Map {
            if let features {
                LineLayer(id: "route", source: "route-source")
                GeoJSONSource(id: "route-source")
                    /// WARNING: This code may be not optimal for large feature collection.
                    .data(.featureCollection(features))
            }
        }
        .onAppear {
            features = loadHeavyGeojson()
        }
        Button("Trigger update \(counter)") {
            /// Counter updates here will trigger the `body` re-evaluation. This in turn
            /// triggers the Map update that need to check if the `features` are changed.
            /// This may be a costly operation.
            counter += 1
        }
    }
}
```

This code may not be optimal, because on every `View.body` re-evaluation, the large feature set needs to be re-evaluated too.

To optimize it, create a custom component that will consume data by a reference type instead. In the example below, the `RouteComponent.body` will be re-evaluated only when the actual `RouteData` object is changed. If only the `counter` is updated, the large route JSON won't be re-evaluated.

```swift
struct MyView: View {
    /// A simple reference wrapper around FeatureCollection.
    private class RouteData {
        let features: FeatureCollection
        init(features: FeatureCollection) { self.features = features }
    }

    /// A custom route component that renders the line layer and creates the data source for it.
    private struct RouteComponent: MapContent {
        /// The `body` is called only when component's properties are changed.
        /// In this case the `route` is a reference type, which guarantees the fast equality check.
        let route: RouteData

        var body: some MapContent {
            LineLayer(id: "route", source: "route-source")
            GeoJSONSource(id: "route-source")
                .data(.featureCollection(route.features))
        }
    }

    @State private var routeData: RouteData?
    @State private var counter = 0

    var body: some View {
        Map {
            if let routeData {
                RouteComponent(route: routeData)
            }
        }
        .onAppear {
            routeData = RouteData(features: loadHeavyGeojson())
        }

        Button("Trigger update \(counter)") {
            /// Update of the counter state won't trigger the RouteComponent.body evaluation because
            /// routeData points to the same data.
            counter += 1
        }

        Button("Update the route") {
            /// This will correctly update the rendered route, only once.
            routeData = RouteData(features: loadANewVersionOfRoute())
        }
    }
}
```

For reference, see the [DynamicStylingExample](https://github.com/mapbox/mapbox-maps-ios/blob/main/Apps/Examples/Examples/Swift%20UI%20Examples/DynamicStyleExample.swift) in the Examples application.
