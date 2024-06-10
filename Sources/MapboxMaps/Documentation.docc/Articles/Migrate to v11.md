# Migrate to v11 from v10

The Mapbox Maps SDK v11 introduces improvements to how Mapbox works on iOS platforms, as well as changes to how developers use the SDK. This document summarizes the most important changes - such as new features, deprecated APIs, and breaking changes - and walks you through how to upgrade an application using v10 of the Mapbox Maps SDK to v11.

## Version Compatibility

| Version | Xcode Version | Swift Version | iOS Version |
|---------|---------------|---------------|-------------|
| 11.0.0  | 14.1+         | 5.7.1+        | 12+         |

## 1. Update Dependencies

Update your app's dependencies to use versions 11+ of the Mapbox Maps SDK for iOS. We distribute the SDK through Swift Package Manager (SPM), CocoaPods, and Direct Download. Full instructions are found [here](https://docs.mapbox.com/ios/maps/guides/install/).

## 2. Explore New Features

### 2.1 The Mapbox Standard Style

We're excited to announce the launch of Mapbox Standard, our latest Mapbox style, now accessible to all customers in a beta version. The new Mapbox Standard core style enables a highly performant and elegant 3D mapping experience with powerful dynamic lighting capabilities, landmark 3D buildings, and an expertly crafted symbolic aesthetic. With Mapbox Standard, we are also introducing a new paradigm for how to interact with map styles based around style importing (see below section for more details).

To set Mapbox Standard as the style for your map in v11 you can use the same ``StyleURI`` convenience variables from v10 like below. Mapbox Standard is the new default style, so not setting a ``StyleManager/styleURI`` means your map will use Mapbox Standard.

```swift
let mapView = MapView()
mapView.mapboxMap.styleURI = .standard
```

The Mapbox Standard style features 4 light presets: `day`, `dusk`, `dawn`, and `night`. The style light preset can be changed from the default, `day`, to another preset with a single line of code. Here you identify which imported style (`basemap`) you want to change the `lightPresent` config on, as well as the value (`dusk`) you want to change it to.


```swift
mapView.mapboxMap.setStyleImportConfigProperty(for: "basemap", config: "lightPreset", value: "dusk")
```

Changing the light preset will alter the colors and shadows on your map to reflect the time of day. For more information, check out the New 3D Lighting API section.

Similarly, you can set other configuration properties on the Standard style such as showing POIs, place labels, or specific fonts:

```swift
mapView.mapboxMap.setStyleImportConfigProperty(for: "basemap", config: "showPointOfInterestLabels", value: false)
```

The Standard style offers 6 configuration properties for developers to change when they import it into their own style:

Property | Type | Description
--- | --- | ---
`showPlaceLabels` | `Bool` | Shows and hides place label layers.
`showRoadLabels` | `Bool` | Shows and hides all road labels, including road shields.
`showPointOfInterestLabels` | `Bool` | Shows or hides all POI icons and text.
`showTransitLabels` | `Bool` | Shows or hides all transit icons and text.
`lightPreset` | `String` | Switches between 4 time-of-day states: `dusk`, `dawn`, `day`, and `night`.
`font` | `Array` | Defines font family for the style from predefined options.

Mapbox Standard is making adding your own data layers easier for you through the concept of `slot`s. `Slot`s are pre-specified locations in the style where your layer will be added to (such as on top of existing land layers, but below all labels). To do this, we've added a new `slot` property to each `Layer`. This property allows you to identify which `slot` in the Mapbox Standard your new layer should be placed in. To add custom layers in the appropriate location in the Standard style layer stack, we added 3 carefully designed slots that you can leverage to place your layer. These slots will remain stable, so you can be sure that your own map won't break even as the basemap evolves automatically.

Slot | Description
--- | ---
`bottom` | Above polygons (land, landuse, water, etc.)
`middle` | Above lines (roads, etc.) and behind 3D buildings
`top` | Above POI labels and behind Place and Transit labels
not specified | Above all existing layers in the style

```swift
var layer = LineLayer(id: "line-layer", source: "line-source")
layer.slot = .middle
mapView.mapboxMap.addLayer(layer)
```

- Important: For the new Standard style, you can only add layers to these three slots (`bottom`, `middle`, `top`) within the Standard style basemap.

Similar to the classic Mapbox styles, you can still use the layer position in ``StyleManager/addLayer(_:layerPosition:)`` method when importing the Standard Style. However, this method is only applicable to custom layers you have added yourself. If you add two layers to the same slot with a specified layer position the latter will define the order of the layers in that slot.

Standard is aware of the map lighting configuration using the `measure-light` expression, which returns you an aggregated value of your light settings. This returns a value which ranges from 0 (darkest) to 1 (brightest). In darker lights, you make the individual layers light up by using the new `*-emissive-stength` expressions, which allow you to add emissive light to different layer types and for example keep texts legible in all light settings. If your custom layers seem too dark, try adjusting the emissive strength of these layers.

