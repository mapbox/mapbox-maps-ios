# Featuresets and Interactions

The experimental Interactions API.

## Overview

The new Interactions API is a toolset that allows you to handle interactions on both layers and basemap features.

When ``Interaction`` is added to the map, it uses a universal ``FeaturesetDescriptor-struct`` to specify which elements of the map it is added to. The descriptor can target either a layer or one of the featuresets.

The Featureset is a new concept that allows Evolving Basemap styles, such as Standard, to export an abstract set of features, such as POI, buildings, and place labels, regardless of which layers they are rendered on.

If an `Interaction` is added to the map without a descriptor, it will handle all interactions that didn't hit any features.

@TabNavigator {
    @Tab("Swift UI") {
    ```swift
    @_spi(Experimental) import MapboxMaps

    Map {
        SymbolLayer(id: "demo-layer", source: "demo-source")

        TapInteraction(.layer("demo-layer")) { feature, context in
            // Handle tap on the feature
            return true // Stops propagation to features below or the map.
        }

        TapInteraction(.standardPoi) { feature, context in
            // Handle tap on "poi" featureset coming from the Standard Style.
            // This featureset will work only when Standard Style is loaded.
            return true // Stops propagation to features below or the map.
        }

        TapInteraction { context in
            // Handle taps, that didn't hit any features.
            return true
        }
    }
    // Currently the featuresets are only available in experimental version of Standard Style for preview.
    // Don't use it in production.
    .mapStyle(.standardExperimental)
    ```
    }
    @Tab("UI Kit") {
    ```swift
    @_spi(Experimental) import MapboxMaps

    let mapView = MapView()
    mapView.mapboxMap.setMapStyleContent {
        SymbolLayer(id: "demo-layer", source: "demo-source")
    }
    // Currently the featuresets are only available in experimental version of Standard Style for preview.
    // Don't use it in production.
    mapView.mapboxMap.mapStyle = .standardExperimental

    mapView.mapboxMap.addInteraction(TapInteraction(.layer("demo-layer")) { feature, context in
        // Handle tap on the feature
        return true // Stops propagation to features below or the map.
    })

    mapView.mapboxMap.addInteraction(TapInteraction(.standardPoi) { feature, context in
        // Handle tap on "poi" featureset coming from the Standard Style.
        // This featureset will work only when Standard Style is loaded.
        return true // Stops propagation to features below or the map.
    })

    mapView.mapboxMap.addInteraction(TapInteraction { context in
        // Handle taps, that didn't hit any features.
        return true
    })
    ```
    }
}

When handling the interaction on a feature, you usually need to change its appearance. This can be achieved via the Feature States API. A feature state is an additional object attached to a feature that the layer definition can [use for styling](https://docs.mapbox.com/style-spec/reference/expressions/#feature-state).

The featuresets defined in Standard Style implement some of the states out of the box. The example below demonstrates how to use ``StandardPoiFeature/State`` and ``StandardBuildingsFeature/State`` with ``FeatureState`` to change the feature appearance when it's selected.

```swift
/// SwiftUI
struct InteractionsExample: View {
    @State var selectedPoi: StandardPoiFeature?
    @State var selectedBuilding: StandardBuildingsFeature?

    var body: some View {
        Map {
            // Select the POI when tapped.
            TapInteraction(.standardPoi) { poi, context in
                selectedPoi = poi
                return true
            }

            // Select the building when tapped.
            LongPressInteraction(.standardBuildings) { building, context in
                selectedBuilding = building
                return true
            }

            if let selectedPoi {
                // Sets the `hide` state to true `when` the poi is selected
                FeatureState(selectedPoi, StandardPoiFeature.State(hide: true))

                // Displays a view annotation on top
                MapViewAnnotation(coordinate: selectedPoi.coordinate) {
                    CustomMarker(name: selectedPoi.name)
                }
            }

            if let selectedBuilding {
                // Sets the `select` state to `true` when building is selected.
                // This will paint the building into a vibrant color.
                FeatureState(selectedBuilding, .init(select: true))
            }
        }
        // Currently the featuresets are only available in experimental version of Standard Style for preview.
        // Don't use it in production.
        .mapStyle(.standardExperimental)
    }
}
```

In UIKit applications, use ``MapboxMap/setFeatureState(_:state:callback:)`` and ``MapboxMap/removeFeatureState(_:stateKey:callback:)`` to set and remove states.

## Topics

### Interaction types
- ``Interaction``
- ``TapInteraction``
- ``LongPressInteraction``

### Featuresets
- ``FeaturesetDescriptor-struct``
- ``FeaturesetFeatureId``
- ``FeaturesetQueryTarget``

### Feature types
- ``FeaturesetFeatureType``
- ``FeaturesetFeature``
- ``StandardPoiFeature``
- ``StandardPlaceLabelsFeature``
- ``StandardBuildingsFeature``
