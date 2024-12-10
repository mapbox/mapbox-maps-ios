# SwiftUI User Guide

Use Mapbox Maps in SwiftUI applications.

## Overview

The Mapbox Maps SDK has a complete support of SwiftUI. This guide demonstrates how to easily integrate Mapbox Maps into your SwiftUI application.

You can find working [SwiftUI examples](https://github.com/mapbox/mapbox-maps-ios/tree/main/Sources/Examples/SwiftUI%20Examples) in the [Examples](https://github.com/mapbox/mapbox-maps-ios/tree/main/Sources/Examples) application.

### Feature support

The SwiftUI ``Map-swift.struct`` is built on top of the existing ``MapView``, which brings the full power of Mapbox Maps SDK to the SwiftUI applications.

However, not every single API is exposed in SwiftUI, you can track the progress in the table below.

Feature | Status | Note
--- | --- | ---
Viewport & Camera | ✅
View Annotations | ✅
Layer Annotations | ✅ | `isDraggable`, `isSelected` are not supported
Annotations Clustering | ✅ |
View Annotations | ✅ |
Puck 2D/3D | ✅
Map Events | ✅
Gesture Configuration | ✅
Ornaments Configuration | ✅
Style API | ✅ | Check out the <doc:Declarative-Map-Styling> user guide.
Custom Camera Animations | 🚧

### Getting started

To start using Mapbox Map in SwiftUI you need to import `SwiftUI` and  `MapboxMaps`.

```swift
import SwiftUI
import MapboxMaps
```

Then you can use ``Map-swift.struct`` to display map content.

```swift
struct ContentView: View {
    init() {
        MapboxOptions.accessToken = "pk..."
    }
    var body: some View {
        Map()
          .ignoresSafeArea()
    }
}
```

Please note, that you have to set the Mapbox Access Token at any time before using the ``Map-swift.struct``. You can do it either by setting `MapboxOptions.accessToken` or any option listed in <doc:Migrate-to-v11##26-Access-Token-and-Map-Options-management>.

## Tutorials

### Setting Map style

By default the map uses the new ``MapStyle/standard`` style which brings rich 3D visualization. But you can use ``Map-swift.struct/mapStyle(_:)`` to set any other style.

```swift
Map()
  .mapStyle(.streets) // Sets Mapbox Streets Style.
```

With the Standard style you can set the lightPresets of the style according to your application's `colorScheme`. Light presents are 4 time-of-day states (`dawn`, `day`, `dusk`, `night`) that set the lighting and shadows of the map to represent changes in daylight.

```swift
struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        Map()
            .mapStyle(.standard(lightPreset: colorScheme == .light ? .day : .dusk))
    }
}
```

Also, you always can use your custom Mapbox Styles built with [Mapbox Studio](https://studio.mapbox.com/).

```swift
Map()
    .mapStyle(.myCustomStyle)

extension MapStyle {
  static let myCustomStyle = MapStyle(uri: StyleURI(rawValue: "mapbox://...")!)
}
```

Please consult the ``MapStyle`` documentation to find more information about style loading.

### Declarative Map Styling

With the advent of Declarative Map Styling, it's now feasible to reuse ``MapStyleContent`` components within SwiftUI, offering a robust and exhaustive method to delineate map content comprehensively in one place.

The following example illustrates the utilization of both ``MapStyleContent``, which can also be utilized outside of SwiftUI, and SwiftUI-specific ``MapContent`` within a singular declarative ``Map`` description:

```swift
Map(initialViewport: .camera(center: .init(latitude: 27.2, longitude: -26.9), zoom: 1.53, bearing: 0, pitch: 0)) {
    MapViewAnnotation(coordinate: .apple) {
        Circle()
            .fill(.purple)
            .frame(width: 40, height: 40)
    }

     PolygonAnnotation(polygon: Polygon(center: .apple, radius: 8 * 100, vertices: 60))
        .fillColor(StyleColor(.yellow))


    GeoJSONSource(id: "source")
        .data(.geometry(.polygon(Polygon(center: .apple, radius: 4 * 100, vertices: 60))))

    FillLayer(id: "fill-id", source: "source")
        .fillColor(.green)
        .fillOpacity(0.7)
}
```

Within SwiftUI, all ``MapStyleContent`` elements will be retained during style reloads and appropriately re-added. This ensures that the sole source of truth for map content lies within the declaration itself. SwiftUI's ``MapContent`` serves as an extension of the Declarative Map Styling approach previously introduced for the UIKit API. Therefore, it's advisable to peruse the <doc:Declarative-Map-Styling> guide to become acquainted with the underlying concepts of this declarative styling paradigm.

### Using Viewport to manage camera

``Viewport`` is a powerful abstraction that manages the camera in SwiftUI. It supports multiple modes, such as `camera`, `overview`, `followPuck`, and others.

For example, with ``Viewport/camera(center:anchor:zoom:bearing:pitch:)`` you can set the camera parameters directly to the map.

```swift
let london = CLLocationCoordinate2D(latitude: 51.5073219, longitude: -0.1276474)
// Sets camera centered to London
Map(initialViewport: .camera(center: london, zoom: 12, bearing: 0, pitch: 0)
```

The `initialViewport` in the example above means that viewport will be set only on map initialization. If the user drags the map, it won't be possible to set the viewport again. In contrast, the example below uses `@State` variable via two-way data binding. With this approach, the viewport can be set and re-set whenever necessary. The approach you should use depends on your particular use case.

```swift
struct ContentView: View {
    // Initializes viewport state as styleDefault,
    // which will use the default camera for the current style.
    @State var viewport: Viewport = .styleDefault

    var body: some View {
        VStack {
            // Passes the viewport binding to the map.
            Map(viewport: $viewport)
            Button("Overview route") {
                // Sets the viewport to overview (fit) the route, or any other geometry.
                viewport = .overview(geometry: LineString(...))
            }
            Button("Locate the user") {
                // Sets viewport to follow the user location.
                viewport = .followPuck(zoom: 16, pitch: 60)
            }
        }
    }
}
```

When the user drags the map, the viewport always resets to ``Viewport/idle`` state. You can't read the actual current camera state from that viewport, but you can observe it via ``Map-swift.struct/onCameraChanged(action:)``.

- Important: It's not recommended to store the camera values received from ``Map-swift.struct/onCameraChanged(action:)`` in `@State` property. They come with high frequency, which may lead to unwanted `body` re-execution and high CPU consumption. It's better to store them in model, or throttle before setting them to @State.


### Viewport animations

The viewport changes can be animated using the ``withViewportAnimation(_:body:completion:)`` function.

```swift
struct ContentView: View {
    @State var viewport: Viewport = .styleDefault


    var body: some View {
        VStack {
            Map(viewport: $viewport)
            Button("Animate viewport") {
                // Changes viewport with default animation
                withViewportAnimation {
                    viewport = .followPuck
                }
            }
            Button("Animate viewport (ease-in)") {
                // Changes viewport with ease-in animation
                withViewportAnimation(.easeIn(duration: 1)) {
                    viewport = .followPuck
                }
            }
        }
    }
}
```

Please consult the ``ViewportAnimation`` documentation to learn more about supported animations.

- Important: It's recommended to use ``ViewportAnimation/default(maxDuration:)`` animation when transition to ``Viewport/followPuck(zoom:bearing:pitch:)`` state. With other animation types, there might be a jump when animation finishes. It may happen because they're designed to finish at the static target.


### Annotations

There are two kinds of annotations in Maps SDK - View Annotations (``MapViewAnnotation``) and Layer Annotations (a.k.a ``PointAnnotation``, ``CircleAnnotation``, etc).

#### View Annotations

View annotation allow you to display any SwiftUI view on top of the map. They give you endless possibility for customization, but may be less performant. Also, they are always displayed above all map content, you cannot place them in between map layers.

The example below displays multiple view annotations.

```swift
struct ContentView: View {
    struct Item: Identifiable {...}
    @state var items = [Item]()

    var body: some View {
        Map {
            // Displays a single view annotation at specified coordinate.
            MapViewAnnotation(coordinate: CLLocationCoordinate(...))
                Text("🚀")
                    .frame(width: 20, height: 20)
                    .background(Circle().fill(.red))
            }

            // Displays multiple data-driven view annotations.
            ForEvery(items) { item in
                MapViewAnnotation(coordinate: item.coordinate) {
                    ItemContentView(item)
                }
            }

            // Displays annotation on the layer feature.
            // The annotation will be dynamically positioned along the route line
            // that is displayed by "route" layer.
            MapViewAnnotation(layerId: "route") {
                ETAView(text: "55 min")
            }
        }
    }
}
```

- Note: The ``ForEvery`` in the above example is similar to `ForEach` in SwiftUI, but works with Map content.

All View annotations may be configured via modifier functions (see ``MapViewAnnotation`` for the full list):

```swift
MapViewAnnotation(coordinate: CLLocationCoordinate(...))
    Text("🚀")
        .frame(width: 20, height: 20)
        .background(Circle().fill(.red))
}
.allowOverlap(true) // will overlap with outer annotations
.variableAnchors([
    ViewAnnotationAnchorConfig(anchor: .bottom) // Anchor will be at the bottom
])
```

#### Layer Annotations

Layer annotations are rendered natively in the map using layers. They can be placed in between map layers, support clustering (for ``PointAnnotation``s only) and are usually more performant.

The example below displays different types of layer annotations.

```swift
struct ContentView: View {
    struct Item {...}
    @state var items = [Item]()

    var body: some View {
        Map {
            /// Displays a polygon annotation
            let polygon = Polygon(...)
            PolygonAnnotation(polygon: polygon)
                .fillColor(StyleColor(.systemBlue))
                .fillOpacity(0.5)
                .fillOutlineColor(StyleColor(.black))
                .onTapGesture {
                    print("Polygon is tapped")
                }

            /// Displays a single point annotation
            PointAnnotation(...)

            /// Displays data-driven group of point annotations.
            PointAnnotationGroup(items, id: \.id) { item in
                PointAnnotation(coordinate: item.coordinate)
                    .image(named: "dest-pin")
                    .iconAnchor(.bottom)
            }
            .clusterOptions(ClusterOptions(...))
        }
    }
```

In example above you can see that `PointAnnotation` (and other types of layer annotations) can be placed alone, or by using an annotation group, such as ``PointAnnotationGroup``.

The first method is a handy way to place only one annotation of its kind. The second is better for multiple annotations and gives more configuration options such as clustering, layer position, and more. Annotation groups also behave like ``ForEvery`` for layer annotations.

### Displaying user position

The Puck allows you to display the user position on the map. The puck can be 2D or 3D.

The example below displays the user position using 2D puck.

```swift
Map {
    Puck2D(bearing: .heading)
        .showsAccuracyRing(true)
}
```

The example below displays the user position using custom 3D model.

```swift
Map {
    let duck = Model(
        uri: URL(string: "https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/Duck/glTF-Embedded/Duck.gltf")!,
        orientation: [0, 0, -90])
    Puck3D(model: duck, bearing: .heading)
}
```

- Note: If you add multiple pucks into one map, only the last one will be displayed.

### Direct access to the underlying map implementation.

If some API is not yet exposed in SwiftUI, you can use ``MapReader`` to access the underlying map implementation.

```swift
var body: some View {
    MapReader { proxy in
        Map()
            .onAppear {
                configureUnderlyingMap(proxy.map)
            }
    }
}
```

We welcome your feedback on the SwiftUI support. If you have any questions or comments please open an [issue in the Mapbox Maps SDK repo](https://github.com/mapbox/mapbox-maps-ios/issues) and add the `SwiftUI` label.