### Customizing Standard

The underlying design paradigm to the Standard style is different from what you know from the classic core styles. Mapbox manages the basemap experience and surfaces key global styling configurations - in return, you get a cohesive visual experience and an evergreen map, always featuring the latest data, styling and rendering features compatible with your SDK. The configuration options make interactions with the basemap simpler than before. During the beta phase, we are piloting these configurations - we welcome feedback on the beta configurations. If you have feedback or questions about the Standard beta style reach out to: [hey-map-design@mapbox.com](mailto:hey-map-design@mapbox.com).

You can customize the overall color of your Standard experience easily by adjusting the 3D light settings. Individual basemap layers and/or color values can’t be adjusted, but all the flexibility offered by the style specification can be applied to custom layers while keeping interaction with the basemap simple through `slot`s.

#### 2.1.1 Style Imports

To work with styles like Mapbox Standard, we've introduced new Style APIs that allow you to import other styles into the main style you display to your users. These styles will be imported by reference, so updates to them will be reflected in your main style without additional work needed on your side. For example, imagine you have style A and style B. The Style API will allow you to import A into B. Upon importing, you can set configurations that apply to A and adjust them at runtime. The configuration properties for the imported style A will depend on what the creator of style A chooses to be configurable. For the Standard style, 6 configuration properties are available for setting lighting, fonts, and label display options (see The Mapbox Standard Style section above).

