# Work with visionOS

Use Mapbox Maps in native applications for Apple Vision Pro.

## Overview

Starting from version `11.2.0-beta.1` of Mapbox Maps, you can use the Mapbox Maps SDK in your native application for Apple Vision Pro. Check out the code samples in our [Examples](https://github.com/mapbox/mapbox-maps-ios/tree/main/Apps/Examples) application on visionOS.

![Standard Style on visionOS](https://static-assets.mapbox.com/maps/ios/documentation/maps_vision_os_locations.png)

- Note: Currently, visionOS is not supported in CocoaPods. Please use SPM or the binary [distribution](https://docs.mapbox.com/ios/maps/guides/install/) of MapboxMaps.

### Make use of Mapbox Maps on visionOS

Working with Mapbox Maps on visionOS is very similar to iOS. As the entry point to the map, you use ``Map`` if your application uses SwiftUI, and ``MapView`` if the application uses UIKit. You can find more information about SwiftUI support in <doc:SwiftUI-User-Guide>.

Most of the Maps SDK's features from iOS are supported on visionOS out-of-the-box. However, there are some platform limitations discussed below.

### Limitations

#### Eye tracking feedback

All the interactive UI elements on vision OS are expected to have visual feedback when the user looks at them. Currently, this effect is only available for native views and can be applied with [hoverEffect](https://developer.apple.com/documentation/swiftui/view/hovereffect(_:)). Mapbox Map renders most of the map content in Metal, which means the hover won't be available for map symbols, lines, polygons, and others. However, you can use [view annotations](https://docs.mapbox.com/ios/maps/guides/annotations/view-annotations/) to place interactive elements onto the map.

```swift
Map {
    // With point annotations you can handle gestures, but you won't receive visual eye-tracking feedback.
    PointAnnotation(coordinate: coordinate1)
        .onTapGesture {
            print("point annotation tapped")
        }

    // With view annotations, you can handle gestures and receive visual feedback.
    MapViewAnnotation(coordinate: coordinate2) {
        Circle()
            .fill(.blue)
            .hoverEffect()
            .onTapGesture {
                print("view annotation tapped")
            }
    }
}
```

#### Location services

The compass data is not available on the platform, which means if you use ``PuckBearing/heading`` as a puck bearing source, the user location puck will point to the north.

To fix that you can disable puck heading.

```swift
Map {
    Puck2D() // By default, puck doesn't use heading and doesn't draw direction pointer.
}
```

Alternatively, you can use you own implementation of heading provider.

```swift
struct PuckDemo: View {
    class LocationModel: ObservableObject {
        var locationProvider = AppleLocationProvider()

        // A custom heading data
        @Published var heading: Heading = .init(direction: 15, accuracy: 1)
    }

    @StateObject var model = LocationModel()

    var body: some View {
        MapReader { proxy in
            Map(initialViewport: .followPuck(zoom: 16, pitch: 0)) {
                Puck2D(bearing: .heading)
            }
            .onAppear {
                proxy.location?.override(
                    locationProvider: model.locationProvider.onLocationUpdate,
                    headingProvider: model.$heading.eraseToSignal())
            }

        }
    }
}
```
