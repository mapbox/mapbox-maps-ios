# Map Content Gestures User Guide

Handle Tap and Long Press gestures on Map, Annotations, and Layers.

## Overview

The map can display different types of content - View Annotations, Layer Annotations, and layers. This guide will walk you through the principles of handling gestures on all of them.

## View Annotations

View annotations are the simplest case of handling map content gestures. The view annotations are native views displayed on top of the Map, which means they will handle gestures before the Map, Layers, or Layer Annotations.

In order to handle gestures on view annotations, use any `UIGestureHandler` in UIKit, or [Gestures](https://developer.apple.com/documentation/swiftui/gestures) in SwiftUI.

```swift
var body: some View {
    Map {
        MapViewAnnotation(coordinate: coordinate) {
            Text("🍔")
                .padding()
                .background(Circle().fill(.green))
                .onTapGesture {
                    print("burger is tapped") // <- View annotation handle the gesture before the Map view.
                }
        }
    }
}
```

## Layer Annotations

The Layer Annotations are rendered by Metal inside of the map content, which means the standard UIKit or SwiftUI doesn't know much about annotations inter-position. However, the Mapbox Maps SDK defines functions to react on Tap and Long Press gestures.

Let's take a look at the example below.

```swift
var body: some View {
    Map {
        let center = CLLocationCoordinate2D(latitude: 60.17195694011002, longitude: 24.945389069265598)
        let polygon = Polygon(center: center, radius: 1000, vertices: 5)
        PolygonAnnotation(polygon: polygon)
            .fillColor(StyleColor(.systemGreen))
            .fillOpacity(0.5)
            .onTapGesture {
                print("polygon is tapped")
            }
            .onLongPressGesture {
                print("polygon is long-pressed")
            }

        CircleAnnotation(centerCoordinate: center)
            .circleRadius(30)
            .circleColor(StyleColor(.systemBlue))
            .onTapGesture {
                print("circle is tapped")
            }

        // The red circle annotation doesn't handle gestures
        CircleAnnotation(centerCoordinate: CLLocationCoordinate2D(latitude: 60.18195694011002, longitude: 24.955389069265598))
            .circleRadius(30)
            .circleColor(StyleColor(.systemRed))
    }
    .onMapTapGesture { context in
        print("map is tapped")
    }
    .onMapLongPressGesture { context in
        print("map is long-pressed")
    }
}
```

![Gesture handling order](https://static-assets.mapbox.com/maps/ios/documentation/swiftui_gesture_handling_order_4.png)

The example above shows the green ``PolygonAnnotation`` and the blue ``CircleAnnotation`` above it. both of them handle the tap gesture, and polygon annotation additionally handles the long-press gesture. The red circle annotation doesn't handle any gestures.

Let's see now what happens when the user taps the map at the positions shown above.

Tap position | Printed message
--- | ---
1 | `circle is tapped`
2 | `polygon is tapped`
3 | `map is tapped`
4 | `map is tapped`

Since the Long Press gesture is only handled by the polygon annotation and the map, the following messages will be printed.

Long Press position | Printed message
--- | ---
1 or 2 | `polygon is long-pressed`
3 or 4 | `map is long-pressed`

If the gesture handler returns `false`, the gesture handling continues with the annotations or layers below it. If the handler returns `true`, the propagation stops.
In the example below, the circle annotation will handle only the first time, passing all the following taps to the polygon.

```swift
@State var circleTapHandled = false

var body: some View {
    Map {
        PolygonAnnotation(...)
            .onTapGesture {
                print("polygon is tapped")
            }
        CircleAnnotation(...)
            .onTapGesture { context in
                if !circleTapHandled {
                    circleTapHandled = true
                    print("circle is tapped")
                }
                return circleTapHandled
            }
    }
}
```

- Note:  Every gesture handler can receive the ``MapContentGestureContext`` that provides additional information about the gesture, such as point and the geographical coordinate.

## Clustered Annotations

Nearby annotations may be grouped into clusters when the user zooms out the map and Mapbox Maps SDK defines functions to conveniently react on Tap and Long Press gestures on annotation clusters.

- Note: Currently clustering is only supported for ``PointAnnotation``.

Example below shows the case where the tap gesture on the cluster is handled and cluster gets expanded by setting the corresponding zoom level.

```swift
let clusterOptions = ClusterOptions(circleRadius: .constant(10), circleColor: .constant(StyleColor(.blue)))

var body: some View {
    Map {
        PointAnnotationGroup(places) { places in
            PointAnnotation(coordinate: place.coordinate)
                .image(named: "intermediate-pin")
                .onTapGesture { places.removeAll(where: { $0.id == place.id }) }
        }
        .clusterOptions(clusterOptions)
        .onClusterTapGesture { context in
            withViewportAnimation(.easeIn(duration: 1)) {
                viewport = .camera(center: context.coordinate, zoom: context.expansionZoom)
            }
        }
    }
}
```

- Note: Annotation cluster gesture handlers receive the ``AnnotationClusterGestureContext`` that provides additional information about the gesture, such as point and the geographical coordinate and minimum expansion zoom of the cluster.

## Layers

Annotations are not the only way to show content on the map. You can use Style API via the ``StyleManager-46yjd`` to organize content in layers or use a custom [Style](https://docs.mapbox.com/style-spec/guides/) for displaying larger data sets.

In those cases, layers play a critical role in displaying content, and you can make them interactive too.

The example below shows how to assign the tap handler to the `house-prices` layer that is defined in a custom style.

```swift
var body: some View {
    Map()
        .mapStyle(.customStyle)
        .onLayerTapGesture("house-prices") { queriedFeature, context in
            displayDetails(queriedFeature, coordinate: context.coordinate)
            return true // Do not propagate the event to the layers and annotations below
        }
}

extension MapStyle {
    // The custom style that defines the "house-prices" layer.
    static let customStyle = MapStyle(uri: StyleURI(rawValue: "https://example.com/mapbox-custom-style.json")!)
}
```

The layers handlers follow the same order rule as annotations - the topmost layer will handle the gesture first.

### Handling gestures with GestureManager

The examples above use the new SwiftUI API, you can learn more about SwiftUI support in the <doc:SwiftUI-User-Guide>.

However, the same API is accessible via the ``GestureManager`` obtained from the ``MapView``.

```swift
mapView.gestures.onMapTap.observe { context in
    print("Tapped at \(context.coordinate)")
}.store(in: &cancelables)

mapView.gestures.onLayerTapGesture("house-prices") { queriedFeature, context in
    displayDetails(queriedFeature, coordinate: context.coordinate)
}.store(in: &cancelables)
```

Please consult the tale below to find the corresponding method.

``Map-swift.struct`` (SwiftUI) | ``GestureManager`` (UIKit)
--- | ---
``Map-swift.struct/onMapTapGesture(perform:)`` | ``GestureManager/onMapTap``
``Map-swift.struct/onMapLongPressGesture(perform:)`` | ``GestureManager/onMapLongPress``
``Map-swift.struct/onLayerTapGesture(_:perform:)`` | ``GestureManager/onLayerTap(_:handler:)``
``Map-swift.struct/onLayerLongPressGesture(_:perform:)`` | ``GestureManager/onLayerLongPress(_:handler:)``