To import a style, you should add an "imports" section to your [Style JSON](https://docs.mapbox.com/help/glossary/style/). In the above example, you would add this "imports" section to your Style JSON for B to import style A and set various configurations such as `Montserrat` for the `font` and `dusk` for the `lightPreset`.

```
...
"imports": [
    {
        "id": "A",
        "url": "STYLE_URL_FOR_A",
        "config": {
            "font": "Montserrat",
            "lightPreset": "dusk",
            "showPointOfInterestLabels": true,
            "showTransitLabels": false,
            "showPlaceLabels": true,
            "showRoadLabels": false
        }
    }
],
...
```

For a full example of importing a style, please check out our [Standard Style Example](https://github.com/mapbox/mapbox-maps-ios/blob/main/Apps/Examples/Examples/All%20Examples/StandardStyleExample.swift). This example imports the Standard style into another style [Real Estate New York](https://github.com/mapbox/mapbox-maps-ios/blob/main/Apps/Examples/Examples/All%20Examples/Sample%20Data/fragment-realestate-NY.json). It then modifies the configurations for the imported Standard style at runtime using the following APIs we've introduced on the ``StyleManager-46yjd`` object:

- ``StyleManager/styleImports``, which returns all of the styles you have imported into your main style
- ``StyleManager/removeStyleImport(for:)``, which removes the style import with the passed Id
- ``StyleManager/getStyleImportSchema(for:)``, which returns the full schema describing the style import with the passed Id
- ``StyleManager/getStyleImportConfigProperties(for:)``, which returns all of the configuration properties of the style import with the passed Id
- ``StyleManager/getStyleImportConfigProperty(for:config:)``, which returns the specified configuration property of the style import with the passed Id
- ``StyleManager/setStyleImportConfigProperties(for:configs:)``, which sets all of the configuration properties of the style import with the passed Id
- ``StyleManager/setStyleImportConfigProperty(for:config:value:)``, which sets the specified configuration property of the style import with the passed Id

In addition to modifying the configuration properties of the imported styles, you can add your own layers to the imported style through the concept of `slot`s. `Slot`s are pre-specified locations in the imported style where your layer will be added to (such as on top of existing land layers, but below all labels). To do this, we've added a new `slot` property to each ``Layer``. This property allows you to identify which `slot` in the imported style your new layer should be placed in.

```swift
var layer = LineLayer(id: "line-layer", source: "line-source")
layer.slot = .middle
mapView.mapboxMap.addLayer(layer)
```

### 2.2 SwiftUI support

We're excited to announce the launch of SwiftUI support in Mapbox Maps SDK. SwiftUI makes it even easier to integrate Mapbox Maps in your application.

**v11:**

```swift
import SwiftUI
@_spi(Experimental) import MapboxMaps

struct ContentView: View {
    var body: some View {
        Map()
          .ignoresSafeArea()
    }
}
```

For more details, please read the <doc:SwiftUI-User-Guide>.

### 2.3 Type-safe Events API

The events lifecycle reporting for ``MapboxMap`` and ``Snapshotter`` have been reworked. The new event system is serialization-free, which brings more type safety and eliminates possible deserialization errors that could take place in v10 MapboxMaps SDK.

As a bonus, this new type system supports the `Combine` framework out-of-the box.

**v10:**

```swift
// Observe every camera change
mapView.mapboxMap.onEvery(.cameraChange) { [weak self] _ in
    guard let self = self else { return }
    self.handleCameraChange(self.mapView.mapboxMap.cameraState)
}

// Observe only the next style loading event
mapView.mapboxMap.onNext(event: .styleLoaded) { [weak self] _ in
    self?.setupStyle()
}
```

**v11:**

```swift
var cancelables = Set<AnyCancelable>()

// Observe every camera change
mapView.mapboxMap.onCameraChanged.observe { [weak self] event in
    self?.handleCameraChange(event.cameraState)
}.store(in: &cancelables)

// Observe only the next style loading event
mapView.mapboxMap.onStyleLoaded.observeNext { [weak self] _ in
  self?.setupStyle()
}.store(in: &cancelables)
```

The new event endpoints such as ``MapboxMap/onCameraChanged`` are exposed as ``Signal``s that allow you to observe any events over time. While you are interested in receiving updates corresponding to these events you simply store the cancelation tokens returned from ``Signal/observe(_:)`` or ``Signal/observeNext(_:)`` methods. When the token is deallocated, the subscription will be automatically canceled and you will stop receiving updates.

Additionally, ``Signal`` implements `Combine.Publisher`, so Combine usage in iOS 13+ targets is recommended:

**v11:**

```swift
mapboxMap.onCameraChanged
    .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
    .map(\.cameraState)
    .sink { [weak self] cameraState in
        self?.handleCameraChange(cameraState)
    }.store(in: &cancellables)
```

Following these changes, methods `MapboxMap.onEvery`, `MapboxMap.onNext`, `Snapshotter.onEvery`, `Snapshotter.onNext` have been deprecated while methods `MapboxMap.observe` and `Snapshotter.observe` have been removed.

### 2.4 New View Annotations API

We introduce support for Dynamic View Annotations that automatically position themselves at any geometry (`Point`, `Polyline`, or `Polygon`). For example, you can visualize ETA labels attached to the route line that is rendered by ``LineLayer``.

To make View Annotations simpler to use, we introduce new ``ViewAnnotation`` object, that helps create an annotation from any UIView:

**v11**
```swift
// Create annotation
let view = CustomView(text: "🏠")
let annotation = ViewAnnotation(coordinate: coordinate, view: view)
annotation.allowOverlap = true
mapView.viewAnnotations.add(annotation)

// Update annotation
annotation.visible = false

// Remove annotation
annotation.remove()
```

The following example uses a dynamic ``ViewAnnotation`` to display route details:

**v11**
```swift
let view = ETAView(text: "55 min")
let annotation = ViewAnnotation(layerId: "route", view: view)
annotation.variableAnchors = .all // Allow anchor to be displayed in all directions.
annotation.onAnchorChanged = { config in
    // Update anchor position.
    etaView.anchor = config.anchor
}
mapView.viewAnnotations.add(annotation)

// When annotation content is changed, call `setNeedsUpdateSize()` for proper positioning.
view.text = "1h 05min"
annotation.setNeedsUpdateSize()
```

The new Dynamic View Annotations are supported in SwiftUI, check out the <doc:SwiftUI-User-Guide#View-Annotations> guide.

### 2.5 Map Content Gesture System

The new API allows you to assign Tap and Long Press gestures handlers to Annotations, Layers, and the Map. The handlers are called according to the rendered layer position starting from the top-most. The map handler is called when neither annotation nor layer handle the gesture.

**v11**
```swift
let annotationManager = mapView.annotations.makePolygonAnnotationManager()
var annotation = PolygonAnnotation(...)
annotation.tapHandler = { context in
  print("tapped point annotation at \(context.coordinate)")
  return true // the polygon handled the tap, do not propagate
}
annotationManager.annotations = [annotation]

mapView.gestures.onLayerTap("my-layer") { queriedFeature, context in
    print("tapped feature \(queriedFeature) of my-layer at \(context.coordinate)")
    return true // layer handled the tap, do not propagate
}.store(in: &cancelables)

mapView.gestures.onMapTap.observe { context in
    // this handler is called when neither annotation nor layer handled the tap.
    print("map tapped at \(context.coordinate)")
}.store(in: &cancelables)
```

For more details, please read the <doc:Map-Content-Gestures-User-Guide>.

### 2.6 Access Token and Map Options management

The access token for every Mapbox SDK can now be set via single call of `MapboxOptions/accessToken`. By default, Mapbox SDKs will try to initialize it upon framework initialization time from:

- `MBXAccessToken` property list value in the app bundle;
- `MapboxAccessToken` file in the app bundle.

If you wish to set access token programmatically, it is highly recommended to set it before initializing a `MapView`.

**v11:**

```swift
import MapboxMaps

MapboxOptions.accessToken = accessToken
```

Configurations for the external resources used by Maps API can now be set via ``MapboxMapsOptions``:

**v11:**

```swift
import MapboxMaps

MapboxMapsOptions.dataPath = customDataPathURL
MapboxMapsOptions.assetPath = customAssetPathURL
MapboxMapsOptions.tileStoreUsageMode = .readOnly
MapboxMapsOptions.tileStore = tileStore
```

To clear the temporary map data, use the ``MapboxMap/clearData(completion:)`` method.

As part of this change `ResourceOptions` and `ResourceOptionsManager` have been removed.
The TileStore also no longer accepts access token as part of its options.

### 2.7 New 3D Lighting API

In v11 we've introduced new experimental lighting APIs to give you control of lighting and shadows in your map when using 3D objects: ``AmbientLight`` and ``DirectionalLight``. We've also added new APIs on ``FillExtrusionLayer`` and ``LineLayer``s to support this 3D lighting styling and enhance your ability to work with 3D model layers. Together, these properties can illuminate your 3D objects such as buildings and terrain to provide a more realistic and immersive map experience for your users. These properties can be set at runtime to follow the time of day, a particular mood, or other lighting goals in your map. Check out our example [here](https://github.com/mapbox/mapbox-maps-ios/blob/main/Apps/Examples/Examples/All%20Examples/Lab/Lights3DExample.swift) for implementation recommendations.

### 2.8 Location API

We introduced several changes to the location-related classes and protocols that will make working with location easier.

The old `LocationProvider` and `Location` were significantly simplified:
- The `LocationProvider` and `Location` are now only responsible for providing location updates. The `LocationProvider` doesn't manage the permissions, accuracy authorization, or heading anymore.
- Heading (compass) data doesn't participate in `Location`.
- The new ``HeadingProvider`` and ``Heading`` are now responsible for providing the heading (compass) updates. The ``HeadingProvider`` is optional and only needed if you use ``PuckBearing/heading`` as a puck bearing type.

- Note: `Location` and ``Heading`` have been separated because their updates can come from the different sources. This also allows us to animate the heading quicker than the location which results in more responsive puck behavior.

In case you need to drive the puck with custom location data, the `LocationProvider` protocol is easy to implement in **v11**:

```swift
class CustomLocationProvider: LocationProvider {
    private let observers: NSHashTable<AnyObject> = .weakObjects()
    var location: Location? {
        didSet {
            guard let location else { return }
            for observer in observers.allObjects {
                (observer as? LocationObserver)?.onLocationUpdateReceived(for: [location])
            }
        }
    }

    public func getLastObservedLocation() -> Location? {
        location
    }

    public func addLocationObserver(for observer: LocationObserver) {
        observers.add(observer)
    }

    public func removeLocationObserver(for observer: LocationObserver) {
        observers.remove(observer)
    }
}

// Override the location provider with the custom one.
let locationProvider = CustomLocationProvider()
mapView.location.override(locationProvider: locationProvider)
```

In case you also need to supply a custom heading (compass) data, implement the ``HeadingProvider`` and override it too:

```swift
let headingProvider = CustomHeadingProvider()
mapView.location.override(locationProvider: locationProvider, headingProvider: headingProvider)
```

The ``LocationManager`` was simplified too. Now it only manages the the location puck, not the `LocationProvider`. For example, its ``LocationManager/options`` only determine the puck appearance. If you need to fine-tune the location provider itself, do it directly via the default ``AppleLocationProvider`` or your own custom provider implementation.

**v10**

```swift
mapView.location.options.distanceFilter = 100
```

**v11**
```swift
let locationProvider = AppleLocationProvider()
locationProvider.options.distanceFilter = 100
mapView.location.override(provider: locationProvider)
```

The ``LocationManager`` now provides ``Signal`` endpoints such as ``LocationManager/onPuckRender``, ``LocationManager/onLocationChange``, ``LocationManager/onHeadingChange``. You can use them to observe puck in the same way, as Map Events (see section 2.2).

**v10**
```swift
mapView.location.addPuckLocationConsumer(self)
```

**v11**
```swift
mapView.location.onPuckRender.observe { renderingData in
    // Adjust puck-connected elements (route line, annotations) here.
}.store(in: &cancelables)
```

As a bonus, you now can use a Combine `Publisher` to drive the puck location updates:

**v11**

```swift
class Example {
    @Published
    private var locations = [Location(coordinate: .init(latitude: 0, longitude: 0))]
    @Published
    private var heading = Heading(direction: 0, accuracy: 0)

    func setup() {
        mapView.location.override(
            locationProvider: $location.eraseToSignal(),
            headingProvider: $heading.eraseToSignal())
    }

    func update() {
        locations = /* new locations update */
        heading = /* new heading */
    }
```

Please check out a more detailed example [here](https://github.com/mapbox/mapbox-maps-ios/blob/main/Apps/Examples/Examples/All%20Examples/Lab/CombineLocationExample.swift).

### 2.9 Camera API

In v11, we have refined the Camera API introduced in v10 to improve developer ergonomics. These changes include several minor updates to usability:

- The SDK now exposes the owner property on ``CameraAnimator``, allowing you to more easily identify the owner.
- The cameraFor methods (cameraForCoordinatesArray, cameraForLocationArray, and cameraForCoordinateBounds) have been simplified and aligned with our Android and Web SDKs. Passing a padding parameter is now optional, and additional optional maxZoom and offset parameters are available for cameraForCoordinateBounds.
- Finally, cameraState can now be accessed through mapboxMap rather than directly on mapView.

**v10:**

```swift
mapView.cameraState.center
```

**v11:**

```swift
mapView.mapboxMap.cameraState.center
```

### 2.10 Tracing

The Maps SDK introduces signpost recording support. Signposts are important instruments for analyzing performance and detecting bottlenecks in your code.

**How to enable tracing**

```swift
Tracing.status = .enabled
```
Alternatively, you can set the `MAPBOX_MAPS_SIGNPOSTS_ENABLED` environment variable to `1` in your application scheme.

Please note that these options will enable all available Maps SDK components for tracing.

**Configure tracing components**

Signposts in the Maps SDK are currently separated into two components:

Tracing component | Description
--- | ---
`core` | Rendering engine (responsible for almost every rendering aspect in the ``MapView`` and ``Snapshotter``).
`platform` | Maps SDK functionality like gestures, animations, view annotations, and so on.

> Important: SDK generates a lot of event for each frame, so Instruments might skip some of them in `Immediate` record mode. Enable `Last N seconds` mode to preserve full signpost data ([see more](https://help.apple.com/instruments/mac/11.0/index.html?localePath=en.lproj#/dev191fbf48)).

To limit signposts generation for a single component, please use the following API:

```swift
Tracing.status = .platform
```

To configure tracing components through environment variable use comma separator like:
```
MAPBOX_MAPS_SIGNPOSTS_ENABLED=core,platform
```
> Hint: Pass `0` or `disabled` to disable tracing through environment variable.

`Tracing.status` API takes precedence over environment variable value. All values are case-insensitive.

### 2.11 Mapbox Maps Recorder

``MapRecorder`` provides an experimental API to record and replay map interaction sessions. Such recordings can be used to debug issues which require multiple steps to reproduce. Usage example can be found [here](https://github.com/mapbox/mapbox-maps-ios/blob/main/Apps/Examples/Examples/All%20Examples/Lab/MapRecorderExample.swift).

### 2.12 Other minor ergonomic improvements

#### 2.12.1 MapboxMap

We added an experimental `tileCover` method to `MapboxMap` that returns tile Ids covering the map. Use ``TileCoverOptions-swift.struct`` to identify which tile range to return tile Ids for.

```swift
let tileCoverOptions = TileCoverOptions(tileSize: 512, minZoom: 4, maxZoom: 8, roundZoom: true)
let tileIds = mapView.mapboxMap.tileCover(for: tileCoverOptions)
```

#### 2.12.2 Sources

Sources are now required to specify ``Source/id`` upon creation for easier reference later.

**v10:**

```swift
let terrainSource = RasterDemSource()
mapView.mapboxMap.style.addSource(terrainSource, id: "terrain-source")
```

**v11:**

```swift
let terrainSource = RasterDemSource(id: "terrain-source")
mapView.mapboxMap.addSource(terrainSource)
```

The ``GeoJSONSource`` now supports configuration with a GeoJSON string as well as a URL, Feature, Feature Collection, or Geometry:

**v11:**

```swift
let poiGeoJSON = """
{
  "type": "FeatureCollection",
  "features": [
    { "type": "Feature", "geometry": { "type": "Point", "coordinates": [ -151.5129, 63.1016 ] } }
  ]
}
"""
var poiSource = GeoJSONSource(id: "poi")
poiSource.data = .string(poiGeoJSON)
mapView.mapboxMap.addSource(poiSource)
```

#### 2.12.3

Most layers (such as ``LineLayer``, ``CircleLayer``, and others) now require the `source` parameter in the initializer. It will make style manipulation code less error-prone.

**v10**

```swift
var lineLayer = LineLayer(id: "route-line")
lineLayer.source = "route-data"
mapView.mapboxMap.style.addLayer(lineLayer)
```

**v11**

```swift
let lineLayer = LineLayer(id: "route-line", source: "route-data")
mapView.mapboxMap.addLayer(lineLayer)
```

Contrary to that, some layers (such as ``BackgroundLayer``, ``SkyLayer``, and ``LocationIndicatorLayer``) don't need `source`, `sourceLayer`, and `filter` properties. To clean up the code we removed them from those layers and from the ``Layer`` protocol.

#### 2.12.4 Support of GeoJSON partial updates.

Instead of setting the whole new GeoJSON object anew every time a single feature has changed, now you can apply more granular, partial GeoJSON updates.
If your features have associated identifiers - you can add, update and remove them on individual basis in your ``GeoJSONSource``.
This is especially beneficial for ``GeoJSONSource``s hosting a large amount of features - in this case adding a feature can be up to 4x faster with partial update API.

```swift
try mapView.mapboxMap.addGeoJSONSourceFeatures(forSourceId: sourceId, features: features)
try mapView.mapboxMap.updateGeoJSONSourceFeatures(forSourceId: sourceId, features: features)
try mapView.mapboxMap.removeGeoJSONSourceFeatures(forSourceId: sourceId, featureIds: featureIds)
```

#### 2.12.5 Gestures

##### Breaking change ⚠️

`MapboxMap.dragStart()` and `MapboxMap.dragEnd()` are not in use anymore and got removed, instead use `MapboxMap.beginGesture()` and `MapboxMap.endGesture()` respectively.


While maintaing the existing gesture approach we made minor improvements. In v11 we now:

- allow animation during any ongoing gestures
- enable zoom during a drag gesture
- added a `rotation` case to `GestureType` to be able to detect rotation separately from other gestures.

#### 2.12.6 Expressions

- Introduced `hsl`, `hsla` color expression
- Introduced `random` expression
- Introduced `measureLight` expression lights configuration property

#### 2.12.7 Cache Management

Experimental API `MapboxMap/setMemoryBudget(_:)` was renamed to ``MapboxMap/setTileCacheBudget(size:)`` and promoted to stable.

#### 2.12.8 Puck3D's scaling behavior

To further improve the performance of 3D model layer, we have replaced Puck 3D's default `model-scale` expression with a new API ``Puck3DConfiguration/modelScaleMode``. By default this property is ``ModelScaleMode/viewport``, which will keep the 3D model size constant across different zoom levels.
While this means that Puck 3D's size should render similarly to v10, it does introduces a behavior breaking change - that ``Puck3DConfiguration/modelScale`` needs to be adjusted to correctly render the puck (in testing we found the adjustment to be around 100x of v10 `model-scale` value, but that could vary depending on other properties etc.).

## 3. Replace Deprecated APIs and Address Breaking Changes

Check for any deprecated APIs in your code and replace them with the recommended alternatives. Deprecated APIs may be removed in future releases.

### 3.1 Replace deprecated MapboxMap/style and Snapshot/style

We've simplified MapboxMap and Snapshot so you can now access Style APIs directly from ``MapboxMap`` and ``Snapshotter`` instance rather than going through the deprecated Style object. For example:

**v10:**

```swift
mapView.mapboxMap.style.updateGeoJSONSource(withId: "route", geoJSON: route)
...
let projection = snapshot.style.projection
```

**v11:**

```swift
mapView.mapboxMap.updateGeoJSONSource(withId: "route", geoJSON: route)
...
let projection = snapshot.projection
```

### 3.2 Replace deprecated Annotations properties for `iconTextFit` and `iconTextFitPadding`

In v11, you can update `iconTextFit` and `iconTextFitPadding` directly on the ``PointAnnotation`` rather than through the ``PointAnnotationManager``. This allows for control over these values for each annotation.

**v10:**

```swift
pointAnnotationManager.iconTextFit = .width
pointAnnotationManager.iconTextFitPadding = [1, 2.3, 4, 5]
```

**v11:**

```swift
pointAnnotation.iconTextFit = .width
pointAnnotation.iconTextFitPadding = [1, 2.3, 4, 5]
```

As a result, ``PointAnnotationManager/iconTextFit`` and ``PointAnnotationManager/iconTextFitPadding`` are deprecated in v11 and will be removed in v12.


### 3.3 Replace deprecated Events methods

In v11, `mapView.mapboxMap.onEvery(<eventType>)` and `mapView.mapboxMap.onNext(event: <eventType>)` have been deprecated in favor of `mapboxMap.on<eventType>.observeNext` and `mapboxMap.on<eventType>.observe`.

For more context, please see the Type-safe Events API section above.

### 3.4 Replace deprecated MapView properties

In v11 `mapView.cameraState` has been moved to `mapboxMap`, so the mapView property has been deprecated. Update your implementation like so:

**v10:**

```swift
let center = mapView.cameraState.center
```

**v11:**

```swift
let center = mapView.mapboxMap.cameraState.center
```

### 3.5 Replace deprecated LocationManager properties

We've made several changes and renamed parts of ``LocationManager``. See the above Location API section for more details.

### 3.6 Replace deprecated MapboxMap properties

Several properties on ``MapboxMap`` were renamed in v11 for clarity. Please update your implementation:

**v10:**

```swift
mapboxMap.uri = .standard
mapboxMap.JSON = "Your style JSON"
mapboxMap.transition = TransitionOptions(
            duration: 3,
            delay: 2,
            enablePlacementTransitions: true)
mapboxMap.isLoaded = true
let defaultCamera = mapboxMap.defaultCamera
```

**v11:**

```swift
mapboxMap.styleURI = .standard
mapboxMap.styleJSON = "Your style JSON"
mapboxMap.styleTransition = TransitionOptions(
            duration: 3,
            delay: 2,
            enablePlacementTransitions: true)
mapboxMap.isStyleLoaded = true
let defaultCamera = mapboxMap.styleDefaultCamera
```

### 3.7 Maps SDK no longer reexport MetalKit and UIKit

Mapbox Maps SDK no longer reexports MetalKit and UIKit frameworks, so you will need to import them as needed for your code. In v10 version you could omit `import UIKit` if you already had an `import MapboxMaps` statement, but that is no longer possible.

**v10:**

```swift
import MapboxMaps

class ViewController: UIViewController { }
```

**v11:**

```swift
import UIKit
import MapboxMaps

class ViewController: UIViewController { }
```

### 3.8 Http Stack changes

#### 3.8.1 HttpServiceFactory and HttpInterceptor changes

`HTTPServiceFactory.reset`, `HttpServiceFactory.setUserDefinedForCustom` and `HttpServiceInterface` have been removed from public visibility. ***It is thus no longer possible to override the HTTP stack.***

If you need to set a HTTP interceptor you can do it via the `HttpServiceFactory.setHttpServiceInterceptorInterface` function. The `HttpServiceInterceptorInterface` has been changed: the `onDownload` function no longer exists and the signature of `onRequest` and `onResponse` have been changed to return a value through a continuation.

**v10**

```swift
class Interceptor: HttpServiceInterceptorInterface {
    func onRequest(for request: HttpRequest) -> HttpRequest {
        return request
    }

    func onResponse(for response: HttpResponse) -> HttpResponse {
        return response
    }

    func onDownload(forDownload download: DownloadOptions) -> DownloadOptions {
        return download
    }
}
```

**v11**

```swift
class Interceptor: HttpServiceInterceptorInterface {
    func onRequest(for request: HttpRequest, continuation: @escaping HttpServiceInterceptorRequestContinuation) {
        continuation(HttpRequestOrResponse.fromHttpRequest(request))
    }

    func onResponse(for response: HttpResponse, continuation: @escaping HttpServiceInterceptorResponseContinuation) {
        continuation(response)
    }
}
```

#### 3.8.2 HttpRequest changes

Introduce `HttpRequestFlags` constants to set additional HttpRequest parameters.

`HttpRequest.keepCompression` moved to `HttpRequest.flags`.

**v10**

```swift
let httpRequest = HttpRequest(method: HttpMethod.get, url: "", headers: [:], keepCompression: false, timeout: 0,
                              networkRestriction: NetworkRestriction.none, sdkInformation: sdkInformation, body: nil)
```

**v11**

```swift
let httpRequest = HttpRequest(method: HttpMethod.get, url: "", headers: [:], timeout: 0, networkRestriction: NetworkRestriction.none,
                              sdkInformation: sdkInformation, body: nil, flags: HttpRequestFlags.none)
```

### 3.9 Offline API

#### 3.9.1 ``OfflineManager`` API changes

- Due to changes documented in Access Token and Map Options management, you no longer need to provide a resource options when initializing an instance of ``OfflineManager``.
- `TilesetDescriptorOptionsForTilesets` and `OfflineManager/createTilesetDescriptorForTilesetDescriptorOptions(_:)` has been removed. Instead you can provide an optional list of `tilesets` when initializing an instance of ``TilesetDescriptorOptions`` and use it to create a `TilesetDescriptor` using `OfflineManager/createTilesetDescriptor(_:)`.
- You can now observe when a style pack is removed with a completion handler.

**v10**
```swift
let offlineManager = OfflineManager(resourceOptions: aResourceOptions)
let tilesetDescriptorOptions = TilesetDescriptorOptionsForTilesets(
    tilesets: ["mapbox://mapbox.mapbox-streets-v8"],
    zoomRange: 0...5)

let tilesetDescriptor = offlineManager.createTilesetDescriptorForTilesetDescriptorOptions(tilesetDescriptorOptions)

offlineManager.removeStylePack(for: .streets)
```

**v11**
```swift
let offlineManager = OfflineManager()
let tileSetDescriptorOptions = TilesetDescriptorOptions(
    styleURI: .outdoors,
    zoomRange: 0...16,
    tilesets: ["mapbox://mapbox.mapbox-streets-v8"])

let tilesetDescriptor = offlineManager.createTilesetDescriptor(for: tileSetDescriptorOptions)

offlineManager.removeStylePack(for: .streets) { result in
    // handle style pack removal result
}
```

#### 3.9.2 Legacy ``OfflineRegionManager`` changes

- Due to changes documented in Access Token and Map Options management, you no longer need to provide a resource options when initializing an instance of ``OfflineRegionManager``.
- `ResponseError` has been renamed to ``OfflineRegionError``, with new flag named `isFatal` indicating that the error is fatal i.e. the region cannot proceed downloading of any resources and it will be put to inactive state.
- ``OfflineRegionObserver`` no longer requires function `responseError(forError:)`, instead you can implement function `errorOccurred(forError:)` to be notified of errors encountered while downloading regional resources.
- `ResponseErrorReason` is renamed to `OfflineRegionErrorType`.
    - The `OfflineRegionErrorType.diskFull` is introduced as a specific error code for shortage of the available space to store the resources.
    - The `OfflineRegionErrorType.tileCountLimitExceeded` is introduced as a specific error code indicating that the limit on the number of Mapbox tiles stored for offline regions has been reached. As a result, function `tileCountLimitExceeded()` is no longer required for conformers of `OfflineRegionObserver`.

**v10**
```swift
let offlineRegionManager = OfflineRegionManager(resourceOptions: aResourceOptions)
let observer = OfflineRegionObserver()
offlineRegionManager.setOfflineRegionObserverFor(observer)

class OfflineRegionObserver: MapboxCoreMaps.OfflineRegionObserver {

    func responseError(forError error: ResponseError) {
        // handle error
    }

    func tileCountLimitExceeded() {
        // handle tile count limit exceeded
    }
}
```

**v11**
```swift
let offlineRegionManager = OfflineRegionManager()
let observer = OfflineRegionObserver()
offlineRegionManager.setOfflineRegionObserverFor(observer)

class OfflineRegionObserver: MapboxCoreMaps.OfflineRegionObserver {

    func errorOccurred(forError error: OfflineRegionError) {
        if case error.type == .tileCountLimitExceeded {
            // handle tile count limit exceed
        }
        ...
    }
}
```

#### 3.10 ``OverviewViewportStateOptions`` changes.

The `OverviewViewportStateOptions.padding` parameter is renamed to ``OverviewViewportStateOptions/geometryPadding``. It adds padding for every coordinate before fitting the geometry. The ``OverviewViewportStateOptions/padding`` now adds camera padding, similar to ``FollowPuckViewportStateOptions/padding``.

#### 3.11 Bearing updates are disabled by default.

The default value for ``LocationOptions/puckBearingEnabled`` option has changed from `true` to `false`. That practially means that
MapView wouldn't redraw on each device compass update and should significantly reduce CPU usage for applications that
only display user location without bearing/heading indication.
If your application still need to rotate puck image according to device heading or location course, enable the option as:

```swift
    mapView.location.options.puckBearingEnabled = true
```

#### 3.12 TileRegionLoadOptions changes.

`TileRegionLoadOptions.startLocation` property type changed from `CLLocation` to `Coordinate2D`.

## 4. Update APIs deprecated in v10 which have been removed in v11

- `textLineHeight` property has been removed from ``PointAnnotationManager``. Instead, use the data-driven ``PointAnnotation/textLineHeight``.
- `PuckBearingSource` has been renamed to ``PuckBearing`` and removed in v11. Along with this, constructor `LocationOptions.init(distanceFilter:desiredAccuracy:activityType:puckType:puckBearingSource:puckBearingEnabled:)` has also been removed, instead please use ``LocationOptions/init(puckType:puckBearing:puckBearingEnabled:)``
- `pinchRotateEnabled` property has been removed from ``GestureOptions``. Instead, use the renamed ``GestureOptions/rotateEnabled``.
- Experimental `MapboxMap.setRenderCache(_:)` has been removed.
- `MapEvents.EventKind` and `MapEvents.Event` have been removed, however, we have provided a shim to smoothen the migration process from v10 to v11. Please refer to the Type-safe Events API section to update your events code.
- The following transition properties have been removed from our layers:
    * `backgroundPatternTransition` has been removed from ``BackgroundLayer``
    * `fillExtrusionPatternTransition` has been removed from ``FillExtrusionLayer``
    * `fillPatternTransition` has been removed from ``FillLayer``
    * `lineDasharrayTransition`, `linePatternTransition` have been removed from ``LineLayer``

## 5. Review other changes

- For all `Layer` types, the ``Layer/visibility`` property now only supports a constant value, instead of ``Expression``.
- Protocol `LocationProvider` now requires class semantic for implementation.
- Map size is now synced to the size of the Metal view
- The `easeTo/flyTo` APIs return non-optional cancelable token.
- The following `GeoJsonSource` cluster APIs now return `Cancelable`: `getGeoJsonClusterLeaves`, `getGeoJsonClusterChildren`, `getGeoJsonClusterExpansionZoom`.
- The `MapOptions/optimizeForTerrain` option was removed, whenever terrain is present layer order is now automatically adjusted for better performance. Previously, optimization was the default.

## 7. Test Your App

Test your app thoroughly after making the changes to ensure everything is working as expected.

## 8. Conclusion

Following the above steps will help you migrate your app to the latest version of the Mapbox Maps SDK for Android. If you encounter any issues during the migration process, refer to the [Mapbox Maps SDK for iOS documentation](https://docs.mapbox.com/ios/maps/overview/) or reach out to the Mapbox support team for assistance.

## Known Issues

- When using styles with globe projection, such as Standard or Streets:
    - the ``MapboxMap/camera(for:padding:bearing:pitch:)-1il0f`` and similar methods can return wrong camera options.
    - the ``OverviewViewportState`` may focus the map camera incorrectly.
