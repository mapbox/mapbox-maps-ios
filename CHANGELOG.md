# Changelog for Mapbox Maps SDK v11 for iOS

Mapbox welcomes participation and contributions from everyone.

## main

## 11.13.1 - 18 June, 2025

## 11.13.0 - 17 June, 2025

## 11.13.0-rc.1 - 03 June, 2025

## 11.13.0-rc.1

* Introduce experimental `worldview` expression.

## 11.13.0-beta.1 - 19 May, 2025

## Breaking changes ⚠️
* `PointAnnotation.iconImageCrossFade` has been deprecated and setting value to it will not have any impact. Use `PointAnnotationManager.iconImageCrossFadeTransition` instead.

* The Interactions and Featuresets API is promoted from experimental. The new API allows you to add interaction handlers to layers, Standard Style featuresets (POI, Buildings and Place Labels), and the map itself in the consistent way. You can control the propagation of events, tappable area, and the order of event handling.
* The experimental style `MapStyle.standardExperimental` is removed. Use `MapStyle.standard` instead.
* Methods `GestureManager.onMapTap`, `GestureManager.onMapLongPress`, `GestureManager.onLayerTap`, `GestureManager.onLayerLongPress` and their SwiftUI counterparts are deprecated. Use `TapInteraction` and `LongPressInteraction` instead.
* Add new `VectorSource.promoteId2` and `GeoJSONSource.promoteId2`. Deprecate `VectorSource.promoteId` and `GeoJSONSource.promoteId`. The newer version support the expression variant of promoteId, which can be used to dynamically nominate IDs to the features.

```swift
// Before (SwiftUI)
Map()
    .onMapTapGesture { context in
        // Handle tap on map
    }
    .onLayerLongPressGesture("a-layer-id") { feature, context in
        // Handle press on a layer
        return true
    }

// After (SwiftUI)
Map {
    TapInteraction { feature in
        // Handle tap on map
        return true
    }

    LongPressInteraction(.layer("a-layer-id")) { feature, context in
        // Handle press on a layer
        return true
    }

    // Bonus: If you use Standard style, new API allows to handle tap on POI, Buildings and Place Labels
    TapInteraction(.standardPoi) { poi, feature in
        print("Tap on \(poi.name)")
        return true
    }
}
```

```swift
// Before (UIKit)
mapView.gestures.onMapTap.observe { context in
    // Handle Tap on Map
}.store(in: &cancelables)

mapView.gestures.onLayerLongPress("a-layer-id") { feature, context in
    // Handle Long press
    return true
}

// After (UIKit)
mapView.mapboxMap.addInteraction(TapInteraction { context in
    // Handle tap on map
    return true
})

mapView.mapboxMap.addInteraction(LongPressInteraction(.layer("a-layer-id")) { feature, context in
    // Handle long press on a layer
    return true
})

// Bonus: If you use Standard style, new API allows to handle tap on POI, Buildings and Place Labels
mapView.mapboxMap.addInteraction(TapInteraction(.standardPoi) { poi, feature in
    print("Tap on poi \(poi.name)")
    return true
})
```

* Expose new experimental properties: `CircleLayer.circleElevationReference`, `FillLayer.fillConstructBridgeGuardRail`, `FillLayer.fillBridgeGuardRailColor`, `FillLayer.fillTunnelStructureColor`.
* Expose new `showLandmarkIcons` property in `MapStyle.standard`.
* New example for elevated spiral line. Utilized the experimental API `LineLayer/linezOffset`.

## 11.12.0 - 07 May, 2025

## 11.12.0-rc.1 - 23 April, 2025

* Expose an experimental API to define a non-rectangular screen culling shape(`MapboxMap.screenCullingShape`).

## 11.12.0-beta.1 - 9 April, 2025

* Expose `graphicsPrograms`, `graphicsProgramsCreationTimeMillis` and `fboSwitchCount` for `CumulativeRenderingStatistics`.
* Update CoreMaps to 11.12.0-beta.1 and Common to 24.12.0-beta.1

## 11.11.0 - 26 March, 2025

* Update CoreMaps to 11.11.0 and Common to 24.11.0
* `top-image`, `bearing-image`, and `shadow-image` properties on `LocationIndicatorLayer` are now paint properties instead of layout properties.

## 11.11.0-rc.1 – 12 March, 2025

* Expose experimental API for setting ColorTheme on style imports.
* Expose use-theme properties for all annotation types and Puck3D layer.
* Update CoreMaps to 11.11.0-rc.2.
* Update Common to 24.11.0-rc.2.

## 11.11.0-beta.1 – 03 March, 2025

* Reduce MapboxMaps binary size by removing debug symbols. Complete dSYM files are still available in the XCFramework.
* Support panning and pinch gestures on trackpads.

## 11.10.1 - 25 February, 2025

* Update CoreMaps to 11.10.2.

## 11.10.0 - 13 February, 2025

* Update CoreMaps to 11.10.0.

## 11.10.0-rc.1 - 31 January, 2025

* Expose experimental ColorTheme API to set style wide color theme. A color theme modifies the global colors of a style using a LUT (lookup table) for color grading.
Pass the image either as a base64-encoded string or as UIImage:
```swift
let mapView = MapView()
mapView.mapboxMap.setMapStyleContent {
   ColorTheme(base64: "base64EncodedImage") // or use an uiimage shortcut ColorTheme(uiimage: lutImage)
}
```
Note: Each style can have only one `ColorTheme`. Setting a new theme overwrites the previous one. Further details can be found in documentation for `ColorTheme`
* Promote `ClipLayer.clipLayerTypes` and `ClipLayer.clipLayerScope` to stable.
* Remove experimental `DirectionalLight.shadowQuality`.
* Add experimental `ViewAnnotationManager.viewAnnotationAvoidLayers` for specifying layers that view annotations should avoid. The API currently only supports line layers.
* Add support for the `maxOverscaleFactorForParentTiles` property in `CustomRasterSource` and `CustomGeometrySource`, allowing greater control over tile overscaling behavior when rendering custom raster tiles.
* Add support for experimental *-use-theme property that allow to override the color theme set on the Map. This is experimental and have several limitations - currently expressions are not supported. Color properties in Lights, Rain, Snow are not supported. *-use-theme for layer applied only after zoom level change.
* Update CoreMaps to 11.10.0-rc.1 and Common to 24.10.0-rc.1.

## 11.10.0-beta.1 - 20 January, 2025

* Mark `SymbolElevationReference`, `FillExtrusionBaseAlignment`, `FillExtrusionHeightAlignment`,  `ModelScaleMode`, `ModelType`, `ClipLayerTypes`, `BackgroundPitchAlignment` types as Experimental. Initially they were exposed as stable by mistake. If you use them, please import `MapboxMaps` with `Experimental` SPI:
```
@_spi(Experimental) import MapboxMaps
```

* Localize geofencing attribution dialog.
* Support dictionary expression literals.
* Bump minimal deployment target from 12.0 to 14.0.
* [SwiftUI] Expose new `slot()` method on annotation groups that takes `Slot` instead of `String`. Use the type with annotationGroups:

swift
```
CircleAnnotationGroup {}
  // old
  .slot("middle")
  // new
  .slot(.middle)
```

* Introduce `ViewAnnotation.priority`, deprecate `ViewAnnotation.selected`.
Use this property to define view annotation sort order.
* Introduce `ViewAnnotation.minZoom` and `ViewAnnotation.maxZoom`. Use these properties to configure zoom-level specific view annotations.
* Update CoreMaps to 11.10.0-beta.2 and Common to 24.10.0-beta.2.

## 11.9.2 - 5 February, 2025

* Update CoreMaps to 11.9.3.

## 11.9.1 - 20 January, 2025

* Update CoreMaps to 11.9.2.

## 11.9.0 - 18 December, 2024

* Remove experimental SPI from `StyleImage`.
* Promote ClipLayer to stable.
* Fix the encoding/decoding key for `Rain/centerThinning` and `Snow/centerThinning`.
* Update CoreMaps to 11.9.0 and Common to 24.9.0.

## 11.9.0-beta.1 - 9 December, 2024

* Add a new API to disable custom resizing implementation of the MapView. To disable the custom resizing implementation, set `MapView.resizingAnimation` to `.none`.
* Add `to-hsla` expression support.

## 11.9.0-beta.1 - 28 November, 2024

⚠️⚠️⚠️ Potentially breaking changes ⚠️⚠️⚠️
* Mark `symbolElevationReference`, `symbolZOffset`, `lineTrimColor `,  `lineTrimFadeRange`, `lineZOffset` as Experimental in AnnotationManagers. This is potentially breaking change, however those properties are not marked as experimental only in AnnotationManagers by mistake.
In order to continue use them use the following import `@_spi(Experimental) import MapboxMaps`.

* Add two separate Geofence examples in SwiftUI - `GeofencingPlayground` and `GeofencingUserLocation`
* Add support for Base and Height alignment in FillExtrusionLayer.
* Add support for `pitchAlignment` in BackgroundLayer.
* Add support for `zOffset` in FillLayer, PolygonAnnotation[Manager] and PolygonAnnotationGroup.
* Add a property emphasisCircleGlowRange to LocationIndicatorLayer to control the glow effect of the emphasis circle – from the solid start to the fully transparent end.
* Fix a crash on calling `LocationIndicatorLayer/location(coordinate:) function` due to missing 0 altitude value.
* Add a new Expression initializer `init(_ operator: Operator, _ arguments: ExpressionArgumentConvertible...)` to simplify the creation of expressions with multiple arguments.
That initializer doesn't require to wrap arguments in `Argument` cases. For example, `Exp(.eq, Exp(.get, "extrude"), "true")`.
* Expose a `TileStore/clearAmbientCache()` method to clear ambient cache.
* Add new experimental `radius` parameter to `TapInteraction`, `LongPressInteraction` and interaction managers to control the radius of a tappable area.
* Add a way to specify image expression options.
* Bump core maps version to 11.9.0-beta.1 and common sdk to 24.9.0-beta.1
* Add new experimental APIs to control precipitation rendering. Snow and Rain are available now with an `@_spi(Experimental)` import prefix.
* Add a way to filter attribution menu items.

## 11.8.0 - 11 November, 2024

* Add two separated Geofence examples in SwiftUI - `GeofencingPlayground` and `GeofencingUserLocation`
* Expose `lineElevationReference`, `lineCrossSlope`, `iconSizeScaleRange`, `textSizeScaleRange` as experimental
* Mark `ClipLayer` as stable

## 11.8.0-rc.1 - 23 October, 2024

* Fix the bug when MapView would ignore the new bounds size if there are more than a single resizing event in the animation.

## 11.8.0-beta.1 - 14 October, 2024

* [SwiftUI] Fixed crash when ForEvery was used with duplicated IDs.
* Introduce experimental Geofencing API. Implementation example: [GeofencingExample.swift](Sources/Examples/All%20Examples/GeofencingExample.swift)
* Refactor of the experimental Interactions and Featuresets API:
  - `InteractiveFeature` is renamed to `FeaturesetFeature`.
  - Introduce new `StandardPoiFeature`, `StandardBuildingsFeature`, `StandardPlaceLabelsFeature`.
  - Introduce new `FeaturesetDescriptor`.

* Generate `MapStyle.standard` and `MapStyle.standardSatellite` from the style specification. Added the new `StandardFont` type to represent the font family in these configurations. If you used a string variable, update your code:
```swift
// Old:
Map().mapStyle(.standard(font: fontValue))
/// New:
Map().mapStyle(.standard(font: StandardFont(rawValue: fontValue)))
Map().mapStyle(.standard(font: .lato))
```
* Introduce experimental property `MapboxMap.styleGlyphURL`. Use this property to apply custom fonts to the map at runtime, without modifying the base style.
* Fix a console warning (`Source x missing for layer x`) when using annotation managers.

## 11.7.0 - 26 September, 2024

* Fix the bug where displaying ViewAnnotation and setting a feature state simultaneously could result in an unapplied feature state.
* Remove `MapboxMaps-Swift.h` from MapboxMaps framework, this will disable ObjC interop for MapboMaps.
* Update CoreMaps to 11.7.0 and Common to 24.7.0

## 11.7.0-rc.1 - 13 September, 2024

* Add experimental `FillExtrusionLayer.fillExtrusionLineWidth` that can switches fill extrusion rendering into wall rendering mode. Use this property to render the feature with the given width over the outlines of the geometry.

## 11.7.0-beta.1 - 30 August, 2024

* Expose data-driven properties on annotation managers. Now it's possible to set data-driven properties globally on annotation manager and specify per-annotation overrides.
Previously user had to specify those properties on each annotation and couldn't specify them globally
* Added new experimental interactive features API. Interactive features allow you to add interactions to both layers, the map itself, or the features defined in the imported styles, such as Standard Style. The new API supersedes the Map Content Gesture API and makes it cross-platform.
* Rename the `MapContentGestuereContext` to the `InteractionContext`
* Introduce a new `RenderedQueryGeometry` type to replace multiple `MapboxMaps.queryRenderedFeatures` overloads.
* [SwiftUI] Introduce new experimental `FeatureState` primitive.

* Expose data-driven properties on annotation managers. Now it's possible to set data-dirven properties globally on annotation manager and specify per-annotation overrides.
Previosuly user had to specify those properties on each annotation and couldn't specify them globally

```swift
CircleAnnotationGroup(circles, id: \.id) { circle in
    CircleAnnotation(centerCoordinate: circle.coordinate)
      .circleColor(circle.color)
      .circleRadius(10)
      .circleStrokeWidth(1)
      .circleStrokeColor(.black)
}
```

The problem with the above approach is that most of the properties are just duplicated for each annotation, which can lead to **large memory overhead** in case of big datasets. In order to solve this issue and provide more versatile API the following approach is now possible, which is visually identical to previous snippet, but more performant.

```swift
CircleAnnotationGroup(circles, id: \.id) { circle in
    CircleAnnotation(centerCoordinate: circle.coordinate)
      .circleColor(circle.color)
}
.circleRadius(10)
.circleStrokeWidth(1)
.circleStrokeColor(.black)
```

Same applies for imperative API. In this case each even annotation will have random color, but others will use the global default specified in the annotation manager.

```swift
let circleAnnotationManager = mapView.annotations.makeCircleAnnotationManager()
var annotations = [CircleAnnotation]()
for i in 0...2000 {
  var annotation = CircleAnnotation(centerCoordinate: .random)
  if i % 2 == 0 { annotation.circleColor = StyleColor(.random) }
  annotations.append(annotation)
}
circleAnnotationManager.circleColor = .blue
```

* Improve memory reclamation behavior when using partial GeoJSON update API.
* Update Turf to 3.0.0 version. That version introduce breaking change – there is no more `RawRepresentable` conformances for `Array` and `Dictionary` system types. If you were relying on the `init(rawValue:)` function or `rawValue` property, you can use the substitution instead:

  * `init(rawValue:)` -> `init(turfRawValue:)`
  * `rawValue` -> `turfRawValue`
* Remove experimental `model-front-cutoff` property from `ModelLayer`
* Bump core maps version to 11.7.0-beta.2 and common sdk to 24.7.0-beta.2
* Expose experimental `ClipLayer.clipLayerScope`, `SymbolLayer.symbolElevationReference` and `SymbolLayer.symbolZOffset`.
* Most of public value types was marked as Sendable now, to facilitate adoption of Swift 6 concurrency model for SDK clients.
* `autoMaxZoom` property exposed for GeoJSONSource to fix rendering issues with `FillExtrusionLayer` in some cases

## 11.6.0 - 14 August, 2024

* Expose getters for `MapOptions.orientation`, `MapOptions.constrainMode` and `MapOptions.viewportMode`.
* Expose `lineTrimColor` and `lineTrimFadeRange` on `LineLayer` which allow to set custom color for trimmed line and fade effect for trim. Update navigation example to use those properties.

## 11.6.0-rc.1 - 31 July, 2024

⚠️⚠️⚠️ Known Issues ⚠️⚠️⚠️

* `ClipLayer` property `clipLayerTypes` is not updated in runtime. The fix is expected to land in stable 11.6.0.

### Features ✨ and improvements 🏁

* Expose new Standard Satellite style. Add new parameters to the Standard Style. With new Standard Style API it's possible to apply color themes on the map, hide/show road labels and show/hide 3D models. With new Standard Satellite style it's possible to show satellite imagery and also apply some configurations similar to Standard Style.

### Bug fixes 🐞

* Fix bug where updating MapStyle didn't update the configuration properties.
* Fix symbols with occlusion crashing on iOS simulators

## 11.6.0-beta.1 - 19 July, 2024

⚠️⚠️⚠️ Known Issues ⚠️⚠️⚠️

* `ClipLayer` property `clipLayerTypes` is not updated in runtime. The fix is expected to land in 11.6.0-rc.1.

### Features ✨ and improvements 🏁

* SwiftUI API marked as stable
* Expose experimental `ClipLayer` to remove 3D data (fill extrusions, landmarks, trees) and symbols.
* `CustomRasterSource` API updated, now `CustomRasterSourceOptions` accepts protocol `CustomRasterSourceClient`, enabling direct rendering into `CustomRasterSource` tiles. To achieve behavior similar to previous releases one may construct instance of `CustomRasterSourceClient` as shown below:

```swift
CustomRasterSourceOptions(tileStatusChangedFunction: { tileID, status in }) // Before
CustomRasterSourceOptions(clientCallback: CustomRasterSourceClient.fromCustomRasterSourceTileStatusChangedCallback { tileID, status in }) // Now
```

* Introduce new `ViewAnnotation.allowZElevate` and `MapViewAnnotation.allowZElevate` properties. When set to true, the annotation will be positioned on the rooftops of buildings, including both fill extrusions and models.
* Deprecate `MapView.presentsWithTransaction` and `Map.presentsWithTransaction` in favor of `MapView.presentationTransactionMode` and `Map.presentationTransactionMode`. The new default `PresentationTransactionMode.automatic` updates the `presentsWithTransaction` automatically when need to optimize performance. If you used the `MapView.presentsWithTransaction` with View Annotations, now you can safely remove this option:

```swift
Map {
  MapViewAnnotation(...)
}
.presentsWithTransaction(true) // Remove this
```

In case you need to preserve the old default behavior use `presentationTransactionMode = .async`:

```swift
mapView.presentationTransactionMode = .async // UIKit
Map().presentationTransactionMode(.async) // SwiftUI
```

* MapboxMaps XCFramework structure now properly constructed for `maccatalyst` platform and code signing issues was eliminated.

### Bug fixes 🐞

* Improved `line-pattern` precision
* Fixed `CustomRasterSource` rendering when camera shows anti-meridian or multiple world copies.

## 11.5.1 - 5 July, 2024

* Update CoreMaps to the 11.5.1 version.

## 11.5.0 - 3 July, 2024

* Use new `LineJoin.none` in conjunction with an image as a `linePattern` value to display repeated series of images along a line(e.g. dotted route line).
* Deprecate `Expression` in favor of `Exp` to avoid name clash with `Foundation.Expression`.

## 11.5.0-rc.1 - 19 June, 2024

* The CustomRasterSource API has been updated. It no longer includes a cache and now provides notifications about alternative tiles that can be used when the ideal ones are unavailable.
* Expose text-occlusion-opacity, icon-occlusion-opacity, line-occlusion-opacity, model-front-cutoff, lineZOffset as experimental.
* Add min/max/default values for most of the style properties.
* Fix compilation of Examples and MapboxMaps in Xcode 16

## 11.5.0-beta.1 - 11 June, 2024

* Improve stability of symbol placement when using `FollowPuckViewportState`.
* Expose `clusterMinPoints` property for `GeoJSONSource` and for `ClusterOptions`
* Root properties (`Atmosphere`, `Lights`, `Projection`, `Terrain`, `Transition`) are now revertible for all styles.
* Introduce raster particles rendering example
* Bump core maps version to 11.5.0-beta.1 and common sdk to 24.5.0-beta.4
* Root properties (`Atmosphere`, `Lights`, `Projection`, `Terrain`, `Transition`) are now revertible for all styles.

## 11.4.0 - 22 May, 2024

* Live performance metrics collection. Mapbox Maps SDK v11.4.0 collects certain performance and feature usage counters so we can better benchmark the MapboxMaps library and invest in its performance. The performance counters have been carefully designed so that user-level metrics and identifiers are not collected.
* Bump core maps version to 11.4.0 and common sdk to 24.4.0

## 11.4.0-rc.2 - 15 May, 2024

* Bump core maps version to 11.4.0-rc.2 and common sdk to 24.4.0-rc.2

## 11.4.0-rc.1 - 8 May, 2024

* Added camera(for:) deprecation for several methods. Added  `CameraForExample` showcasing camera(for:) usageq
* Expose experimental `RasterParticleLayer` which is suitable for displaying precipitation or wind on the map
* Expose the list of added `ViewAnnotation`
* Bump core maps version to 11.4.0-rc.1 and common sdk to 24.4.0-rc.1.

## 11.4.0-beta.3 - 6 May, 2024

* Bump common sdk to 24.4.0-beta.3.

## 11.4.0-beta.2 - 2 May, 2024

* Bump core maps version to 11.4.0-beta.2 and common sdk to 24.4.0-beta.2.
* `MapboxMap.loadStyle()` and `Snapshotter.loadStyle()` behaviour is rolled back to pre 11.4.0-beta.1 state.

## 11.4.0-beta.1 - 24 April, 2024

⚠️⚠️⚠️ Known Issues ⚠️⚠️⚠️

* In v11.4.0-beta.1, setting a `RasterLayer`’s `rasterColor` property with an expression will block the layer from rendering. This issue will be resolved in v11.4.0-rc.1.

### Experimental API breaking changes ⚠️

In this release, we introduce the new [Declarative Styling API](https://docs.tilestream.net/ios/maps/api/latest/documentation/mapboxmaps/declarative-map-styling) for UIKit and SwiftUI. This change is based on `MapContent` introduced for SwiftUI; therefore, it has been restructured. The changes are compatible; however, in some rare cases, you may need to adjust your code.

* [SwiftUI] `MapContent` now supports custom implementations, similar to SwiftUI views. The `MapContent` protocol now requires the `var body: some MapContent` implementation.
* [SwiftUI] PointAnnotation and Puck3D property-setters that consumed fixed-length arrays reworked to use named properties or platform types for better readability:

```swift
// Before
PointAnnotation()
    .iconOffset([10, 20]) // x, y
    .iconTextFitPadding([1, 2, 3, 4]) // top, right, bottom, left
Puck3D()
    .modelScale([1, 2, 3]) // x, y, z

// After
PointAnnotation()
    .iconOffset(x: 10, y: 20)
    .iconTextFitPadding(UIEdgeInsets(top: 1, left: 4, bottom: 3, right: 2))
Puck3D()
    .modelScale(x: 1, y: 2, z: 3)
```

* `StyleImportConfiguration` was removed from public API, the `MapStyle` now contains the configuration directly.
* `TransitionOptions` is now a Swift `struct` rather than an Objective-C `class`.

### Features ✨ and improvements 🏁

* All the style primitives can now be used as `MapContent` in SwiftUI.

```swift
@_spi(Experimental) MapboxMaps
Map {
    LineLayer(id: "traffic")
        .lineColor(.red)
        .lineWidth(2)
}
```

* UIKit applications can now use the `setMapStyleContent` to use style primitives:

```swift
@_spi(Experimental) MapboxMaps
mapView.mapboxMap.setMapStyleContent {
    LineLayer(id: "traffic")
        .lineColor(.red)
        .lineWidth(2)
}
```

* Allow to assign slot to 2D and 3D location indicators.
* Allow observing start/stop event of `CameraAnimator`
  You can observe start/stop event of `CameraAnimator` by using new `CameraAnimationsManager` APIs as shown below

  ```swift
  // Observe start event of any CameraAnimator owned by AnimationOwner.cameraAnimationsManager
  mapView.camera
    .onCameraAnimatorStarted
    .owned(by: .cameraAnimationsManager)
    .observe { cameraAnimator in
      // Handle camera animation started here.
    }
    .store(in: &cancelables)
  // Observe finished events of any CameraAnimator
  mapView.camera
    .onCameraAnimatorFinished
    .observe { animator in
      // Handle camera animation stopped here.
    }
    .store(in: &cancelables)
  ```

  You can also observe directly on an instance of `CameraAnimator` when using low-level camera APIs to create a custom animator

  ```swift
  // Declare an animator that changes the map's bearing
  let bearingAnimator = mapView.camera.makeAnimator(duration: 4, curve: .easeInOut) { (transition) in
    transition.bearing.toValue = -45
  }
  bearingAnimator.onStarted.observe {
    // Bearing animator has started.
  }.store(in: &cancelables)
  ```

* Allow adding slots at runtime.
* Expose API to interact with style imports using Declarative Styling and regular imperative API.
* Expose `StyleImport` for declarative styling as `MapStyleContent`.
* Expose `removeStyleImport`, `moveStyleImport`, `updateStyleImport`, `addStyleImport` methods on `StyleManager`
* Allow assigning layerPosition to 2D and 3D location indicators in imperative API.
* Make Puck2D and Puck3D to be positioned according to relative layer position in declarative API instead of always top-most position.
* Add codesign for XCFrameworks.
* `MapboxMap.loadStyle()` and `Snapshotter.loadStyle()` now correctly call the `completion` closure.

## 11.3.0 - 10 April, 2024

### Features ✨ and improvements 🏁

* Introduce an experimental Style DSL, enabling developers to add map style content like Sources, Layers, Style Images, Terrain, Light and Atmosphere to their map style at runtime in a declarative pattern. See the documentation [here](https://docs.mapbox.com/ios/maps/api/11.2.0-beta.1/documentation/mapboxmaps/style-dsl) for more information. For SwiftUI users, this Style DSL provides a more natural approach to manipulating content.
[tile store] Expose API for estimating Tile Region downloads and storage size.

## 11.3.0-rc.1 - 27 March, 2024

* [tile store] Expose API for estimating Tile Region downloads and storage size.
* Remove metal view's contentScaleFactor assertion.
* Bump core maps version to 11.3.0-rc.1 and common sdk to 24.3.0-rc.1.

## 11.3.0-beta.1 - 14 March, 2024

* Update the minimum Xcode version to 15.2 (Swift 5.9).
* Add `onClusterTap` and `onClusterLongPress` to AnnotationManagers(UIKit) and AnnotationGroups(SwiftUI) which support clustering
* Add annotations drag handlers callbacks `dragBeginHandler`, `dragChangeHandler`, `dragEndHandler` to all Annotation types.
* [SwiftUI] Expose `captureSnapshot` on `MapProxy` which allows to capture SwiftUI Map snapshot using `MapReader`
* [SwiftUI] Expose `opaque` and `frameRate` on SwiftUI Map
* [SwiftUI] Add `allowHistTesting` modifier on `MapViewAnnotation`.
* [SwiftUI] Fix view annotations positioning on `.ignoresSafeArea(.all)`
* Add `includeOverlays` parameter to `MapView.snapshot()`
* Fix taps propagation on `ViewAnnotation` and `MapViewAnnotation`.
* Added Attribution and Telemetry pop-up dialogs and compass view content description translations for Arabic, Belarusian, Bulgarian, Catalan, Chinese Simplified, Chinese Traditional, Czech, Danish, Dutch, French, Galician, German, Hebrew, Italian, Japanese, Korean, Lithuanian, Norwegian, Polish, Belarusian, Russian, Spanish, Swedish, Ukranian and Vietnamese.
* Bump core maps version to 11.3.0-beta.1 and common sdk to 24.3.0-beta.1.

## 11.2.0 - 28 February, 2024

* Bump core maps version to 11.2.0 and common sdk to 24.2.0.

## 11.2.0-rc.1 - 15 February, 2024

### Bug fixes 🐞

* Fix Map and encompassing List scroll at the same time
* visionOS small enhancements

## 11.2.0-beta.1 - 1 February, 2024

### Features ✨ and improvements 🏁

* vision OS support. 🚀
* Add easing curve parameter to `CameraAnimationsManager.fly(to:duration:curve:completion)`, make `TimingCurve` public with few more options.
* Expose `MapboxMap.centerAltitudeMode` and ensure correct `centerAltitudeMode` on gesture ending.
* Expose extra configuration methods for `MapboxMap`: `setNorthOrientation(_:)`, `setConstrainMode(_:)` and `setViewportMode(_:)`.
Use them to configure respective map options after creating a map view.
* Expose `MapboxMap.reduceMemoryUse()` which can be used in situations when it is important to keep the memory footprint minimal.
* Expose `MapboxMap.isAnimationInProgress` and `MapboxMap.isGestureInProgress` to query current status of both built-in and custom camera animations and gestures.
* Expose experimental `CustomRasterSource` and non-experimental `CustomGeometrySource` as regular `Source`'s providing a better way to work with them and also allow for using them in Style DSL.
* Introduce `tileCacheBudget` property on `GeoJsonSource`, `RasterSource`, `RasterDemSource`, `RasterArraySource`, `VectorSource`, `CustomGeometrySource`, and `CustomRasterSource`.
* `MapboxMaps/setTileCacheBudget(size:)` will now use the `TileCacheBudgetSize` property, the older method with `TileCacheBudget` has been deprecated and will be removed in a future major release.
* Introduce `SymbolLayer.iconColorSaturation` API.
* Introduce experimental `RasterLayer.rasterElevation` API.
* Introduce experimental `MapboxMap.collectPerformanceStatistics` allowing to collect map rendering performance statistics, both for UIKit and SwiftUI.

### Bug fixes 🐞

* Fix MapView flickering during resizing.
* Fix glitch in chained camera animations.
* Build XCFramework with `SWIFT_SERIALIZE_DEBUGGING_OPTIONS=NO` flag to avoid serialized search paths in Swift modules.
* Fixed a crash that occurs when annotations have duplicate identifiers.

### Dependency Updates

* Bump Turf version to `2.8.0`.
* Bump minimum Xcode version to `14.3.1`.

## 11.1.0 - 17 January, 2024

* Add `customData` field in Annotaion and deprecate `userInfo`. `userInfo` behaviour rolled back to v10 behaviour.
* Fixed a bug where the attribution dialog does not appear when there is a presented view controller.
* Make padding optional in `MapboxMap.camera(for:padding:bearing:pitch:maxZoom:offset:)` and `MapboxMap.camera(for:padding:bearing:pitch:)`.
* Update CoreMaps to 11.1.0 and Common to 24.1.0

## 11.1.0-rc.1 - 04 January, 2024

### Bug fixes 🐞

* Fix the bug where the annotation could disappear when it is dragged.

## 11.1.0-beta.1 - 19 December, 2023

⚠️⚠️⚠️ Known Issues ⚠️⚠️⚠️

* `RasterArraySource.rasterLayers` is always `nil` for any source.
Workaround: use `MapboxMap.sourceProperty(for:property:).value` to fetch a value of `RasterArraySource.rasterLayers`.

* Expose method to get coordinate info for point(s): `MapboxMap.coordinateInfo(for:)` and `MapboxMap.coordinatesInfo(for:)`.
* [SwiftUI] Expose `Map.gestureHandlers()` for handling Map gesture events.
* Introduce experimental `RasterArraySource`, along with `RasterLayer.rasterArrayBand`.
* Introduce `-emissiveStrength` attribute for `FillExtrusionLayer`, `HillShadeLayer` and `RasterLayer`.
* Update MapboxCoreMaps to v11.1.0-beta.1 and MapboxCommon to v24.1.0-beta.2

## 11.0.0 - 29 November, 2023

* Introduce [`Slot`](https://docs.mapbox.com/ios/maps/api/11.0.0-rc.2/documentation/mapboxmaps/slot/) for assigning a layer to a slot.
* Update MapboxCoreMaps to v11.0.0 and MapboxCommon to v24.0.0

## 11.0.0-rc.2 - 17 November, 2023

### Breaking changes ⚠️

* Note: SwiftUI support is an experimental feature, its API may be changed until it stabilizes.

* [SwiftUI] Fixed point annotations clustering.
* [SwiftUI] Viewport inset system was refactored:
  * The `Viewport.inset(...)` function was removed in favor of the `Viewport.padding(...)`
  * The `Viewport.inset(...)` previously had an `ignoringSafeArea` parameter which allowed developers to specify if an edge safe area inset should be accounted for in padding calculation. Starting with this version, instead of this parameter there is a `Map.usesSafeAreaInsetsAsPadding(_:)` modifier that enables or disables this for all edges.

### Features ✨ and improvements 🏁

* [SwiftUI] New `Map.additionalSafeAreaInsets(...)` modifier that adds additional global safe area insets for the map. Use them to display any UI elements on top of the map. The additional safe area will automatically be accounted for in camera padding calculation in every Viewport.
* Added `allowOverlapWithPuck` and `ignoreCameraPadding` options to `ViewAnnotation` and `MapViewAnnotation`.

### Bug fixes 🐞

* [SwiftUI] Fix bug when `Viewport.inset(...)` didn't use safe area insets on the first load.
* [SwiftUI] Fix map basic coordinator clinging to the first subscriptions.

## 11.0.0-rc.1 - 3 November, 2023

### Breaking changes ⚠️

* `MapboxMap.loadStyle` methods changed error type from `MapLoadingError` to `Error`.
* `OverviewViewportStateOptions.coordinatesPadding` is renamed to `OverviewViewportStateOptions.geometryPadding`.
* [SwiftUI] ``Viewport.overview(geometry:bearing:pitch:coordinatesPadding:maxZoom:offset:)` is renamed to `Viewport.overview(geometry:bearing:pitch:geometryPadding:maxZoom:offset:)`
* Bearing indication on user location puck is disabled by default to reduce amount map redraws.
    To re-enable bearing update rendering, set `mapView.location.options.puckBearingEnabled` to `true`.
* The default behavior of resetting the viewport to idle is changed. Previously viewport was reset to idle when the user touched the map for longer than 150 ms. Now it will happen when the user pans the map. If the desired behavior is different, you can disable the default by setting `mapView.viewport.options.transitionsToIdleUponUserInteraction` to `false` and implementing any gesture that calls `mapView.viewport.idle()`.

### Features ✨ and improvements 🏁

* Refactor `MapboxMap.loadStyle` to cancel previous style loads when called multiple times.
* New experimental `StyleManager.load(mapStyle:transition:completion)` method to load `MapStyle` in `MapboxMap`, or `Snapshotter`:

  ```swift
  mapboxMap.load(mapStyle: .standard(lightPreset: .dawn, showRoadLabels: false)) { _ in
    print("Style is loaded")
  }
  ```

* Support `slot` for annotation managers and annotation groups.
* [SwiftUI] Annotation groups can be created with static list of annotations. In the example below polyline annotation group displays two annotations on the same layer.

  ```swift
  Map {
      PolylineAnnotationGroup {
          PolylineAnnotation(lineCoordinates: route.coordinates)
              .lineColor("blue")
          if let alternativeRoute {
              PolylineAnnotation(lineCoordinates: alternativeRoute.coordinates)
                  .lineColor("green")
          }
      }
      .lineCap(.round)
      .slot("middle")
  }
  ```

* [SwiftUI] Expose `transitionsToIdleUponUserInteraction` modifier.
* Introduce typed API for assining a layer to a slot.
* Introduce `Slot` for assining a layer to a slot.
* Introduce [`Slot`](https://docs.mapbox.com/ios/maps/api/11.0.0-rc.1-docc/documentation/mapboxmaps/slot) for assigning a layer to a slot.

### Bug fixes 🐞

* Fix issue where 2D puck images are not getting updates.
* [SwiftUI] Fixed issue when viewport inset with safe area is calculated incorrectly.
* Fixed issue when quick interaction didn't lead to resetting viewport to `idle`.

## 11.0.0-beta.6 - 23 October, 2023

### Breaking changes ⚠️

* Style projection can be undefined for styles that do not explicitly specify it, so `MapboxMap.projection` has become optional.
* View Annotation API is changed:
  * `ViewAnnotationOptions.geometry` was removed in favor of `ViewAnnotationOptions.annotatedFeature`.
  * `ViewAnnotationOptions.associatedFeatureId` was removed. Use `AnnotatedFeature.layerFeature(layerId:featureId:)` with `ViewAnnotationOptions.annotatedFeature` to bind View Annotation to features rendered by any layer.
  * [SwiftUI] Use `MapViewAnnotation` instead of `ViewAnnotation` to display view annotations in SwiftUI.
* `OverviewViewportStateOptions.padding` is renamed to `OverviewViewportStateOptions.coordinatePadding`, the `OverviewViewportStateOptions.padding` now represents the camera padding.

### Features ✨ and improvements 🏁

* New `ViewAnnotation` class is added for simplifying View Annotation management. It is a simple to use replacement for the old `ViewAnnotationOptions`. It automatically updates size and other properties of annotations, and provides new features:
  * Automatic anchor position from specified `ViewAnnotation.variableAnchor` configurations.
  * Supports displaying not only at point features, but also at lines and polygons.
* Support Dynamic View Annotations in SwiftUI.
* Add `MapboxMaps.camera(for:camera:coordinatesPadding:maxZoom:offset)`.
* Add `MapViewDebugOptions.padding` debug option.
* Add `maxZoom` and `offset` parameters to `OverviewViewportStateOptions`.

### Bug fixes 🐞

* Fix issue when transition to Overview Viewport resulted in double padding.
* [SwiftUI] Fix issue when Overview Viewport is incorrect if set as initial viewport.

## 11.0.0-beta.5 - 9 October, 2023

* Add a new CustomLayer API to simplify manipulation of layers with custom rendering (aka "CustomLayerHost").
* The following APIs have been promoted to stable:
  * `LineLayer/lineDepthOcclusionFactor`, `LineLayer/lineDepthOcclusionFactorTransition`, `LineLayer/lineEmissiveStrength` and `LineLayer/lineEmissiveStrengthTransition`
  * `SymbolLayer/iconImageCrossFade`, `SymbolLayer/iconImageCrossFadeTransition`, `SymbolLayer/iconEmissiveStrength`, `SymbolLayer/iconEmissiveStrengthTransition`, `SymbolLayer/textEmissiveStrength` and `SymbolLayer/textEmissiveStrengthTransition`
  * `BackgroundLayer/backgroundEmissiveStrength` and `BackgroundLayer/backgroundEmissiveStrengthTransition`
  * `CircleLayer/circleEmissiveStrength` and `CircleLayer/circleEmissiveStrengthTransition`
  * `FillLayer/fillEmissiveStrength` and `FillLayer/fillEmissiveStrengthTransition`
  * `AmbientLight`, `DirectionalLight` and related APIs.
* Fix memory leak in SwiftUI.
* Expose `MapViewDebugOptions` in SwiftUI.

## 11.0.0-beta.4 - 20 September, 2023

### Breaking changes ⚠️

* `StyleColor.red`, `StyleColor.green`, `StyleColor.blue`, `StyleColor.alpha` are not in use anymore and got removed.
* The `syncSourceAndLayerIfNeeded` method in every annotation manager (e.g`PointAnnotationManager` and others) was removed from the public API.

### Features ✨ and improvements 🏁

* Add MSAA support with the `MapInitOptions/antialiasingSampleCount` property.
* `StyleColor` - add support for all color formats as defined by [Mapbox Style Spec](https://docs.mapbox.com/style-spec/reference/types/#color).
* Introduce experimental Custom Raster Source APIs: `StyleManager/addCustomRasterSource`, `StyleManager/setCustomRasterSourceTileData`, `StyleManager/invalidateCustomRasterSourceTile`, `StyleManager/invalidateCustomRasterSourceRegion`.
* Introduce new Map Content Gesture System.
* Add an experimental `MapView/cameraDebugOverlay` which returns a UIView displaying the current state of the camera.
* Add `MapView/debugOptions` which wraps the debugOptions on the underlying map in `MapViewDebugOptions`. An additional `.camera` debug option has been added, which adds a `CameraDebugView` to the map to see the current camera state. `MapboxMap/debugOptions` has been deprecated; access the underlying map debug options through `mapView.debugOptions.nativeDebugOptions` instead.

## 11.0.0-beta.3 - 8 September, 2023

### Breaking changes ⚠️

* `MapboxMap.dragStart()` and `MapboxMap.dragEnd()` are not in use anymore and got removed.
* Remove `MapOptions/optimizeForTerrain` option. Whenever terrain is present layer order is automatically adjusted for better performance.

### Features ✨ and improvements 🏁

* Improve map camera and gestures when terrain is used to fix camera bumpiness and map flickering.
* Expose a method to remove tile region with a completion: `TileStore.removeTileRegion(forId:completion:)`.
* Bump core maps version to 11.0.0-beta.4 and common sdk to 24.0.0-beta.4.

### Bug fixes 🐞

* Fix `modelCastShadows` and `modelReceiveShadows` options of `Puck3DConfiguration` being ignored.
* Fix `StyleColor` failing to initialize with non-sRGB color spaces by converting supplied `UIColor`s to `sRGB` color space by default.

## 11.0.0-beta.2 - 23 August, 2023

* Introduce experimental `MapboxRecorder`, which allows recording of the map and replaying custom scenarios.
* Expose `slot` property on `Layer` protocol.
* Bump core maps version to 11.0.0-beta.3 and common sdk to 24.0.0-beta.3.
* Add privacy policy attribution dialog action.

## 11.0.0-beta.1 - 2 August, 2023

* Introduce `hsl`, `hsla` color expression.
* Introduce `random` expression.
* Introduce `measureLight` expression lights configuration property.
* Introduce `LineLayer/lineBorderColor`, `LineLayer/lineBorderWidth` APIs.
* Introduce `SymbolLayer/iconImageCrossFade` API.
* Introduce experimental `BackgroundLayer/backgroundEmissiveStrength`, `CircleLayer/circleEmissiveStrength`, `FillLayer/fillEmissiveStrength`, `LineLayer/lineEmissiveStrength`, `SymbolLayer/iconEmissiveStrength`, `SymbolLayer/textEmissiveStrength`, `ModelLayer/modelEmissiveStrength`, `ModelLayer/modelRoughness`, `ModelLayer/modelHeightBasedEmissiveStrengthMultiplier` APIs.
* Introduce experimental `FillExtrusionLayer/fillExtrusionAmbientOcclusionWallRadius`, `FillExtrusionLayer/fillExtrusionAmbientOcclusionGroundRadius`, `FillExtrusionLayer/fillExtrusionAmbientOcclusionGroundAttenuation`, `FillExtrusionLayer/fillExtrusionFloodLightColor`, `FillExtrusionLayer/fillExtrusionFloodLightIntensity`, `FillExtrusionLayer/fillExtrusionFloodLightWallRadius`, `FillExtrusionLayer/fillExtrusionFloodLightGroundRadius`, `FillExtrusionLayer/fillExtrusionFloodLightGroundAttenuation`, `FillExtrusionLayer/fillExtrusionVerticalScale` APIs.
* Rename `Viewport` to `ViewportManager`.
* Apply `ModelScaleMode.viewport` to Puck3D configuration and remove the custom expression for the `modelScale` of the puck. This means if you are using a constant for `Puck3DConfiguration/modelScale` in v10, you need to adjust this model-scale constant so the puck would be rendered correctly in v11, while this value depends on other configurations of your puck, we have found the new adjusted model-scale to fall between 10x-100x of the old value.
* Add experimental `tileCover` method to the `Snapshotter` that returns tile ids covering the map.
* Add optional `maxZoom` and `offset` parameters to `MapboxMap.camera(for coordinateBounds:)`. `MapboxMap.camera(for coordinateBounds:)`, `MapboxMap.camera(for coordinates:)`, and `MapboxMap.camera(for geometry:)` no longer return a padding value.
* `Location` is splitted into `Location` and `Heading` structs, the location and heading data are now animated individually.
* Replace `loadStyleJSON(_:completion:)`/`loadStyleJSON(_:completion:)` with overloaded `loadStyle(_:completion:)`.
* Mark `Expression.Operator.activeAnchor` as experimental.
* Add transition options as a parameter to `loadStyle(...)` methods.
* `Expression.Operator` is now a struct with static variables instead of enum.
* Add `MapboxMap.coordinate(s)Info(for:)` for converting offscreen points into geographical coordinates.
* Fixed an issue when `MapboxMap.point(for:)` could return false negative result.
* Remove `source`, `sourceLayer`, `filter` properties from the `Layer` protocol requirement.
* Bump core maps version to 11.0.0-beta.1.
* Refactor style Light API: introduce `AmbientLight`, `DirectionalLight`, `FlatLight` and methods to set them.
* Add expression support to `Layer.visibility`.
* Expose new APIs for working with style importing and configuration: getStyleImports(), removeStyleImport(forImportId:), getStyleImportSchema(forImportId:), getStyleImportConfigProperties(forImportId:), setStyleImportConfigPropertiesForImportId(_:configs:), getStyleImportConfigProperty(forImportId:config:), setStyleImportConfigPropertyForImportId(_:config:value:)
* Expose `slot` property for all `Layer`s to link layers from imported styles.
* Convert Style properties enums into structs.
* Bump core maps version to 11.0.0-beta.2 and common sdk to 24.0.0-beta.2.
* Remove MetaKit reexport.

## 11.0.0-alpha.2 - 21 June, 2023

* Remove unnecessary check before updating a geo json source.
* Remove deprecated `LocationManager.updateHeadingForCurrentDeviceOrientation()` method.
* Remove deprecated `MapEvents.EventKind`.
* Make NSNumber extension internal.
* Remove experimental `MapboxMap.setRenderCache(_:)` method.
* Remove deprecated `GestureOptions.pinchRotateEnabled`.
* Remove deprecated `Location` initializer.
* Remove deprecated transition properties from layers.
* Make `easeTo/flyTo` return non-optional cancelable token.
* Add `rotation` case to `GestureType` to be able to detect rotation separately from other gestures.
* Enable zoom during a drag gesture.
* Fix bearing value is fluctuating between initial value and correct value during a rotation gesture.
* Allows animation during any ongoing gestures.
* Sync map size to the size of the metal view.
* Fix missing feature properties for `nil`/`null` values.
* Added experimental `tileCover` method to `MapboxMap` that returns tile ids covering the map.
* Expose `owner` property for `CameraAnimator` protocol
* Updated core styles to the latest versions.
* Merge `TilesetDescriptorOptions` and `TilesetDescriptorOptionsForTilesets`. To enable tileset descriptor creation for a list of tilesets that are not part of the original style use `TilesetDescriptorOptions`.
* Use `DataRef` to pass snapshot and style image data by reference, improving performance
* Bumped min iOS version to 12.0
* Expose a subset of ModelLayer APIs.
* Protocol `LocationProvider` now requires class semantic for implementation.
* The Map events have been reworked:
  * Now all Map events payloads are serialize-free, which brings more type safety and eliminates possible deserialization errors;
  * The `MapboxMap` and `Snapshotter` now expose `on`-prefixed properties that allows you to subscribe to map events via `observe` and `observeNext` methods:

    ```swift
    mapboxMap.onCameraChanged.observe { [weak self] event in
      self?.camera = event.cameraState
    }.store(in: &cancelables)

    mapboxMap.onStyleLoaded.observeNext { [weak self] _ in
      self?.configureStyle()
    }.store(in: &cancelables)
    ```

  * The `AnyCancelable` object returned from `observe` and `observeNext` should be stored, otherwise the subscription will be immediately canceled;
  * The same `on`-prefixed properties can now be used as `Combine.Publisher`:

    ```swift
    import Combine
    mapboxMap.onCameraChanged
      .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
      .map(\.cameraState)
      .sink { [weak self] cameraState in
        self?.camera = cameraState
      }.store(in: &cancellables)
    ```

  * Methods `MapboxMap.onEvery`, `MapboxMap.onNext`, `Snapshotter.onEvery`, `Snapshotter.onNext` have been deprecated;
  * Methods `MapboxMap.observe` and `Snapshotter.observe` have been removed.
* Deprecate `PointAnnotationManager.iconTextFit` and `PointAnnotationManager.iconTextFitPadding` in favor of `PointAnnotation.iconTextFit` and `PointAnnotation.iconTextFitPadding`.
* Remove deprecated `PuckBearingSource`and related APIs.
* Experimental API `MapboxMap/setMemoryBudget` was renamed to `MapboxMaps/setTileCacheBudget` and promoted to stable.
* Location consumer methods have been renamed to align with Swift API Design Guidelines. Use `addLocationConsumer(_:)` and `removeLocationConsumer(_:)` rather than `addLocationConsumer(newConsumer:)` and `removeLocationConsumer(consumer:)`.
* `SourceType` and `LayerType` are now structs with static variables instead of enums
* Remove `ResourceOptions` and `ResourceOptionsManager`. Introduce `MapboxOptions` and `MapboxMapsOptions` to handle application-level access token and other generic options.
  * Mapbox's access token can now be set with `MapboxCommon.MapboxOptions`. By default, MapboxMaps SDK will try to read the access token from app bundle's property list or `MapboxAccessToken` file when Maps service are initialized; if you wish to set access token programmatically, it is highly recommended to set it before initializing a `MapView`.

    ```swift
    import MapboxMaps

    MapboxOptions.accessToken = accessToken
    ```

  * `TileStore`no longer requires `TileStoreOptions.mapboxAccessToken` to be explicitly set.
  * Configurations for the external resources used by Maps API can now be set with `MapboxMapsOptions`:

    ```swift
    import MapboxMaps

    MapboxMapsOptions.dataPath = customDataPathURL
    MapboxMapsOptions.assetPath = customAssetPathURL
    MapboxMapsOptions.tileStoreUsageMode = .readOnly
    MapboxMapsOptions.tileStore = tileStore
    ```

  * To clear the temporary map data, you can use `MapboxMap.clearData(completion:)`
* Expose new 3D Lights API: `AmbientLight` and `DirectionalLight`.
* `TypeConversionError`, `SnapshotError`, and `ViewAnnotationManagerError` are now structs with static variables instead of enums
* Extend `Layer` protocol with `visibility` property.
* Add required `id` property to `Source`. After that change `id` should be specified for source upon creation:

  ```swift
  let terrainSource = RasterDemSource(id: "terrain-source")
  mapView.mapboxMap.addSource(terrainSource)
  ```

* Support string option in `GeoJSONSourceData`.
* Allows passing `extraOptions` (which must be a valid JSON object) when creating `StylePackLoadOptions`and `TilesetDescriptorOptions`.
* Deprecate `MapboxMap/style` and `Snapshotter/style`, from now on you can access Style APIs directly from `MapboxMap` and `Snapshotter` instance.
* Add a new API to enable Tracing with `Tracing.status = .enabled`. Checkout `Tracing` reference to see more.
* Introduce `FillExtrusionLayer.fillExtrusionRoundedRoof` , `FillExtrusionLayer.fillExtrusionEdgeRadius` API.
* Introduce `line-depth-occlusion` API.
* Introduce `FillExtrusionLayer/fillExtrusionRoundedRoof`, `FillExtrusionLayer/fillExtrusionEdgeRadius` API.
* Introduce `lineDepthOcclusionFactor` API for `LineLayer`s and `PolylineAnnotiationManager`.
* Add `Codable` support to `CameraOptions`, `CameraState`, `FollowPuckViewportStateBearing`, `FollowPuckViewportStateOptions`.
* Expose new Style APIs for partial GeoJSON update:

```swift
MapboxMap.addGeoJSONSourceFeatures(forSourceId:features:dataId:)
MapboxMap.updateGeoJSONSourceFeatures(forSourceId:features:dataId:)
MapboxMap.removeGeoJSONSourceFeatures(forSourceId:featureIds:dataId:)
```

## 10.15.0 - July 27, 2023

* Update MapboxCoreMaps to 10.15.0 and MapboxCommon to 23.7.0.
* Fixed an issue when `MapboxMap.point(for:)` could return false negative result.

## 10.15.0-rc.1 - July 13, 2023

* Update MapboxCoreMaps to 10.15.0-rc.1 and MapboxCommon to 23.7.0-rc.1.
* Fixed an issue when `MapboxMap.point(for:)` could return false negative result.

## 10.15.0-beta.1 - June 29, 2023

* Remove unneeded synthesized initializers
* Update MapboxCoreMaps to 10.15.0-beta.1 and MapboxCommon to 23.7.0-beta.1.

## 10.14.0 - June 14, 2023

* Added experimental `tileCover` method to the `Snapshotter` that returns tile ids covering the map.
* Update MapboxCoreMaps to 10.14.0 and MapboxCommon to 23.6.0.

## 10.14.0-rc.1 - May 31, 2023

* Fix the issue with simultaneous zooming/panning during the pitch gesture.
* Fix the issue with black MapView when transparent style is used.
* Update MapboxCoreMaps to 10.14.0-rc.1 and MapboxCommon to 23.6.0-rc.1.

## 10.14.0-beta.1 - May 17, 2023

* Add a renamed flag to `PuckBearingSource` and related APIs.
* Update MapboxCoreMaps to 10.14.0-beta.1 and MapboxCommon to 23.6.0-beta.1.

## 10.13.1 - May 5, 2023

* Remove XCFramework binary dependency on MapboxMobileEvents.
* Update MapboxCoreMaps to 10.13.1 and MapboxCommon to 23.5.0
* [CarPlay] Fix display link is not correctly paused/resumed when map is added to a CarPlay dashboard scene.

## 10.13.0-rc.1 - April 19, 2023

* Update MapboxCoreMaps to 10.13.0-rc.1 and MapboxCommon to 23.5.0-rc.1.

## 10.13.0-beta.1 - April 5, 2023

* Remove unnecessary check before updating a geo json source.
* Enable zoom during a drag gesture.
* Fix bearing value is fluctuating between initial value and correct value during a rotation gesture.
* Allows animation during any ongoing gestures.
* Sync map size to the size of the metal view.
* Fix visual jitter when an annotation dragging ends.
* Fix missing feature properties for `nil`/`null` values.
* Added experimental `tileCover` method to `MapboxMap` that returns tile ids covering the map.
* Update MapboxCoreMaps to 10.13.0-beta.1 and MapboxCommon to 23.5.0-beta.1.

## 10.12.1 - March 29, 2023

* Bump MapboxCoreMaps to 10.12.1

## 10.12.0 - March 22, 2023

* Deprecate `Snapshotter.tileMode`.
* Bump MapboxCoreMaps to 10.12.0 and MapboxCommon to 23.4.0

## 10.12.0-rc.1 - March 8, 2023

* Correct user-agent fragment sent to events/telemetry service.
* Bump MapboxCoreMaps to 10.12.0-rc.1 and MapboxCommon to 23.4.0-rc.1.
* Change annotation end-of-drag delay to 0.125 to minimize lagging.
* Different data types are now used for `querySourceFeatures` and `queryRenderedFeatures`: `QueriedSourceFeature` and `QueriedRenderedFeature`. `QueriedRenderedFeature` has a new field `layer` which contains the queried feature's layer id.
* Remove deprecated `queryRenderedFeatures()` methods. Use `queryRenderedFeatures(with:options:completion:)` instead.
* Remove deprecated `queryFeatureExtension()` method. Use `getGeoJsonClusterLeaves()`/`getGeoJsonClusterChildren()`/`getGeoJsonClusterExpansionZoom()` instead.
* Add the `MapboxMap.resetFeatureState` method.
* Add `callback` argument to the `MapboxMap` methods `getFeatureState`, `setFeatureState`, `removeFeatureState`.
* Return `cancelable` from the `MapboxMap` methods : `getFeatureState`, `setFeatureState`, `removeFeatureState`, `querySourceFeatures`, `getGeoJsonClusterLeaves`, `getGeoJsonClusterChildren`, `getGeoJsonClusterExpansionZoom`.
* The `CameraOptions/padding` field is now optional.

## 10.12.0-beta.1 - February 22, 2023

* Added basic signposts for performance profiling. To enable them, use `MAPBOX_MAPS_SIGNPOSTS_ENABLED` environment variable. ([#1818](https://github.com/mapbox/mapbox-maps-ios/pull/1818))
* Fix build erros appearing when SDK distributed as a static library through Cocoapods. ([#1888](https://github.com/mapbox/mapbox-maps-ios/pull/1888))
* Update MapboxCoreMaps to `v10.12.0-beta.1` and MapboxCommon to `v23.4.0-beta.1`
* Fix app extension support. ([#1916](https://github.com/mapbox/mapbox-maps-ios/pull/1916))
* Allow pass `dataId` to `sourceDataLoaded` event.
* Add a dedicated GestureRecognizer (and Handler) to interrupt deceleration animation on tap on the map.

## 10.11.0 - February 8, 2023

* Update to MapboxCoreMaps 10.11.1 and MapboxCommon 23.3.1. ([#1899](https://github.com/mapbox/mapbox-maps-ios/pull/1899))

## 10.11.0-rc.1 - January 26, 2023

* Improve stability of attribution parsing. ([#1849](https://github.com/mapbox/mapbox-maps-ios/pull/1849))
* Enable `Expression` to be created without an operator so `clusterProperties` can support advanced use cases. ([#1855](https://github.com/mapbox/mapbox-maps-ios/pull/1855))
* Update CoreMaps `10.11.0-rc.1` and CommonSDK `23.3.0-rc.1`. ([#1856](https://github.com/mapbox/mapbox-maps-ios/pull/1875))
* Angle normalization function was improved to prevent map spinning on close angles. ([#1828](https://github.com/mapbox/mapbox-maps-ios/pull/1828))

## 10.11.0-beta.1 - January 12, 2023

* Reduce CPU usage/energy consumption whem map idling while showing user location. ([#1789](https://github.com/mapbox/mapbox-maps-ios/pull/1789))
* Fix loading errors appearing when providing custom endpoint for `ResourceOptions.baseURL`. ([#1749](https://github.com/mapbox/mapbox-maps-ios/pull/1749))
* Remove delegate requirement for annotation interaction. ([#1750](https://github.com/mapbox/mapbox-maps-ios/pull/1750))
* Reset compass image to default one if `nil` was passed to the `MapboxCompassOrnamentView.updateImage(image:)`. ([#1766](https://github.com/mapbox/mapbox-maps-ios/pull/1766), [#1772](https://github.com/mapbox/mapbox-maps-ios/pull/1772))
* Prevent `PointAnnotationManager` to remove images that are not owned by it from Style. ([#1775](https://github.com/mapbox/mapbox-maps-ios/pull/1775))
* Use `sdf` parameter when adding a style image. ([#1803](https://github.com/mapbox/mapbox-maps-ios/pull/1803))
* Fix scale bar grows beyond its maximum width at large zoom near north/south poles. ([#1802](https://github.com/mapbox/mapbox-maps-ios/pull/1802))
* Improve GeoJSONSource add/update performance by passing `GeoJSONSourceData` directly. ([#1815](https://github.com/mapbox/mapbox-maps-ios/pull/1815))
* Support `Expression` in `FormatOptions`. ([#1826](https://github.com/mapbox/mapbox-maps-ios/pull/1826))
* Update to MapboxCoreMaps 10.11.0-beta.1 and MapboxCommon 23.3.0-beta.1. ([#1842](https://github.com/mapbox/mapbox-maps-ios/pull/1842))

## 10.10.1 - December 20, 2022

* [CarPlay] Fix map view permanently pausing when moving to window on foreground ([#1808](https://github.com/mapbox/mapbox-maps-ios/pull/1808))

## 10.10.0 - December 8, 2022

* Update CoreMaps and CommonSDK. ([#1777](https://github.com/mapbox/mapbox-maps-ios/pull/1777))

## 10.10.0-rc.1 - November 18, 2022

* Fix memory leak when viewport is being deallocated while transition is running. ([#1691](https://github.com/mapbox/mapbox-maps-ios/pull/1691))
* Fix issue with simultaneous recognition of tap gesture. ([#1712](https://github.com/mapbox/mapbox-maps-ios/pull/1712))
* Fix label localization to properly handle Simplified and Traditional Chinese. ([#1687](https://github.com/mapbox/mapbox-maps-ios/pull/1687))
* Allow simultaneous recognition of map- and annotation- handling gesture recognizers. ([#1737](https://github.com/mapbox/mapbox-maps-ios/pull/1737))
* Update MapboxCommon to `v23.2.0-rc.3`. ([#1738](https://github.com/mapbox/mapbox-maps-ios/pull/1738))

## 10.10.0-beta.1 - November 4, 2022

* Animates to camera that fit a list of view annotations. ([#1634](https://github.com/mapbox/mapbox-maps-ios/pull/1634))
* Prevent view annotation being shown erroneously after options update.([#1627](https://github.com/mapbox/mapbox-maps-ios/pull/1627))
* Add an example animating a view annotation along a route line. ([#1639](https://github.com/mapbox/mapbox-maps-ios/pull/1639))
* Enable clustering of point annotations, add example of feature. ([#1475](https://github.com/mapbox/mapbox-maps-ios/issues/1475))
* Reduce location provider heading orientation update frequency. ([#1618](https://github.com/mapbox/mapbox-maps-ios/pull/1618))
* Expose the list of added view annotations. ([#1621](https://github.com/mapbox/mapbox-maps-ios/pull/1621))
* Fix `loadStyleURI/loadStyleJSON` completion being invoked more than once. ([#1665](https://github.com/mapbox/mapbox-maps-ios/pull/1665))
* Remove ornament position deprecation. ([#1676](https://github.com/mapbox/mapbox-maps-ios/pull/1676))
* Prevent map from being rendered on background. By aligning better with Scene lifecycle API, as well as, respecting scene/application activation status, rendering artifacts should no longer be an issue after app is coming from background.  ([#1675](https://github.com/mapbox/mapbox-maps-ios/pull/1675))
* Support `isDraggable` and `isSelected` properties for annotations. ([#1659](https://github.com/mapbox/mapbox-maps-ios/pull/1659))
* New API to load custom style JSON on the initilization of MapView. ([#1686](https://github.com/mapbox/mapbox-maps-ios/pull/1686))
* Update MapboxCoreMaps to `v10.10.0-beta.1` and MapboxCommon to `v23.2.0-beta.1`. ([#1680](https://github.com/mapbox/mapbox-maps-ios/pull/1680))
* Add API to enable/disable render of world copies. ([#1684](https://github.com/mapbox/mapbox-maps-ios/pull/1684))
* Avoid triggering assertion for the 3D puck layer when returning `allLayerIdentifiers`. ([#1650](https://github.com/mapbox/mapbox-maps-ios/pull/1650))

## 10.9.0 - October 19, 2022

* Update to MapboxCoreMaps 10.9.0 and MapboxCommon 23.1.0. ([#1652](https://github.com/mapbox/mapbox-maps-ios/pull/1652))

## 10.9.0-rc.1 - October 7, 2022

* Fix accuracy ring radius jumping when zooming the map in/out with `.reducedAccuracy` location authorization.([#1625](https://github.com/mapbox/mapbox-maps-ios/pull/1625))
* Fix behavior with initial view annotation placement.([#1604](https://github.com/mapbox/mapbox-maps-ios/pull/1604))
* Fix behavior where selected view annotation is not moved to correct z-order.([#1607](https://github.com/mapbox/mapbox-maps-ios/pull/1607))
* Update MapboxCoreMaps to `v10.9.0-rc.1`. ([#1630](https://github.com/mapbox/mapbox-maps-ios/pull/1630))
* Update MapboxCommon to `v21.1.0-rc.2`. ([#1630](https://github.com/mapbox/mapbox-maps-ios/pull/1630))

## 10.9.0-beta.2 - September 29, 2022

* Replace MapboxMobileEvents dependency with CoreTelemetry (part of MapboxCommon). ([#1379](https://github.com/mapbox/mapbox-maps-ios/pull/1379))

## 10.9.0-beta.1 - September 21, 2022

* Expose `ResourceRequest` properties publicly. ([#1548](https://github.com/mapbox/mapbox-maps-ios/pull/1548))
* Parse GeoJSON data on a background queue. ([#1576](https://github.com/mapbox/mapbox-maps-ios/pull/1576))
* Fix block retain cycle in `MapboxMap/observeStyleLoad(_:)`, from now on `loadStyleURI` and `loadStyleJSON` completion block will not be invoked when MapboxMap is deallocated. ([#1575](https://github.com/mapbox/mapbox-maps-ios/pull/1575))
* Remove `DictionaryEncoder` enforce nil encoding for nested level of the dictionary. ([#1565](https://github.com/mapbox/mapbox-maps-ios/pull/1565))
* Expose `distance-from-center` and `pitch` expressions. ([#1559](https://github.com/mapbox/mapbox-maps-ios/pull/1559))
* Expose location puck opacity. ([#1585](https://github.com/mapbox/mapbox-maps-ios/pull/1585))
* Update MapboxCoreMaps to v10.9.0-beta.1 and MapboxCommon to v23.1.0-beta.1. ([#1589](https://github.com/mapbox/mapbox-maps-ios/pull/1589))

## 10.8.1 - September 8, 2022

* Downgrade MME to 1.0.8. ([#1572](https://github.com/mapbox/mapbox-maps-ios/pull/1572))
* Update to MapboxCoreMaps 10.8.0 and MapboxCommon 23.0.0. ([#1564](https://github.com/mapbox/mapbox-maps-ios/pull/1564))

## 10.8.0 - September 8, 2022

 ⚠️ MapboxMaps SDK iOS v10.8.0 contained a defect. Although this bug had no known end-user impact, 10.8.0 should not be used in production and has been removed from availability. v10.8.1 resolves the issue and is a drop-in replacement.

## 10.8.0-rc.1 - August 24, 2022

* Apply mercator scale to 3D puck also when its `modelScale` is not specified. ([#1523](https://github.com/mapbox/mapbox-maps-ios/pull/1523))

## 10.8.0-beta.1 - August 11, 2022

* Expose image property for compass ornament. ([#1468](https://github.com/mapbox/mapbox-maps-ios/pull/1468))
* Expand scale bar range up to 15000 km/10000 miles. ([#1455](https://github.com/mapbox/mapbox-maps-ios/pull/1455))
* Add the ability to override scale bar units. ([#1473](https://github.com/mapbox/mapbox-maps-ios/pull/1473))
* Animate padding changes between 2 camera when used with `FlyToCameraAnimator`. ([#1479](https://github.com/mapbox/mapbox-maps-ios/pull/1479))
* Fix NaN latitude crash rarely happening in `CameraAnimationsManager.fly(to:duration:completion)`. ([#1485](https://github.com/mapbox/mapbox-maps-ios/pull/1485))
* Fix `Style.updateLayer(withId:type:update)` so resetting a layer's properties should work. ([#1476](https://github.com/mapbox/mapbox-maps-ios/pull/1476))
* Add the ability to display heading calibration alert. ([#1509](https://github.com/mapbox/mapbox-maps-ios/pull/1509))
* Add support for sonar-like pulsing animation around 2D puck. ([#1513](https://github.com/mapbox/mapbox-maps-ios/pull/1513))
* Support view annotation lookup by an identifier. ([#1512](https://github.com/mapbox/mapbox-maps-ios/pull/1512))

## 10.7.0 - July 28, 2022

* Update to MapboxCoreMaps 10.7.0 and MapboxCommon 22.1.0. ([#1492](https://github.com/mapbox/mapbox-maps-ios/pull/1492))
* Limit `MapboxMap.points(for:)` to the bounds of the map view, if the coordinate's point is beyond then return (-1, -1) for its corresponding point.([#1490](https://github.com/mapbox/mapbox-maps-ios/pull/1490))
* Remove experimental ModelLayer API. ([#1486](https://github.com/mapbox/mapbox-maps-ios/pull/1486))

## 10.7.0-rc.1 - July 14, 2022

* Add rotation threshold to prevent map from being rotated accidentally. ([#1429](https://github.com/mapbox/mapbox-maps-ios/pull/1429))
* Introduce `GestureOptions.simultaneousRotateAndPinchZoomEnabled` and deprecate `GestureOptions.pinchRotateEnabled` in favor of `GestureOptions.rotateEnabled`. ([1429](https://github.com/mapbox/mapbox-maps-ios/pull/1429))
* Expose public initializer for `TilesetDescriptorOptionsForTilesets`. ([#1431](https://github.com/mapbox/mapbox-maps-ios/pull/1431))
* Fix view annotation losing its feature association after update. ([#1446](https://github.com/mapbox/mapbox-maps-ios/pull/1446))
* Update CoreMaps to `10.7.0-rc.1`. ([#1456](https://github.com/mapbox/mapbox-maps-ios/pull/1456))

## 10.7.0-beta.1 - June 29, 2022

* Introduce `FillExtrusionLayer.fillExtrusionAmbientOcclusionIntensity` and `FillExtrusionLayer.fillExtrusionAmbientOcclusionRadius` properties for FillExtrusionLayer. ([1410](https://github.com/mapbox/mapbox-maps-ios/pull/1410))
* Introduce `PointAnnotation.textLineHeight` and deprecated `PointAnnotationManager.textLineHeight`, as `text-line-height` is data-driven property now. ([1410](https://github.com/mapbox/mapbox-maps-ios/pull/1410))
* Remove experimental annotation from Viewport API. ([#1392](https://github.com/mapbox/mapbox-maps-ios/pull/1392))
* Remove deprecated `animationDuration` parameter in `FollowPuckViewportStateOptions` initializer.([#1390](https://github.com/mapbox/mapbox-maps-ios/pull/1390))
* Deprecate existing QueryRenderedFeatures methods and add cancellable counterparts. ([#1378](https://github.com/mapbox/mapbox-maps-ios/pull/1378))
* Add well-formed(type-safe) map event types. ([#1362](https://github.com/mapbox/mapbox-maps-ios/pull/1362))
* Use MapboxCoreMaps API to move a Layer instead of manually removing the layer then adding it back. ([#1367](https://github.com/mapbox/mapbox-maps-ios/pull/1367))
* Expose API to get puck's location updates. ([#1365](https://github.com/mapbox/mapbox-maps-ios/pull/1365))
* Add example for simulating a route with vanishing effects. ([#1328](https://github.com/mapbox/mapbox-maps-ios/pull/1328))
* Expose transition properties for Atmosphere API. ([#1401](https://github.com/mapbox/mapbox-maps-ios/pull/1401))
* Fix Atmosphere API coding keys so engine can read the new values properly. ([#1401](https://github.com/mapbox/mapbox-maps-ios/pull/1401))
* Pause metal rendering earlier in app/scene life-cycle to address rendering artifacts when coming from background. ([#1402](https://github.com/mapbox/mapbox-maps-ios/pull/1402))
* Update to MapboxCoreMaps 10.7.0-beta.1 and MapboxCommon to 22.1.0-beta.1. ([#1415](https://github.com/mapbox/mapbox-maps-ios/pull/1415))

## 10.6.0 - June 16, 2022

* Update to MapboxCoreMaps 10.6.0 and MapboxCommon to 22.0.0. ([#1394](https://github.com/mapbox/mapbox-maps-ios/pull/1394))

## 10.6.0-rc.1 - June 2, 2022

* Update to MapboxCoreMaps 10.6.0-rc.1 and MapboxCommon 22.0.0-rc.2. ([#1368](https://github.com/mapbox/mapbox-maps-ios/pull/1368))
* Add mercator scale factor to 3D puck, so that the 3D puck size won't increase as latitude increases. ([#1347](https://github.com/mapbox/mapbox-maps-ios/pull/1347))

## 10.6.0-beta.2 - May 25, 2022

* Introduce ModelLayer experimental API to render 3D models on the map. ([#1348](https://github.com/mapbox/mapbox-maps-ios/pull/1348))

## 10.6.0-beta.1 - May 20, 2022

* Expose API to check whether an image exists in `Style`. ([#1297](https://github.com/mapbox/mapbox-maps-ios/pull/1297))
* Call `MapboxMap.reduceMemoryUse` when application goes to background. ([#1301](https://github.com/mapbox/mapbox-maps-ios/pull/1301))
* Update to MapboxMobileEvents v1.0.8. ([#1324](https://github.com/mapbox/mapbox-maps-ios/pull/1324))
* Enable explicit drawing behavior for metal view(call `draw()` explicitly instead of `setNeedsDisplay` when view's content need to be redrawn) again.([#1331](https://github.com/mapbox/mapbox-maps-ios/pull/1331))
* Update to MapboxCoreMaps 10.6.0-beta.3 and MapboxCommon 22.0.0-beta.1. ([#1335](https://github.com/mapbox/mapbox-maps-ios/pull/1335), [#1342](https://github.com/mapbox/mapbox-maps-ios/pull/1342))
* Add Atmosphere API ([#1329](https://github.com/mapbox/mapbox-maps-ios/pull/1329))
* Update SDK name in attribution action sheet. ([#1338](https://github.com/mapbox/mapbox-maps-ios/pull/1338))
* Revert tap target to original value. ([#1339](https://github.com/mapbox/mapbox-maps-ios/pull/1339))

## 10.5.0 - May 5, 2022

* Update to MapboxCoreMaps 10.5.1 and MapboxCommon 21.3.0. ([#1310](https://github.com/mapbox/mapbox-maps-ios/pull/1310), [#1313](https://github.com/mapbox/mapbox-maps-ios/pull/1313))
* Invoke animator completion handlers added after completion or cancellation. ([#1305](https://github.com/mapbox/mapbox-maps-ios/pull/1305))

## 10.5.0-rc.1 - April 20, 2022

* Add support for runtime source properties. ([#1267](https://github.com/mapbox/mapbox-maps-ios/pull/1267))
* Start location services lazily. ([#1262](https://github.com/mapbox/mapbox-maps-ios/pull/1262))
* Fix localization crash on iOS 11 and 12. ([#1278](https://github.com/mapbox/mapbox-maps-ios/pull/1278))
* Increase tap target to conform to Apple Human Interface guidelines. ([#1283](https://github.com/mapbox/mapbox-maps-ios/pull/1283))
* Update to MapboxCoreMaps 10.5.0-rc.1 and MapboxCommon 21.3.0-rc.2. ([#1281](https://github.com/mapbox/mapbox-maps-ios/pull/1281))
* Expose API to set memory budget for `MapboxMap`. ([#1288](https://github.com/mapbox/mapbox-maps-ios/pull/1288))

## 10.5.0-beta.1 - April 7, 2022

* Mitigate `OfflineRegionManager.mergeOfflineDatabase(for:completion)` throwing `TypeConversionError.unexpectedType` on a successfull merge. Introduce `OfflineRegionManager.mergeOfflineDatabase(forPath:completion)` as the correct way to merge offline database. ([#1192](https://github.com/mapbox/mapbox-maps-ios/pull/1192))
* Limit MapboxMap.point(for: CLLocationCoordinate2D) to the bounds of map view ([#1195](https://github.com/mapbox/mapbox-maps-ios/pull/1195))
* Add support for app extensions. ([#1183](https://github.com/mapbox/mapbox-maps-ios/pull/1183))
* `BasicCameraAnimator.cancel()` and `.stopAnimation()` now invoke the completion blocks with `UIViewAnimatingPosition.current` instead of crashing with a `fatalError` when invoked prior to `.startAnimation()` or `.startAnimation(afterDelay:)`. ([#1197](https://github.com/mapbox/mapbox-maps-ios/pull/1197))
* `CameraAnimationsManager.stopAnimations()` will now cancel all animators regardless of their state. Previously, only animators with `state == .active` were canceled. ([#1197](https://github.com/mapbox/mapbox-maps-ios/pull/1197))
* Fix animator-related leaks. ([#1200](https://github.com/mapbox/mapbox-maps-ios/pull/1200))
* Improve AnyTouchGestureRecognizer's interaction with other gesture recognizers. ([#1210](https://github.com/mapbox/mapbox-maps-ios/pull/1210))
* Expose convenience properties and methods to transform `CoordinateBounds`. ([1226](https://github.com/mapbox/mapbox-maps-ios/pull/1226))
* Update annotation examples. ([#1215](https://github.com/mapbox/mapbox-maps-ios/pull/1215))
* Add `Style.setLight(_:)` to set light onto a style. Update `BuildingExtrusionsExample` with an example to set a light source on the style. ([#1234](https://github.com/mapbox/mapbox-maps-ios/pull/1234))
* Remove `FollowPuckViewportStateOptions.animationDuration`, a workaround for the moving target problem. ([#1228](https://github.com/mapbox/mapbox-maps-ios/pull/1228))
* Deprecate `FollowPuckViewportStateOptions.animationDuration`, a workaround for the moving target problem. ([#1228](https://github.com/mapbox/mapbox-maps-ios/pull/1228))
* Add map view example with `debugOptions`. ([#1225](https://github.com/mapbox/mapbox-maps-ios/pull/1225))
* Introduce `line-trim-offset` property for LineLayer. ([#1231](https://github.com/mapbox/mapbox-maps-ios/pull/1231))
* Add `MapboxMap.coordinateBoundsUnwrapped`. ([#1241](https://github.com/mapbox/mapbox-maps-ios/pull/1241))
* Update `DefaultViewportTransition` to solve the moving target problem. ([#1245](https://github.com/mapbox/mapbox-maps-ios/pull/1245))
* Increase deceleration cutoff threshold from 20 to 35 to prevent camera changes
 after animation stops. ([#1244](https://github.com/mapbox/mapbox-maps-ios/pull/1244))
* Update to MapboxCoreMaps 10.5.0-beta.1 and MapboxCommon 21.3.0-beta.2. ([#1235](https://github.com/mapbox/mapbox-maps-ios/pull/1235))
* API for using globe projection has been moved to `Style.setProjection(_:)` and `Style.projection` and is no longer experimental. ([#1235](https://github.com/mapbox/mapbox-maps-ios/pull/1235))
* Add `OfflineRegion.getStatus(completion:)`. ([#1239](https://github.com/mapbox/mapbox-maps-ios/pull/1239))
* Add a prefix `maps-ios` to all Log message's category. ([#1250](https://github.com/mapbox/mapbox-maps-ios/pull/1250)))

## 10.4.3 - April 13, 2022

* Update to MapboxCommon 21.2.1. ([#1271](https://github.com/mapbox/mapbox-maps-ios/pull/1271))
* Start location services lazily. ([#1262](https://github.com/mapbox/mapbox-maps-ios/pull/1262))

## 10.4.2 - April 7, 2022

* Update to MapboxCoreMaps 10.4.2 ([#1256](https://github.com/mapbox/mapbox-maps-ios/pull/1256))
* Add `OfflineRegion.getStatus(completion:)`. ([#1239](https://github.com/mapbox/mapbox-maps-ios/pull/1239))

## 10.4.1 - March 28, 2022

* Revert to using metal view draw notifications (`setNeedsDisplay()` instead of `draw()`). ([#1216](https://github.com/mapbox/mapbox-maps-ios/pull/1216))

## 10.4.0 - March 23, 2022

* Update to MapboxCoreMaps 10.4.1 and MapboxCommon 21.2.0. ([#1190](https://github.com/mapbox/mapbox-maps-ios/pull/1190))

## 10.4.0-rc.1 - March 9, 2022

* Update to MapboxCoreMaps 10.4.0-rc.1 and MapboxCommon 21.2.0-rc.1. ([#1158](https://github.com/mapbox/mapbox-maps-ios/pull/1158))
* Enable explicit drawing behavior for metal view(call `draw()` explicitly instead of `setNeedsDisplay` when view's content need to be redrawn).([#1157](https://github.com/mapbox/mapbox-maps-ios/pull/1157))
* Restore cancellation of animations on single tap. ([#1166](https://github.com/mapbox/mapbox-maps-ios/pull/1166))
* Fix issue where invalid locations could be emitted when setting a custom location provider. ([#1172](https://github.com/mapbox/mapbox-maps-ios/pull/1172))
* Fix crash in Puck2D when location accuracy authorization is reduced. ([#1173](https://github.com/mapbox/mapbox-maps-ios/pull/1173))
* Fix an issue where plain text source attribution was not populated in attribution dialog.([1163](https://github.com/mapbox/mapbox-maps-ios/pull/1163))
* `BasicCameraAnimator.owner` is now public. ([#1181](https://github.com/mapbox/mapbox-maps-ios/pull/1181))
* The animation owner for ease-to and fly-to animations is now `"com.mapbox.maps.cameraAnimationsManager"`. ([#1181](https://github.com/mapbox/mapbox-maps-ios/pull/1181))

## 10.4.0-beta.1 - February 23, 2022

* Prevent rendering in background by pausing/resuming display link in response to application or scene lifecycle events. ([#1086](https://github.com/mapbox/mapbox-maps-ios/pull/1086))
* Sync viewport and puck animations. ([#1090](https://github.com/mapbox/mapbox-maps-ios/pull/1090))
* Add puckBearingEnabled property for location. ([#1107](https://github.com/mapbox/mapbox-maps-ios/pull/1107))
* Fix camera change events being fired after map has stopped moving. ([#1118](https://github.com/mapbox/mapbox-maps-ios/pull/1118))
* Fix issue where single tap and double tap to zoom in gestures could recognize simultaneously. ([#1113](https://github.com/mapbox/mapbox-maps-ios/pull/1113))
* Remove experimental GestureOptions.pinchBehavior property. ([#1125](https://github.com/mapbox/mapbox-maps-ios/pull/1125))
* Update to MapboxCoreMaps 10.4.0-beta.1 and MapboxCommon 21.2.0-beta.1. ([#1126](https://github.com/mapbox/mapbox-maps-ios/pull/1126))
* Exposed APIs to allow positioning of other views relative to the logoView, compassView, scaleBarView and attributionButton. ([#1130](https://github.com/mapbox/mapbox-maps-ios/pull/1130))
* Add `GestureOptions.pinchPanEnabled` and `.pinchZoomEnabled`. ([#1092](https://github.com/mapbox/mapbox-maps-ios/pull/1092))
* Fix an issue where pinch gesture emitted superfluous camera changed events. ([#1137](https://github.com/mapbox/mapbox-maps-ios/pull/1137))
* Add focalPoint property to zoom and rotate gestures ([#1122](https://github.com/mapbox/mapbox-maps-ios/pull/1122))
* Expose public initializers for `LayerInfo` and `SourceInfo`. ([#1144](https://github.com/mapbox/mapbox-maps-ios/pull/1144))
* Add `ViewAnnotationManager.removeAll()` that removes all view annotations added before. Introduce `ViewAnnotationUpdateObserver` protocol for notifying when annotion views get their frames or visibility changed. Add `ViewAnnotationManager.addViewAnnotationUpdateObserver(_:)` and `ViewAnnotationManager.removeViewAnnotationUpdateObserver(_:)` to add and remove observers. ([#1136](https://github.com/mapbox/mapbox-maps-ios/pull/1136))

## 10.3.0 - February 10, 2022

* Updated to MapboxCoreMaps 10.3.2 and MapboxCommon 21.1.0. ([#1078](https://github.com/mapbox/mapbox-maps-ios/pull/1078), [#1091](https://github.com/mapbox/mapbox-maps-ios/pull/1091), [#1104](https://github.com/mapbox/mapbox-maps-ios/pull/1104))
* Fixed compass button regression introduced in rc.1. ([#1083](https://github.com/mapbox/mapbox-maps-ios/pull/1083))
* Removed pitch gesture change angle requirements to avoid map freezing during gesture. ([#1089](https://github.com/mapbox/mapbox-maps-ios/pull/1089))

## 10.3.0-rc.1 – January 26, 2022

* Exposed API to invalidate `OfflineRegion`. ([#1026](https://github.com/mapbox/mapbox-maps-ios/pull/1026))
* Exposed API to set metadata for `OfflineRegion`. ([#1060](https://github.com/mapbox/mapbox-maps-ios/pull/1060))
* Refined Viewport API. ([#1040](https://github.com/mapbox/mapbox-maps-ios/pull/1040), [#1050](https://github.com/mapbox/mapbox-maps-ios/pull/1050), [#1058](https://github.com/mapbox/mapbox-maps-ios/pull/1058))
* Add extension function to show or hide bearing image. ([#980](https://github.com/mapbox/mapbox-maps-ios/pull/980))
* Updated to MapboxCoreMaps 10.3.0-rc.1 and MapboxCommon 21.1.0-rc.1. ([#1051](https://github.com/mapbox/mapbox-maps-ios/pull/1051))
* Add APIs to enable customizing 2D puck accuracy ring color. ([#1057](https://github.com/mapbox/mapbox-maps-ios/pull/1057))

## 10.3.0-beta.1 - January 12, 2022

* Exposed `triggerRepaint()` to allow manual map repainting.
    ([#964](https://github.com/mapbox/mapbox-maps-ios/pull/964))
* Exposed `TransitionOptions` to allow control over symbol fade duration.
    ([#902](https://github.com/mapbox/mapbox-maps-ios/pull/902))
* Added `Style.removeTerrain()` to allow removing terrain. ([#918](https://github.com/mapbox/mapbox-maps-ios/pull/918))
* `Snapshotter` initialization now triggers a turnstyle event. ([#908](https://github.com/mapbox/mapbox-maps-ios/pull/908))
* Fixed a bug where 2D puck location was never set when location accuracy authorization was reduced. ([#989](https://github.com/mapbox/mapbox-maps-ios/pull/989))
* Fixed a bug where setting LocationManager.options would cause the LocationProvider to be reconfigured. ([#992](https://github.com/mapbox/mapbox-maps-ios/pull/992))

## 10.2.0 - December 15, 2021

* Update to MapboxCoreMaps 10.2.0 and MapboxCommon 21.0.1. ([#952](https://github.com/mapbox/mapbox-maps-ios/pull/952))
* Fix the crash when MapView had zero width or height. ([#903](https://github.com/mapbox/mapbox-maps-ios/pull/903))

## 10.2.0-rc.1 - December 2, 2021

* Removed experimental designation from persistent layer APIs. ([#849](https://github.com/mapbox/mapbox-maps-ios/pull/849))
* Fixed an issue that prevented direct download artifacts from exposing experimental APIs. ([#854](https://github.com/mapbox/mapbox-maps-ios/pull/854))
* Updates `Style.localizeLabels(into:forLayerIds:)` to only localize the primary localization and not the fall-through localizations. ([#856](https://github.com/mapbox/mapbox-maps-ios/pull/856))
* Removes swiftlint config from direct download artifacts. ([#859](https://github.com/mapbox/mapbox-maps-ios/pull/859))
* Removed `AnnotationView` wrapper views from `ViewAnnotationManager` API. ([#846](https://github.com/mapbox/mapbox-maps-ios/pull/846))
* Reduce geometry wrapping using GeometryConvertible. ([#861](https://github.com/mapbox/mapbox-maps-ios/pull/861))
* Fixed an issue that could prevent the location puck from appearing. ([#862](https://github.com/mapbox/mapbox-maps-ios/pull/862))
* Added support for exponentials to `StyleColor`. ([#873](https://github.com/mapbox/mapbox-maps-ios/pull/873))
* Fixes initialization of attribution dialog. ([#865](https://github.com/mapbox/mapbox-maps-ios/pull/865))
* Improved panning behavior on pitched maps. ([#888](https://github.com/mapbox/mapbox-maps-ios/pull/888))
* Added pinch gesture tradeoff configuration option. ([#890](https://github.com/mapbox/mapbox-maps-ios/pull/890))
* Update to MapboxCoreMaps 10.2.0-rc.1 and MapboxCommon 21.0.0-rc.2. ([#891](https://github.com/mapbox/mapbox-maps-ios/pull/891))

## 10.2.0-beta.1 - November 19, 2021

* Fixed an issue where camera animations triggered with `startAnimation(afterDelay:)` could appear jerky after a pan gesture. ([#789](https://github.com/mapbox/mapbox-maps-ios/pull/789))
* Send location update when puck is nil and other location-related improvements. ([#765](https://github.com/mapbox/mapbox-maps-ios/pull/765))
* Update to MapboxCoreMaps 10.2.0-beta.1 and MapboxCommon 21.0.0-rc.1. ([#836](https://github.com/mapbox/mapbox-maps-ios/pull/836))
* Updates pan and pinch gesture handling to work iteratively rather than based on initial state. ([#837](https://github.com/mapbox/mapbox-maps-ios/pull/837))
* `AnnotationOrchestrator`, rather than the annotation managers, now manages the single-tap gesture recognizer for annotations. ([#840](https://github.com/mapbox/mapbox-maps-ios/pull/840))
* Add view annotations feature, which enables the usage of custom UIView subclasses as annotations. ([#776](https://github.com/mapbox/mapbox-maps-ios/pull/776))

## 10.1.2 - December 13, 2021

* Fixed billing issue when upgrading Mapbox Maps SDK from v6 to v10. ([#943](https://github.com/mapbox/mapbox-maps-ios/pull/943))

## 10.1.1 - December 1, 2021

**NOTE:** As of December 3, 2021, this release is no longer available due to a new bug that was introduced while fixing the billing issue. A new patch will be issued shortly.

* Fixed billing issue when upgrading Mapbox Maps SDK from v6 to v10. ([#885](https://github.com/mapbox/mapbox-maps-ios/pull/885))

## 10.1.0 - November 4, 2021

* Update to `MapboxCoreMaps` v10.1.0 and `MapboxCommon` v20.1.0. ([#807](https://github.com/mapbox/mapbox-maps-ios/pull/807))

## 10.1.0-rc.1 - October 28, 2021

* Fixed an issue with `UIImage` conversion that led to a "mismatched image size" error. ([#790](https://github.com/mapbox/mapbox-maps-ios/pull/790))
* Update to `MapboxCoreMaps` v10.1.0-rc and `MapboxCommon` v20.1.0-rc.2. ([#790](https://github.com/mapbox/mapbox-maps-ios/pull/790))

## 10.1.0-beta.1 - October 21, 2021

* Make `PointAnnotation.Image`'s fields public. ([#753](https://github.com/mapbox/mapbox-maps-ios/pull/753))
* Set `MapboxMap` flags during gestures and animations. ([#754](https://github.com/mapbox/mapbox-maps-ios/pull/754))
* Treat anchor as constant for `ease(to:)` animations. ([#772](https://github.com/mapbox/mapbox-maps-ios/pull/772))
* Fix experimental snapshot API for iOS 15. ([#760](https://github.com/mapbox/mapbox-maps-ios/pull/760))
* Decelerate more quickly (or not at all) on pitched maps. ([#773](https://github.com/mapbox/mapbox-maps-ios/pull/773))
* Add `GestureOptions.pinchRotateEnabled` to configure whether the pinch gesture rotates the map. ([#779](https://github.com/mapbox/mapbox-maps-ios/pull/779))
* Fixed a name collision between Swift symbols and `MapboxCoreMaps.Task`. ([#769](https://github.com/mapbox/mapbox-maps-ios/pull/769))
* Fixed an issue that caused `queryFeatureExtension` to fail. ([#769](https://github.com/mapbox/mapbox-maps-ios/pull/769))
* Updated `MapboxCoreMaps` to v10.1.0-beta and `MapboxCommon` to 20.1.0-rc.1. ([#769](https://github.com/mapbox/mapbox-maps-ios/pull/769))

## 10.0.3 - December 13, 2021

* Fixed billing issue when upgrading Mapbox Maps SDK from v6 to v10. ([#942](https://github.com/mapbox/mapbox-maps-ios/pull/942))

## 10.0.2 - November 29, 2021

**NOTE:** As of December 3, 2021, this release is no longer available due to a new bug that was introduced while fixing the billing issue. A new patch will be issued shortly.

* Fixed billing issue when upgrading Mapbox Maps SDK from v6 to v10. ([#876](https://github.com/mapbox/mapbox-maps-ios/pull/876))

## 10.0.1 - October 15, 2021

* Passing an unsupported locale into `Style.localizeLabels(into:forLayerIds:)` throws an error instead of crashing. ([#752](https://github.com/mapbox/mapbox-maps-ios/pull/752))
* Fixed a bug affecting the persistence of user settings when upgrading to v10. ([#758](https://github.com/mapbox/mapbox-maps-ios/pull/758))
* Allow compass visibility to accurately reflect set value. ([#757](https://github.com/mapbox/mapbox-maps-ios/pull/757))
* Update MapboxMobileEvents to v1.0.6, fixing a null pointer crash. ([#762](https://github.com/mapbox/mapbox-maps-ios/pull/762))

## 10.0.0 - October 6, 2021

### Breaking changes ⚠️

* Removes default parameter values in the `addImage` function. ([#695](https://github.com/mapbox/mapbox-maps-ios/pull/695))
* `public func layer<T: Layer>(withId id: String) throws -> T` has been updated to `public func layer<T>(withId id: String, type: T.Type) throws -> T where T: Layer`. ([#694](https://github.com/mapbox/mapbox-maps-ios/pull/694))
* `public func updateLayer<T: Layer>(withId id: String, update: (inout T) throws -> Void) throws` has been updated to `public func updateLayer<T>(withId id: String, type: T.Type, update: (inout T) throws -> Void) throws where T: Layer`. ([#694](https://github.com/mapbox/mapbox-maps-ios/pull/694))
* `public func source<T: Source>(withId id: String) throws -> T` has been updated to `public func source<T>(withId id: String, type: T.Type) throws -> T where T: Source`. ([#694](https://github.com/mapbox/mapbox-maps-ios/pull/694))
* `@_spi(Experimental) public func layer(withId id: String, type: Layer.Type) throws -> Layer` is no longer experimental and has been updated to `public func layer(withId id: String) throws -> Layer`. ([#694](https://github.com/mapbox/mapbox-maps-ios/pull/694))
* `@_spi(Experimental) public func source(withId id: String, type: Source.Type) throws  -> Source` is no longer experimental and has been updated to `public func source(withId id: String) throws  -> Source`. ([#694](https://github.com/mapbox/mapbox-maps-ios/pull/694))
* `GestureManagerDelegate.gestureBegan(for:)` has been renamed to `GestureManagerDelegate.gestureManager(_:didBegin:)`. ([#697](https://github.com/mapbox/mapbox-maps-ios/pull/697))
* Added the public delegate methods `GestureManagerDelegate.gestureManager(_:didEnd:willAnimate:)` and `GestureManagerDelegate.gestureManager(_:didEndAnimatingFor:)`. ([#697](https://github.com/mapbox/mapbox-maps-ios/pull/697))
* Converts `PointAnnotation.Image` from an `enum` to a `struct`. ([#707](https://github.com/mapbox/mapbox-maps-ios/pull/707))
* Removes `PointAnnotation.Image.default`. ([#707](https://github.com/mapbox/mapbox-maps-ios/pull/707))
* Replaces `PointAnnotation.Image.custom` with `PointAnnotation.Image.init(image:name:)`. ([#707](https://github.com/mapbox/mapbox-maps-ios/pull/707))
* The `tapGestureRecognizer` var on each `*AnnotationManager` has been removed in favor of a unified tap gesture recognizer available at `GestureManager.singleTapGestureRecognizer`([#709](https://github.com/mapbox/mapbox-maps-ios/pull/709)).
* `public func layerProperty(for layerId: String, property: String) -> Any` has been renamed to `public func layerPropertyValue(for layerId: String, property: String) -> Any` to avoid ambiguity. ([#708](https://github.com/mapbox/mapbox-maps-ios/pull/708))
* `MapboxCommon.Geometry` extension methods are now marked as internal. ([#683](https://github.com/mapbox/mapbox-maps-ios/pull/683))
* `TileRegionLoadOptions` init now takes a `Geometry` instead of a `MapboxCommon.Geometry`. ([#711](https://github.com/mapbox/mapbox-maps-ios/pull/711))
* `CameraAnimationsManager.options` has been removed. Use `MapboxMap.cameraBounds` and `MapboxMap.setCameraBounds(with:)` instead. ([#712](https://github.com/mapbox/mapbox-maps-ios/pull/712))
* `MapboxMap.setCameraBounds(for:)` has been renamed to `.setCameraBounds(with:)` ([#712](https://github.com/mapbox/mapbox-maps-ios/pull/712))
* Renames `Style.updateGeoJSONSource<T: GeoJSONObject>(withId:geoJSON:)` to `Style.updateGeoJSONSource(withId:geoJSON:)`. Instead of passing in the expected GeoJSON object type, you perform pattern matching on the return value using `case let`. ([#715](https://github.com/mapbox/mapbox-maps-ios/pull/715))
* Setting `data` property on a GeoJSON source via `Style.setSourceProperty(for:property:value:)` or `Style.updateGeoJSONSource(withId:geoJSON:)` is now asynchronous and never returns an error. Errors will be reported asynchronously via a `MapEvents.EventKind.mapLoadingError` event instead. ([#732](https://github.com/mapbox/mapbox-maps-ios/pull/732))
* Core and Common APIs that accept user-defined implementations of protocols now hold strong references to the provided objects. Please audit your usage of the following protocols and make any required changes to avoid memory leaks: `CustomLayerHost`, `ElevationData`, `MapClient`, `MBMMetalViewProvider`, `Observer`, `OfflineRegionObserver`, `HttpServiceInterceptorInterface`, `HttpServiceInterface`, `LogWriterBackend`, `OfflineSwitchObserver`, `ReachabilityInterface`, `TileStoreObserver`. ([#732](https://github.com/mapbox/mapbox-maps-ios/pull/732))
* Extends `OfflineRegionGeometryDefinition.geometry` to use `Geometry` rather than `MapboxCommon.Geometry`. It also adds a convenience initializer that takes a `Geometry`. ([#706](https://github.com/mapbox/mapbox-maps-ios/pull/706))
* Annotation managers are now kept alive by the `AnnotationOrchestrator` (`MapView.annotations`) until they are explicitly destroyed by calling `mapView.annotations.removeAnnotationManager(withId:)` or are implicitly destroyed by creating a second annotation manager with the same ID. ([#725](https://github.com/mapbox/mapbox-maps-ios/pull/725))
* The `AnnotationManager` protocol now conforms to `AnyObject`. ([#725](https://github.com/mapbox/mapbox-maps-ios/pull/725))
* `PreferredFPS` has been removed. `MapView.preferredFramesPerSecond` now of type `Int`, rather than `PreferredFPS`. ([#735](https://github.com/mapbox/mapbox-maps-ios/pull/735))
* `QueriedFeature.feature` is no longer optional. ([#737](https://github.com/mapbox/mapbox-maps-ios/pull/737))
* `TypeConversionError` has a new case `unsuccessfulConversion`. ([#737](https://github.com/mapbox/mapbox-maps-ios/pull/737))

### Features ✨ and improvements 🏁

* `TileRegionLoadOptions` exposes its geometry as a `Geometry`. ([#711](https://github.com/mapbox/mapbox-maps-ios/pull/711))
* Adds `FeatureExtensionValue.init(value: Any?, features: [Feature]?)` that works with Turf. ([#717](https://github.com/mapbox/mapbox-maps-ios/pull/717))
* Adds `FeatureExtensionValue.features: [Feature]?` that works with Turf. ([#717](https://github.com/mapbox/mapbox-maps-ios/pull/717))
* APIs that accept Turf `Feature` now allow `Feature.identifier` and `.properties` to be `nil`. ([#717](https://github.com/mapbox/mapbox-maps-ios/pull/717))
* APIs that accept Turf `Feature` now ignore `Feature.properties` instead of crashing if it cannot be converted to `[String: NSObject]`. ([#717](https://github.com/mapbox/mapbox-maps-ios/pull/717))
* Any touch event in the map now immediately disables camera animation. Temporarily disable user interaction on the `MapView` to disable this behavior as needed. ([#712](https://github.com/mapbox/mapbox-maps-ios/pull/712))
* `BasicCameraAnimator` no longer updates the camera a final time after being stopped or canceled prior to running to completion. ([#712](https://github.com/mapbox/mapbox-maps-ios/pull/712))
* `BasicCameraAnimator.isReversed` is now settable. ([#712](https://github.com/mapbox/mapbox-maps-ios/pull/712))
* The double tap, quick zoom, and double touch gestures now use the gesture's location in the view to anchor camera changes. Previously, they used the camera's center coordinate. ([#722](https://github.com/mapbox/mapbox-maps-ios/pull/722))
* `MapboxCommon.HTTPServiceFactory.reset()` has been added to release the HTTP service implementation. ([#732](https://github.com/mapbox/mapbox-maps-ios/pull/732))
* `AnnotationOrchestrator.annotationManagersById` has been added. This dictionary contains all annotation managers that have not been removed. ([#725](https://github.com/mapbox/mapbox-maps-ios/pull/725))
* Adds the `ExpressionArgument.geoJSONObject(_:)` case, which allows you to include a `Turf.GeoJSONObject` instance in an expression with the `Expression.Operator.distance` or `Expression.Operator.within` operator. ([#730](https://github.com/mapbox/mapbox-maps-ios/pull/730))
* Adds `MapView.preferredFrameRateRange` for devices using iOS 15.0 and up. ([#735](https://github.com/mapbox/mapbox-maps-ios/pull/735))
* Adds `TileStore.subscribe(_:)` which can be used to observe a `TileStore`'s activity. The API design deviates from Android's add/remove observer API so that the developer-provided `TileStoreObserver` can be wrapped into a `MapboxCommon_Private.TileStoreObserver` without needing to use global state or something like Objective-C associated objects to look up which wrapper goes with with developer-provided observer when calling `__removeObserver`. ([#737](https://github.com/mapbox/mapbox-maps-ios/pull/737))
* Adds `TileStoreObserver` protocol. ([#737](https://github.com/mapbox/mapbox-maps-ios/pull/737))

### Bug fixes 🐞

* Fix rendering artifacts for a model layer when `model-opacity` property is used. ([#732](https://github.com/mapbox/mapbox-maps-ios/pull/732))
* Improve rendering performance by avoiding unnecessary re-layout for cached tiles. ([#732](https://github.com/mapbox/mapbox-maps-ios/pull/732))
* Fix telemetry opt-out through attribution dialog. ([#743](https://github.com/mapbox/mapbox-maps-ios/pull/743))

### Dependencies

* Updates MapboxCoreMaps to v10.0.0, MapboxCommon to v20.0.0. ([#732](https://github.com/mapbox/mapbox-maps-ios/pull/732))
* Updates [Turf to v2._x_](https://github.com/mapbox/turf-swift/releases/tag/v2.0.0). ([#741](https://github.com/mapbox/mapbox-maps-ios/pull/741))
* Updates MapboxMobileEvents to v1.0.5. ([#724](https://github.com/mapbox/mapbox-maps-ios/pull/724))

## 10.0.0-rc.9 - September 22, 2021

### Breaking changes ⚠️

* `BasicCameraAnimator` now keeps animators alive without the user storing the animator. ([#646](https://github.com/mapbox/mapbox-maps-ios/pull/646/))
* Experimental style APIs are now marked with `@_spi(Experimental)` and the previously used underscore prefixes have been removed. In order to access these methods, use `@_spi(Experimental)` to annotate the import statement for MapboxMaps. ([#680](https://github.com/mapbox/mapbox-maps-ios/pull/680))
* `RenderedQueryOptions.filter` is now of type `Expression` instead of `Any` ([#689](https://github.com/mapbox/mapbox-maps-ios/pull/689))
* `OfflineRegionGeometryDefinition.geometry` is now of type `Turf.Geometry` instead of `MapboxCommon.Geometry` ([#689](https://github.com/mapbox/mapbox-maps-ios/pull/689))
* The `HTTPResponse` init methods that take `MapboxCommon.Expected` instead of `Result` are now correctly marked as refined for Swift. ([#689](https://github.com/mapbox/mapbox-maps-ios/pull/689))
* The `DownloadStatus` init methods that take `MapboxCommon.Expected` instead of `Result` and `NSNumber?` instead of `UInt64?` are not correctly marked as refined for Swift. ([#689](https://github.com/mapbox/mapbox-maps-ios/pull/689))
* `GestureOptions.hapticFeedbackEnabled` has been removed. ([#663](https://github.com/mapbox/mapbox-maps-ios/pull/663))
* `GestureManager.decelarationRate` has been removed and `GestureOptions.decelerationRate` is the single source of truth. ([#662](https://github.com/mapbox/mapbox-maps-ios/pull/662))
* `GestureManager` no longer conforms to `NSObject` and is not a `UIGestureRecognizerDelegate`. ([#669](https://github.com/mapbox/mapbox-maps-ios/pull/669))
* `TapGestureHandler.init` was previously public by mistake and is now internal. ([#677](https://github.com/mapbox/mapbox-maps-ios/pull/677))
* The behavior of `GestureManager.options` has been updated to better reflect the `isEnabled` state of the associated gesture recognizers. ([#677](https://github.com/mapbox/mapbox-maps-ios/pull/677))
* The gesture recognizer properties of `GestureManager` are no longer `Optional`. ([#677](https://github.com/mapbox/mapbox-maps-ios/pull/677))
* `GestureType` has been redesigned so that its cases have a 1-1 relationship with the built-in gestures. ([#677](https://github.com/mapbox/mapbox-maps-ios/pull/677))
* `GestureManager.rotationGestureRecognizer` has been removed. Rotation is now handled by `.pinchGestureRecognizer` in addition to its preexisting handling of panning and zooming. ([#696](https://github.com/mapbox/mapbox-maps-ios/pull/696))
* `GestureManager.doubleTapToZoomOutGestureRecognizer` has been replaced with `.doubleTouchToZoomOutGestureRecognizer`. ([#696](https://github.com/mapbox/mapbox-maps-ios/pull/696))
* `PanScrollingMode` has been renamed to `PanMode`. ([#696](https://github.com/mapbox/mapbox-maps-ios/pull/696))
* `GestureOptions.zoomEnabled` has been replaced by `.doubleTapToZoomInEnabled`, `.doubleTouchToZoomOutEnabled`, and `.quickZoomEnabled`. ([#696](https://github.com/mapbox/mapbox-maps-ios/pull/696))
* `GestureOptions.rotateEnabled` has been removed. ([#696](https://github.com/mapbox/mapbox-maps-ios/pull/696))
* `GestureOptions.scrollEnabled` has been renamed to `.panEnabled`. ([#696](https://github.com/mapbox/mapbox-maps-ios/pull/696))
* `GestureOptions.scrollingMode` has been renamed to `.panMode`. ([#696](https://github.com/mapbox/mapbox-maps-ios/pull/696))
* `GestureOptions.decelerationRate` has been renamed to `.panDecelerationFactor`. ([#696](https://github.com/mapbox/mapbox-maps-ios/pull/696))
* `GestureType.doubleTapToZoomOut` has been replaced with `.doubleTouchToZoomOut`. ([#696](https://github.com/mapbox/mapbox-maps-ios/pull/696))
* `GestureType.rotate` has been removed. ([#696](https://github.com/mapbox/mapbox-maps-ios/pull/696))
* `GestureType` cases have been reordered for consistency with `GestureOptions` and `GestureManager`. ([#696](https://github.com/mapbox/mapbox-maps-ios/pull/696))

### Features ✨ and improvements 🏁

* Allow users to set the map's `MapDebugOptions`. ([#648](https://github.com/mapbox/mapbox-maps-ios/pull/648))
* Implement 'promoteId' feature for geojson and vector sources. The feature allows to promote feature's property to a feature id, so that promoted id can be used with FeatureState API. ([#660](https://github.com/mapbox/mapbox-maps-ios/pull/660))
* Tiled 3D model layer and source ([#689](https://github.com/mapbox/mapbox-maps-ios/pull/689))
* Enable instant transitions for data driven symbol layer properties ([#689](https://github.com/mapbox/mapbox-maps-ios/pull/689))
* Implement face culling for Metal ([#689](https://github.com/mapbox/mapbox-maps-ios/pull/689))
* `HTTPServiceInterface.getInstance()` is now publicly available. ([#689](https://github.com/mapbox/mapbox-maps-ios/pull/689))
* `CameraState`'s fields are now `var`s instead of `let`s for testing purposes, and a public, memberwise initializer has been added. ([#677](https://github.com/mapbox/mapbox-maps-ios/pull/677))
* `PanScrollingMode` now conforms to `CaseIterable`. ([#677](https://github.com/mapbox/mapbox-maps-ios/pull/677))
* `GestureType` now conforms to `CaseIterable`. ([#677](https://github.com/mapbox/mapbox-maps-ios/pull/677))
* Pan deceleration has been reimplemented to produce a more natural deceleration effect. ([#692](https://github.com/mapbox/mapbox-maps-ios/pull/692))
* Expose new API to allow users to create a `UIImage` out of the last rendered MapView state. ([#693](https://github.com/mapbox/mapbox-maps-ios/pull/693))

### Bug fixes 🐞

* Fixes animations that are started within an UIKit animation context. ([#684](https://github.com/mapbox/mapbox-maps-ios/pull/684))
* Fix transition between layers with all-constant properties ([#689](https://github.com/mapbox/mapbox-maps-ios/pull/689))
* Fix rendering artifact for a line layer, when its line-gradient property is set at runtime. ([#689](https://github.com/mapbox/mapbox-maps-ios/pull/689))
* Don't draw SDF images in text-field and issue warning for it ([#689](https://github.com/mapbox/mapbox-maps-ios/pull/689))
* Fix incorrect return from `StyleManager#getStyleLayerPropertyDefaultValue` for 'text-field'. Now the default value is set to `["format", "" , {}]` ([#689](https://github.com/mapbox/mapbox-maps-ios/pull/689))
* GestureManager no longer sets itself as the delegate of all gestures in MapView when its options change. ([#677](https://github.com/mapbox/mapbox-maps-ios/pull/677))
* Fixes an issue where tapping the compass could fail to set the bearing to 0 if there was already an animation running. Tapping the compass now cancels any existing animations. ([#696](https://github.com/mapbox/mapbox-maps-ios/pull/696))
* Fixes issues with the pinch gesture when removing and re-adding one of the two required touches. ([#696](https://github.com/mapbox/mapbox-maps-ios/pull/696))
* Fixes an issue where a pan gesture would fail if it interrupted the deceleration from a previous pan gesture. ([#696](https://github.com/mapbox/mapbox-maps-ios/pull/696))

## 10.0.0-rc.8 - September 8, 2021

### Breaking changes ⚠️

* `QueriedFeature.feature` is now of type `Turf.Feature?` instead of `MapboxCommon.Feature`. ([#628](https://github.com/mapbox/mapbox-maps-ios/pull/628))
* Enables error notification in offline mode if the required resource is missing in cache (before map did not emit any notification in this case) ([#628](https://github.com/mapbox/mapbox-maps-ios/pull/628))
* Suppresses error notifications on missing volatile tiles in offline mode ([#628](https://github.com/mapbox/mapbox-maps-ios/pull/628))
* Adapt setBounds to gl-js behavior: constraining of coordinates and zoom level is now stricter to prevent out of bounds map area to be visible in the viewport ([#628](https://github.com/mapbox/mapbox-maps-ios/pull/628))
* Add HTTP interceptor API - HttpServiceInterface has a new method `setInterceptor` that must be implemented ([#628](https://github.com/mapbox/mapbox-maps-ios/pull/628))
* `Geometry` now refers to `Turf.Geometry` instead of `MapboxCommon.Geometry`. ([#622](https://github.com/mapbox/mapbox-maps-ios/pull/622))
* `Feature` now refers to `Turf.Feature` instead of `MapboxCommon.Feature`. ([#642](https://github.com/mapbox/mapbox-maps-ios/pull/642))
* Renamed `ColorRepresentable` to `StyleColor` ([#650](https://github.com/mapbox/mapbox-maps-ios/pull/650))
* Removed the argument label from `StyleColor`'s `UIColor` initializer ([#650](https://github.com/mapbox/mapbox-maps-ios/pull/650))
* Renamed `ColorRepresentable.rgbaDescription` to `StyleColor.rgbaString`. ([#650](https://github.com/mapbox/mapbox-maps-ios/pull/650))
* Changed `StyleColor`'s `Encodable` implementation to always encode an rgba color string instead of encoding an rgba expression ([#650](https://github.com/mapbox/mapbox-maps-ios/pull/650))
* Updated the extension on `UIColor` that adds `ExpressionArgumentConvertible` to return an rgba color string instead of an rgba expression. ([#650](https://github.com/mapbox/mapbox-maps-ios/pull/650))
* Annotation managers now sync with their backing source and layer only once per display link. Use `syncSourceAndLayerIfNeeded()` to force the sync to happen earlier. ([#650](https://github.com/mapbox/mapbox-maps-ios/pull/650), [#621](https://github.com/mapbox/mapbox-maps-ios/pull/621))
* The `layerType` argument to `Style._layerPropertyDefaultValue(for:property:)` is now of type `LayerType` instead of `String` ([#650](https://github.com/mapbox/mapbox-maps-ios/pull/650))
* `Expression` decoding will now fail if the operator is missing ([#650](https://github.com/mapbox/mapbox-maps-ios/pull/650))
* `PointAnnotationManager.textVariableAnchor` is now of type `[TextAnchor]?` instead of `[String]?` ([#650](https://github.com/mapbox/mapbox-maps-ios/pull/650))
* `PointAnnotationManager.textWritingMode` is now of type `[TextWritingMode]?` instead of `[String]?` ([#650](https://github.com/mapbox/mapbox-maps-ios/pull/650))

### Features ✨ and improvements 🏁

* It is no longer necessary to `import Turf`. ([#622](https://github.com/mapbox/mapbox-maps-ios/pull/622))
* Enable instant transitions for data driven paint layer properties ([#628](https://github.com/mapbox/mapbox-maps-ios/pull/628))
* Offload networking tasks at the init phase ([#631](https://github.com/mapbox/mapbox-maps-ios/pull/631))
* 3D pucks will now be rendered over other 3D content and occluded by terrain ([#641](https://github.com/mapbox/mapbox-maps-ios/pull/641))
* Added a public, failable, component-wise initializer to `StyleColor` ([#650](https://github.com/mapbox/mapbox-maps-ios/pull/650))
* Updated `StyleColor`'s `Decodable` support to be able to handle rgba color strings as well as rgba expressions ([#650](https://github.com/mapbox/mapbox-maps-ios/pull/650))
* Made generated enums conform to `CaseIterable` ([#650](https://github.com/mapbox/mapbox-maps-ios/pull/650))
* Location puck can now hide the accuracy ring. The default value is to hide the accuracy ring. In order to enable the ring, set the `showAccuracyRing` property in `Puck2DConfiguration` to `true`. [#629](https://github.com/mapbox/mapbox-maps-ios/pull/629)
* Annotation interaction delegates are only called when at least one annotation is detected to have been tapped ([638](https://github.com/mapbox/mapbox-maps-ios/issues/638))

### Bug fixes 🐞

* Fix volatile tiles disappearing on "not modified" response ([#628](https://github.com/mapbox/mapbox-maps-ios/pull/628))
* Fix crash in MapboxMap.clearData() ([#628](https://github.com/mapbox/mapbox-maps-ios/pull/628))
* Trigger map redraw when feature state changes ([#628](https://github.com/mapbox/mapbox-maps-ios/pull/628))
* Do not start background task if telemetry collection is disabled ([#631](https://github.com/mapbox/mapbox-maps-ios/pull/631))
* Fix KVC decoding for iOS 15 ([#631](https://github.com/mapbox/mapbox-maps-ios/pull/631))
* The GeoJSON source backing an `AnnotationMnager` is now removed correctly when an `AnnotationManager` is deallocated ([#633](https://github.com/mapbox/mapbox-maps-ios/pull/633))
* Updated annotations to use `rgbaString` and `init(rgbaString:)` when serializing and deserializing `StyleColor`s ([#650](https://github.com/mapbox/mapbox-maps-ios/pull/650))
* Annotation managers now properly restore the default values of any annotation or common style properties that are reset to nil, with the exception of `text-field` and `line-gradient` for which there are currently issues to resolve between mapbox-maps-ios and mapbox-core-maps-ios. ([#650](https://github.com/mapbox/mapbox-maps-ios/pull/650))
* Fixed Expression decoding when second array element could be an operator ([#650](https://github.com/mapbox/mapbox-maps-ios/pull/650))
* Fixed an issue where layer persistence was not maintained after calling `Style._moveLayer`. ([#643](https://github.com/mapbox/mapbox-maps-ios/pull/643))
* Fix issue where annotations were not being returned to annotation interaction delegates ([638](https://github.com/mapbox/mapbox-maps-ios/issues/638))

### Breaking changes ⚠️

* `TileStore.tileRegionGeometry(forId: String, completion: @escaping (Result<MapboxCommon.Geometry, Error>) -> Void)` has been updated to `TileStore.tileRegionGeometry(forId: String, completion: @escaping (Result<Geometry, Error>) -> Void)`. ([#661](https://github.com/mapbox/mapbox-maps-ios/pull/661))

## 10.0.0-rc.7 - August 25, 2021

### Features ✨ and improvements 🏁

* Add support for `FeatureState` in GeoJSON sources. ([#611](https://github.com/mapbox/mapbox-maps-ios/pull/611))
  * `setFeatureState(sourceId:sourceLayerId:featureId:state:)` is used to associate a `stateMap` for a particular feature
  * `getFeatureState(sourceId:sourceLayerId:featureId:callback:)` is used to retrieve a previously stored `stateMap` for a feature
  * `removeFeatureState(sourceId:sourceLayerId:featureId:stateKey:)` is used to remove a previously stored `stateMap` for a feature
* Added `GeoJSONSource.generateId` ([#593](https://github.com/mapbox/mapbox-maps-ios/pull/593))
* Enable the combined usage of line-dasharray with line-gradient ([#588](https://github.com/mapbox/mapbox-maps-ios/pull/588))
* Fixed rendering issue for round line-join in line gradients ([#594](https://github.com/mapbox/mapbox-maps-ios/pull/594))

### Breaking changes ⚠️

* Removed GeoJSONManager. Please use Turf directly instead to serialize and deserialize GeoJSON. ([#603](https://github.com/mapbox/mapbox-maps-ios/pull/603))
* Add specific geometry types to annotations. ([#612](https://github.com/mapbox/mapbox-maps-ios/pull/612))
* Replace syncAnnotations with property setter. ([#614](https://github.com/mapbox/mapbox-maps-ios/pull/614))

### Bug fixes 🐞

* Update all Annotation files to use `get/set` instead of `didSet`. This fixes an issue where properties were not being set at `init`. ([#590](https://github.com/mapbox/mapbox-maps-ios/pull/590))
* `GeoJSONSource.clusterProperties` is now correctly modeled per the style spec. ([#597](https://github.com/mapbox/mapbox-maps-ios/pull/597))
* Fixes a crash caused by `MapboxMap.clearData()`. ([#609](https://github.com/mapbox/mapbox-maps-ios/pull/609))
* Added missing attribution and links to info alert controller. ([#591](https://github.com/mapbox/mapbox-maps-ios/pull/591))
* Fixed issue that caused incorrect animation of negative padding values ([#602](https://github.com/mapbox/mapbox-maps-ios/pull/602))

## 10.0.0-rc.6 - August 11, 2021

### Features ✨ and improvements 🏁

* Added support for building with Xcode 13b3. ([#564](https://github.com/mapbox/mapbox-maps-ios/pull/564))
* Added attribution to snapshots generated by `Snapshotter`. ([#567](https://github.com/mapbox/mapbox-maps-ios/pull/567))
* Added a convenience initializer for `DownloadStatus` ([#454](https://github.com/mapbox/mapbox-maps-ios/pull/454))

### Bug fixes 🐞

* Fixed an issue where panning was not enabled while zooming. ([#474](https://github.com/mapbox/mapbox-maps-ios/pull/474))

## 10.0.0-rc.5 - July 28, 2021

* Fixed an issue where `MapView` positioning wasn't correct when used in containers such as UIStackView. ([#533](https://github.com/mapbox/mapbox-maps-ios/pull/533))

### Features ✨ and improvements 🏁

* Added new options to `MapSnapshotOptions`
  * `showsLogo` is a flag that will decide whether the logo will be shown on a snapshot
  * `showsAttribution` is a flag that will decide whether the attribution will be shown on a snapshot

## 10.0.0-rc.4 - July 14, 2021

### Features ✨ and improvements 🏁

* Support `text-writing-mode` property for line symbol-placement text labels. ([#522](https://github.com/mapbox/mapbox-maps-ios/pull/522))
  Note: This change will bring following changes for CJK text block:
  1. For vertical CJK text, all the characters including Latin and Numbers will be vertically placed now. Previously, Latin and Numbers are horizontally placed.
  2. For horizontal CJK text, it may have a slight horizontal shift due to the anchor shift.
* Expanded `localizeLabels(into: Locale)` to accept a `[String]`. This array will contain a list of layer ids that you will want to localize. ([#512](https://github.com/mapbox/mapbox-maps-ios/pull/512))

### Breaking changes ⚠️

* `TileRegionError` has a new case `tileCountExceeded(String)`. ([#522](https://github.com/mapbox/mapbox-maps-ios/pull/522))
* FlyToCameraAnimator.state will now be `.inactive` after it completes or is stopped. This change makes its behavior consistent with the behavior of `BasicCameraAnimator`. ([#519](https://github.com/mapbox/mapbox-maps-ios/pull/519))
* Completion blocks added to `BasicCameraAnimator` will no longer be invoked as a side-effect of deinitialization. ([#519](https://github.com/mapbox/mapbox-maps-ios/pull/519))
* Removed the `SupportedLanguage` enum. You may now use `Locale(identifier: String)` as intended. ([#512](https://github.com/mapbox/mapbox-maps-ios/pull/512))
* Removed the `MapView.locale` property. Now, in order to localize values, you must call `mapView.mapboxMap.style.localizeLabels(into: Locale)`. ([#512](https://github.com/mapbox/mapbox-maps-ios/pull/512))

### Bug fixes 🐞

* Clean up network listener after http file source gets out of scope. ([#522](https://github.com/mapbox/mapbox-maps-ios/pull/522))
* Fix `line-center` anchor calculation when the anchor is very near to the line geometry point. ([#522](https://github.com/mapbox/mapbox-maps-ios/pull/522))
* Fix threading issues in HTTP file source. ([#522](https://github.com/mapbox/mapbox-maps-ios/pull/522))
* Fixed an issue that could cause flickering during ease to and basic animations ([#519](https://github.com/mapbox/mapbox-maps-ios/pull/519))
* Fixed an issue that could result in ease to and basic animations never reaching their final values ([#519](https://github.com/mapbox/mapbox-maps-ios/pull/519))

## 10.0.0-rc.3 - June 30, 2021

### Features ✨ and improvements 🏁

* Introduced static method `MapboxMap.clearData(for:completion:)` and instance methods `MapboxMap.clearData(completion:)` and `Snapshotter.clearData(completion:)`. These new methods allow clearing temporary map data. ([#496](https://github.com/mapbox/mapbox-maps-ios/pull/496))
* `MapLoadingError` events now include source and tile information where appropriate. These new fields allow developers to understand what source or tile has failed to load and the reason for the failure. ([#496](https://github.com/mapbox/mapbox-maps-ios/pull/496))

### Bug fixes 🐞

* Fixed a runtime crash that occurred only when the SDK was included as an XCFramework (direct download). ([#497](https://github.com/mapbox/mapbox-maps-ios/pull/497))
* Fixed an issue where animators created by fly to and ease to were not released until the next fly to or ease to began. ([#505](https://github.com/mapbox/mapbox-maps-ios/pull/505))
* Fixed an issue where a complete animator would trigger redrawing unnecessarily. ([#505](https://github.com/mapbox/mapbox-maps-ios/pull/505))
* Fix raster/v1 terrain tiles fetch failures caused by appending pixel ratio to the URLs when tile size is equal to 512 ([#496](https://github.com/mapbox/mapbox-maps-ios/pull/496))
* Improve persistent layer pinning by keeping information about initial LayerPosition ([#496](https://github.com/mapbox/mapbox-maps-ios/pull/496))

## 10.0.0-rc.2 - June 23, 2021

### Features ✨ and improvements 🏁

* Introduced experimental `Style._addPersistentLayer(with:layerPosition:)`, `Style._isPersistentLayer(id:)`, `Style._addPersistentCustomLayer(withId:layerHost:layerPosition:)` APIs, so that the tagged layer and its associated resources remain when a style is reloaded. This improves performance of annotations during a style change. Experimental APIs should be considered liable to change in any SEMVER version. ([#471](https://github.com/mapbox/mapbox-maps-ios/pull/471), [#473](https://github.com/mapbox/mapbox-maps-ios/pull/473))

* Annotations now will persist across style changes by default. ([#475](https://github.com/mapbox/mapbox-maps-ios/pull/475))

* Adds localization support for v10 Maps SDK. This can be used by setting the `mapView.locale`. Use the `SupportedLanguages` enum, which lists currently supported `Locale`. ([#480](https://github.com/mapbox/mapbox-maps-ios/pull/480))
* Fixed Tileset descriptor bug: Completion handler is called even if the `OfflineManager` instance goes out of scope.
* Fixed text rendering when both 'text-rotate' and 'text-offset' are set.

### Breaking changes ⚠️

* MapboxMaps now pins exactly to `MapboxCommon`. ([#485](https://github.com/mapbox/mapbox-maps-ios/pull/485), [#481](https://github.com/mapbox/mapbox-maps-ios/pull/481))

## 10.0.0-rc.1 - June 9, 2021

**The Mapbox Maps SDK for iOS has moved to release candidate status and is now ready for production use.**

### Breaking changes ⚠️

* Converted `MapSnapshotOptions` to a struct. ([#430](https://github.com/mapbox/mapbox-maps-ios/pull/430))
* Removed `CacheManager`. In the following releases, an API to control temporary map data may be provided. ([#440](https://github.com/mapbox/mapbox-maps-ios/pull/440))
* Changed `ResourceOptions.cachePathURL` to `dataPathURL` and removed `cacheSize`. ([#440](https://github.com/mapbox/mapbox-maps-ios/pull/440))
* Annotations don't have a `type` property since they can be directly compared to a type. ([451](https://github.com/mapbox/mapbox-maps-ios/pull/451))
* Internalize extensions of Core and Common types. ([#449](https://github.com/mapbox/mapbox-maps-ios/pull/449))

### Features ✨ and improvements 🏁

* Allows a developer to choose whether the puck is oriented based on `heading` or `course` via a new `puckBearingSource` option in `mapView.location.options`. By default, the puck will be oriented using `heading`. ([#428](https://github.com/mapbox/mapbox-maps-ios/pull/428))

* All stock gesture recognizers are now public on the `GestureManager`. ([450](https://github.com/mapbox/mapbox-maps-ios/pull/450))
* The tap gesture recognizer controlled by any given annotation manager is now public. ([451](https://github.com/mapbox/mapbox-maps-ios/pull/451))

### Bug fixes 🐞

* Fixed a bug where animations were not always honored. ([#443](https://github.com/mapbox/mapbox-maps-ios/pull/443))
* Fixed an issue that vertical text was not positioned correctly if the `text-offset` property was used. ([#440](https://github.com/mapbox/mapbox-maps-ios/pull/440))
* Emit `.mapLoadingError` when an empty token is provided for accessing Mapbox data sources. Before the fix, the application may crash if an empty token was provided and map tries to load data from Mapbox data source. ([#440](https://github.com/mapbox/mapbox-maps-ios/pull/440))
* Do not emit `.mapLoadingError` when an empty URL is set to GeoJSON source. ([#440](https://github.com/mapbox/mapbox-maps-ios/pull/440))

### Dependencies

* Updated MapboxCoreMaps, MapboxCommon and Turf dependencies. ([#440](https://github.com/mapbox/mapbox-maps-ios/pull/440))

## 10.0.0-beta.21 - June 3, 2021

### Breaking changes ⚠️

* Updated MapboxCoreMaps and MapboxCommon dependencies. ([#388](https://github.com/mapbox/mapbox-maps-ios/pull/388))
  * Removed the `MBX` prefix from `MBXGeometry`, `MBXGeometryType` and `MBXFeature`. Existing uses of the similar Turf types need to be fully namespaced, i.e. `Turf.Feature`
  * Introduced separate minZoom/maxZoom fields into CustomGeometrySourceOptions API instead of the formerly used `zoomRange`
  * Improved zooming performance.
  * Fixed terrain transparency issue when a sky layer is not used.
* `MapboxMap.__map` is now private. ([#374](https://github.com/mapbox/mapbox-maps-ios/pull/374))
* Added `CameraManagerProtocol.setCameraBounds`, `MapboxMap.prefetchZoomDelta`, `MapboxMap.options`, `MapboxMap.reduceMemoryUse()`, `MapboxMap.resourceOptions` and `MapboxMap.elevation(at:)`. ([#374](https://github.com/mapbox/mapbox-maps-ios/pull/374))
* Removed `OfflineError.invalidResult` and `OfflineError.typeMismatch`. ([#374](https://github.com/mapbox/mapbox-maps-ios/pull/374))
* Updated `Projection` APIs to be more Swift-like. ([#390](https://github.com/mapbox/mapbox-maps-ios/pull/390))
* Added `ResourceOptionsManager` and removed `CredentialsManager` which it replaces. `ResourceOptions` is now a struct. ([#396](https://github.com/mapbox/mapbox-maps-ios/pull/396))
* Updated the ambient cache path. ([#396](https://github.com/mapbox/mapbox-maps-ios/pull/396))
* Removed `CameraAnimationsManager.setCamera()` and renamed `CameraManagerProtocol._setCamera` to `CameraManagerProtocol.setCamera()`. Use `MapView.mapboxMap.setCamera()` to set the camera. ([#426](https://github.com/mapbox/mapbox-maps-ios/pull/426))
* Removed `MapCameraOptions` and `RenderOptions`; this behavior has moved to both `MapboxMap` and `MapView`. ([#427](https://github.com/mapbox/mapbox-maps-ios/pull/427/files))
* The Annotations library has been rebuilt to expose many more customization options for each annotation. ([#398](https://github.com/mapbox/mapbox-maps-ios/pull/398))
* High level animations return `Cancelable` instead of `CameraAnimator`. ([#400](https://github.com/mapbox/mapbox-maps-ios/pull/400))

### Bug fixes 🐞

* Fixed a bug with `TileStore.tileRegionGeometry` returning invalid value. ([#390](https://github.com/mapbox/mapbox-maps-ios/pull/390))
* Fixed a bug where the underlying renderer was not being destroyed. ([#395](https://github.com/mapbox/mapbox-maps-ios/pull/395))
* Fixed a bug where the snapshotter completion handler was being called twice on cancellation.
([#382](https://github.com/mapbox/mapbox-maps-ios/pull/382))
* Fixed a bug where `GestureManager.delegate` was inaccessible. ([#401](https://github.com/mapbox/mapbox-maps-ios/pull/401))

### Features ✨ and improvements 🏁

* Added `Snapshotter.coordinateBounds(for:)` and `Snapshotter.camera(for:padding:bearing:pitch:)`. ([#386](https://github.com/mapbox/mapbox-maps-ios/pull/386))

### Development 🛠

* Dependency management for development of the SDK has moved to Swift Package Manager and the existing Cartfile has been removed.

## 10.0.0-beta.20 - May 20, 2021

### Breaking changes ⚠️

* `BaseMapView.on()` has now been replaced by `mapView.mapboxMap.onNext(...) -> Cancelable` and `mapView.mapboxMap.onEvery(...) -> Cancelable`. ([#339](https://github.com/mapbox/mapbox-maps-ios/pull/339))
* `StyleURI`, `PreferredFPS`, and `AnimationOwner` are now structs. ([#285](https://github.com/mapbox/mapbox-maps-ios/pull/285))
* The `layout` and `paint` substructs for each layer are now merged into the root layer struct. ([#362](https://github.com/mapbox/mapbox-maps-ios/pull/362))
* `GestureOptions` are owned by `GestureManager` directly. ([#343](https://github.com/mapbox/mapbox-maps-ios/pull/343))
* `LocationOptions` are owned by `LocationManager` directly. ([#344](https://github.com/mapbox/mapbox-maps-ios/pull/344))
* `MapCameraOptions` are owned by `mapView.camera` directly. ([#345](https://github.com/mapbox/mapbox-maps-ios/pull/345))
* `RenderOptions` are owned by `BaseMapView` directly. ([#350](https://github.com/mapbox/mapbox-maps-ios/pull/350))
* `AnnotationOptions` are owned by `AnnotationManager` directly. ([#351](https://github.com/mapbox/mapbox-maps-ios/pull/351))
* `MapView` has been coalesced into `BaseMapView` and the resulting object is called `MapView`. ([#353](https://github.com/mapbox/mapbox-maps-ios/pull/353))
* `Style.uri` is now an optional property. ([#347](https://github.com/mapbox/mapbox-maps-ios/pull/347))
* `Style` is no longer a dependency on `LocationSupportableMapView`. ([#352](https://github.com/mapbox/mapbox-maps-ios/pull/352))
* `Style` now has a more flat structure. `Layout` and `Paint` structs are now obsolete and `Layer` properties are at the root layer. ([#362](https://github.com/mapbox/mapbox-maps-ios/pull/362))
* Changed `LayerPosition` to an enum. ([#](https://github.com/mapbox/mapbox-maps-ios/pull/221))
* Removed `style` from MapView; updated tests and examples to use `mapboxMap.style`. ([#361](https://github.com/mapbox/mapbox-maps-ios/pull/361))
* The `visibleFeatures` APIs have been renamed to `queryRenderedFeatures`. ([#361](https://github.com/mapbox/mapbox-maps-ios/pull/361))
* `LoggingConfiguration` is no longer public. ([#361](https://github.com/mapbox/mapbox-maps-ios/pull/361))
* The following Swift wrappers have been added for existing types; these primarily change callbacks from using an internal `MBXExpected` type to using Swift's `Result` type. ([#361](https://github.com/mapbox/mapbox-maps-ios/pull/361))
  * `CacheManager`
  * `HttpResponse`
  * `OfflineSwitch` (which replaces NetworkConnectivity)
  * `OfflineRegionManager` (though this API is deprecated)
* Adds `loadStyleURI` and `loadStyleJSON` to `MapboxMap`. ([#354](https://github.com/mapbox/mapbox-maps-ios/pull/354))

### Bug fixes 🐞

* Fixed an issue where the map's scale bar and compass view could trigger `layoutSubviews()` for the map view. ([#338](https://github.com/mapbox/mapbox-maps-ios/pull/338))

## 10.0.0-beta.19.1 - May 7, 2021

### Breaking changes ⚠️

* `OrnamentOptions.logo._isVisible` and `OrnamentOptions.attributionButton._isVisible` have been replaced with `OrnamentOptions.logo.visibility` and `OrnamentOptions.attributionButton.visibility`. ([#326](https://github.com/mapbox/mapbox-maps-ios/pull/326))

### Bug fixes 🐞

* Fixed an issue where location pucks would not be rendered. ([#331](https://github.com/mapbox/mapbox-maps-ios/pull/331))

## 10.0.0-beta.19 - May 6, 2021

### Breaking changes ⚠️

* `camera(for:)` methods have moved from `BaseMapView` to `MapboxMap` ([#286](https://github.com/mapbox/mapbox-maps-ios/pull/286))
  * The API has also been aligned with Android by:
    * Removing default values for parameters
    * Making `bearing` and `pitch` parameters optional
    * Adding the `camera(for:camera:rect:)` variant
* `OrnamentOptions` should now be accessed via `MapView.ornaments.options`. `MapConfig.ornaments` has been removed. Updates can be applied directly to `OrnamentsManager.options`. Previously the map's ornament options were updated on `MapConfig.ornaments` with `MapView.update`. ([#310](https://github.com/mapbox/mapbox-maps-ios/pull/310))
* `OrnamentOptions` now uses structs to manage options for individual ornaments. For example, `OrnamentOptions.scaleBarPosition` is now `OrnamentOptions.scaleBar.position`. ([#318](https://github.com/mapbox/mapbox-maps-ios/pull/318))
* The `LogoView` class is now private. ([#310](https://github.com/mapbox/mapbox-maps-ios/pull/310))
* `Style` has been significantly refactored, for example:
  * Synchronous APIs returning `Result` types now throw.
  * A number of APIs previously accessed via `__map` are now available via the `Style` object.
  * APIs with a `get` prefix have been renamed; for example `getLayer<T>(with:type:)` to `layer<T>(withId:type:) throws` and `getSource<T>(id:type:)` to `source<T>(withId:type:) throws`

### Features ✨ and improvements 🏁

* `OrnamentsManager` is now a public class and can be accessed via the `MapView`'s `ornaments` property.
* `CompassDirectionFormatter` is now public. It provides a string representation of a `CLLocationDirection` and supports the same languages as in pre-v10 versions of the Maps SDK. ([#300](https://github.com/mapbox/mapbox-maps-ios/pull/300))- `OrnamentOptions` should now be accessed via `MapView.ornaments.options`. Updates can be applied directly to the `options` property. Previously the map's ornament options were updated via `MapConfig.ornaments`. ([#310](https://github.com/mapbox/mapbox-maps-ios/pull/310))
* The `LogoView` class is now private. ([#310](https://github.com/mapbox/mapbox-maps-ios/pull/310))

## 10.0.0-beta.18.1 - April 28, 2021

### Breaking changes ⚠️

* #### Camera Animations

  * A new `CameraTransition` struct has been introduced to allow better control on the "from" and "to" values of a camera animation ([#282](https://github.com/mapbox/mapbox-maps-ios/pull/282))
    * A mutable version of the `CameraTransition` struct is passed into every animation block.
  * Animations can only be constructor injected into `CameraAnimator` as part of the `makeAnimator*` methods on `mapView.camera`.
  * The `makeCameraAnimator*` methods have been renamed to `makeAnimator*` methods

* #### Gestures

  * Gestures now directly call `__map.setCamera()` instead of using CoreAnimation

## 10.0.0-beta.18 - April 23, 2021

### Breaking changes ⚠️

* #### `MapView`

  * The initializer has changed to `public init(frame: CGRect, mapInitOptions: MapInitOptions = MapInitOptions(), styleURI: StyleURI? = .streets)`.
  * `MapOptions` has been renamed `MapConfig`. A new `MapOptions` has been introduced; its properties are required to initialize the underlying map object.
  * A `MapInitOptions` configuration struct has been introduced. It currently wraps both `ResourceOptions` and `MapOptions` and is used when initializing a `MapView`.
  * `baseURL` and `accessToken` can no longer be set from a nib or storyboard. Instead a new `MapInitOptionsProvider` protocol and an `IBOutlet` on `MapView` has been introduced to allow a customer `MapInitOptions` to be provided to the `MapView`. This provider is not used when initializing a `MapView` programmatically.
  * The `Manager` suffix has been removed from `MapView.gesturesManager`, `MapView.ornamentsManager`, `MapView.cameraManager`, `MapView.locationManager`, and `MapView.annotationsManager`.
  * `BaseMapView.camera` has been renamed to `BaseMapView.cameraOptions`.

* #### Foundation

  * `AccountManager` has been removed. A new `CredentialsManager` replaces it. You can use `CredentialsManager.default` to set a global access token.
  * MapboxCoreMaps protocol conformances have been encapsulated. ([#265](https://github.com/mapbox/mapbox-maps-ios/pull/265))
    * `ObserverConcrete` has been removed.
    * `BaseMapView` no longer conforms to `MapClient` or `MBMMetalViewProvider`, and the methods they required are now internal.
    * The setter for `BaseMapView.__map` is now private
    * `Snapshotter` no longer conforms to `Observer`, and the method it required is now internal.
  * The `BaseMapView.__map` property has been moved to `BaseMapView.mapboxMap.__map`. ([#280](https://github.com/mapbox/mapbox-maps-ios/pull/280))
  * A `CameraOptions` struct has been introduced. This shadows the class of the same name from MapboxCoreMaps and. This avoids unintended sharing and better reflects the intended value semantics of the `CameraOptions` concept. ([#284](https://github.com/mapbox/mapbox-maps-ios/pull/284))

* #### Dependencies

  * Updated dependencies to MapboxCoreMaps 10.0.0-beta.20 and MapboxCommon 11.0.1
  * ResourceOptions now contains a `TileStore` instance. Tile store usage is enabled by default, the resource option `tileStoreEnabled` flag is introduced to disable it.
  * `TileStore` no longer returns cached responses for 401, 403 and unauthorized requests.
  * Fixed a bug where `TileStore` would not invoke completion closures (when client code did not keep a strong reference to the tile store instance).

### Features ✨ and improvements 🏁

* Introduced the `OfflineManager` API that manages style packs and produces tileset descriptors for use with the tile store. The `OfflineManager` and `TileStore` APIs are used in conjunction to download offline regions and associated "style packs". These new APIs replace the deprecated `OfflineRegionManager`. Please see the new `OfflineManager` guide for more details.

### Bug fixes 🐞

* Fixed a crash in line layer rendering, where the uniform buffer size had an incorrect value.

## 10.0.0-beta.17 - April 13, 2021

### Breaking changes ⚠️

* `AnnotationManager` no longer conforms to `Observer` and no longer has a `peer` ([#246](https://github.com/mapbox/mapbox-maps-ios/pull/246))
* `AnnotationSupportableMap` is now internal ([#246](https://github.com/mapbox/mapbox-maps-ios/pull/246))

* #### MapView

  * Initializer has been changed to `public init(frame: CGRect, resourceOptions: ResourceOptions, glyphsRasterizationOptions: GlyphsRasterizationOptions = GlyphsRasterizationOptions.default, styleURI: StyleURI? = .streets)`.
  * `StyleURL` has been renamed to `StyleURI`
  * `OrnamentSupportableMapView` is not internal.

* #### Ornaments

  * `LayoutPosition` has been deprecated in favor of `OrnamentPosition`.
  * `LayoutVisibility` has been deprecated in favor of `OrnamentVisibility`.
  * `showsLogoView` has been renamed to `_showsLogoView`.
  * `showsCompass` and `showsScale` have been deprecated. Visibility properties can be used to set how the Compass and Scale Bar should be shown.

* #### Foundation

  * `cancelTransitions` has been renamed to `cancelAnimations`.
  * [`setCamera()`](https://github.com/mapbox/mapbox-maps-ios/pull/250/files#diff-8fa667141ac423a208a6e7036ed759e7e52fc6940bd58834c1935c2c6ead9c65L177) with individual parameters has been deprecated in favor of [`setCamera(to targetCamera: CameraOptions...)`](https://github.com/mapbox/mapbox-maps-ios/blob/edbf08e37975c81c7ee1cbc4bb046c48d522d306/Sources/MapboxMaps/Foundation/Camera/CameraManager.swift#L140) which requires `CameraOptions`.
  * The following camera convenience functions have been removed:
    * `public func transitionCoordinateBounds(newCoordinateBounds: CoordinateBounds, animated: Bool = false)`
    * `public func transitionCoordinateBounds(to newCoordinateBounds: CoordinateBounds, edgePadding: UIEdgeInsets, animated: Bool = false, completion: ((UIViewAnimatingPosition) -> Void)? = nil)`
    * `public func transitionVisibleCoordinates(newCoordinates: [CLLocationCoordinate2D], edgePadding: UIEdgeInsets, animated: Bool = false)`
    * `public func transitionVisibleCoordinates(to newCoordinates: [CLLocationCoordinate2D], edgePadding: UIEdgeInsets, bearing: CLLocationDirection, duration: TimeInterval, animated: Bool = false, completion: ((UIViewAnimatingPosition) -> Void)? = nil)`
    * `public func resetPosition()`
    * `public func resetNorth(_ animated: Bool = false)`
  * In `CameraAnimator`, `fractionComplete` is now of type `Double` and `delayFactor` now returns a `Double`.
  * `MapboxLogoView` has been renamed to `LogoView`.
  * `MapboxLogoSize` has been renamed to `LogoSize`.

* #### Style

  * Initializer is now marked as internal.
  * `styleUri` property has been renamed to `uri`.
  * The `url` property from `StyleURL` has been removed.

* #### Expressions

  * `init(from: jsonObject)` and `public func jsonObject()` have been removed.
  * `Element.op` has been renamed to `Element.operator`.
  * `Argument.array` has been renamed to `Argument.numberArray`.
  * `ValidExpressionArgument` has been renamed to `ExpressionArgumentConvertible`

### Bug fixes 🐞

* Fixes an issue that could prevent annotations from being selectable. ([#246](https://github.com/mapbox/mapbox-maps-ios/pull/246))
* Fixes an issue where some JSON layers are not be decoded correctly. ([#248](https://github.com/mapbox/mapbox-maps-ios/pull/248))
* Fixes an issue where the location puck was not animating. ([#256](https://github.com/mapbox/mapbox-maps-ios/pull/256))

## 10.0.0-beta.16 - March 29, 2021

### Breaking changes ⚠️

* The `CameraManager.moveCamera` method has been removed. ([#217](https://github.com/mapbox/mapbox-maps-ios/pull/217))
* `UIView.animate` is no longer supported. Instead, use `CameraAnimators`. ([#217](https://github.com/mapbox/mapbox-maps-ios/pull/217))
* Developers should make camera changes directly to `MapView`'s camera
  properties. Previously, changes could be applied to `MapView.cameraView`. ([#217](https://github.com/mapbox/mapbox-maps-ios/pull/217))
* `CameraAnimator` objects are managed by developers and should be stored by
  developers to prevent the animations from falling out of scope.
* `LocationOptions.showUserLocation` has been removed. Use
  `LocationOptions.puckType` instead, setting it to `nil` if you do not want to
  show the user location. `LocationManager.showUserLocation` has also been
  removed. ([#203](https://github.com/mapbox/mapbox-maps-ios/pull/203))
* Make model layer internal and refactor for increased public API clarity
  ([#194](https://github.com/mapbox/mapbox-maps-ios/pull/194), [#198](https://github.com/mapbox/mapbox-maps-ios/pull/198))
  * `ModelLayer` and `ModelSource` are now internal
  * `shouldTrackLocation` flag has been removed from `LocationConsumer` because
    it was never used
  * `PuckType.puck2D`'s associated value is now non-optional. It still has a
    default value corresponding to the previous behavior
  * `LocationPuckManager` is now internal
  * Renaming:
    * `LocationPuck` is now `PuckType`
    * `LocationOptions.locationPuck` is now `LocationOptions.puckType`
    * `LocationIndicatorLayerViewModel` is now `Puck2DConfiguration`
    * `PuckModelLayerViewModel` is now `Puck3DConfiguration`
* Updates dependencies to MapboxCoreMaps 10.0.0-beta.17 and MapboxCommon 10.0.2.
  ([#193](https://github.com/mapbox/mapbox-maps-ios/pull/193))
  * [rendering] Query rendered features now work for fill-extrusions when
    terrain is enabled.
  * [rendering] Improved terrain rendering performance due to reduction of
    loaded tiles.
* All layer paint/layout properties can be defined via expressions ([#185](https://github.com/mapbox/mapbox-maps-ios/pull/185))
* Added RawRepresentable conformance to StyleURL. Removed enum cases for older
  style versions. ([#168](https://github.com/mapbox/mapbox-maps-ios/pull/168))

### Features ✨ and improvements 🏁

* Introduced the platform-driven Drag API for shifting the map’s camera. ([#217](https://github.com/mapbox/mapbox-maps-ios/pull/217))
* Introduced `CameraAnimator`, a UIViewPropertyAnimator-based class for
  animating camera changes. These animators should be created using
  `CameraManager.makeCameraAnimator` methods. ([#217](https://github.com/mapbox/mapbox-maps-ios/pull/217))
* Gesture-driven camera changes have been updated to use camera animators. ([#217](https://github.com/mapbox/mapbox-maps-ios/pull/217))
* The `AnimatorOwner` enum has been added to track owners for individual
  animators. ([#217](https://github.com/mapbox/mapbox-maps-ios/pull/217))
* `CameraManager.fly(to:)` is now built on camera animators. `zoom`, `pitch`,
  `bearing`, and `centerCoordinate` keyframes are supported. ([#217](https://github.com/mapbox/mapbox-maps-ios/pull/217))
* The getter for LocationManager.locationOptions is now public. ([#209](https://github.com/mapbox/mapbox-maps-ios/pull/209))
* Added function to get layer identifier for an annotation type. ([#189](https://github.com/mapbox/mapbox-maps-ios/pull/189))
* Add PreferredFPS.custom() to add support for custom preferred frames per
  second values. ([#157](https://github.com/mapbox/mapbox-maps-ios/pull/157))

### Bug fixes 🐞

* Fixes an issue in which the puck was not reflecting updates to its
  configuration ([#199](https://github.com/mapbox/mapbox-maps-ios/pull/199))

## 10.0.0-beta.15 - March 4, 2021

### Breaking changes ⚠️

* Updates MapboxCoreMaps to v10.0.0.beta.16 and MapboxCommon to v10.0.0-beta.12 ([#152](https://github.com/mapbox/mapbox-maps-ios/pull/152))

### New Events API

* The above breaking change introduces the new Map Events API which will:
  * Simplify the Map API and align it with other weakly typed interfaces
    (addStyleLayer, addStyleSource, etc.).
  * Minimize the effort for addition of new events.
  * Expose experimental events.
  * Suppress events that a developer hasn't subscribed to.
  * Automatically expose new events for Snapshotter (eliminating the need to
    modify MapObserver and MapSnapshotterObserver separately).
* Events that have been removed:
  * `mapResumedRendering`
  * `mapPausedRendering`
  * `mapLoadingStarted`
  * `renderMapStarted`
  * `renderMapFinished`
  * `cameraWillChange`
  * `cameraIsChanging`
* Events that have been renamed:
  * `EventType.Map.mapLoaded` -> `EventType.Map.loaded`
  * `MapEvents.EventKind.cameraDidChange` -> `MapEvents.EventKind.cameraChanged`

### Features ✨ and improvements 🏁

* Maps SDK now supports a static bundle via direct download ([#149](https://github.com/mapbox/mapbox-maps-ios/pull/149))

## 10.0.0-beta.14 - February 24, 2021

### Breaking changes ⚠️

* Updates Turf to v2.0.0-alpha.3 ([#133](https://github.com/mapbox/mapbox-maps-ios/pull/133))

### Features ✨ and improvements 🏁

* Added SwiftUI example. ([#78](https://github.com/mapbox/mapbox-maps-ios/pull/78))
* Allow a developer to synchronously update a layer with one API call -- no
  longer have to retrieve and re-add a layer. ([#85](https://github.com/mapbox/mapbox-maps-ios/pull/85))
* MapboxMaps can now be built and tested using Swift Package Manager ([#125](https://github.com/mapbox/mapbox-maps-ios/pull/125))

### Bug fixes 🐞

* Prevent pitch and zoom from exceeding limits. Also updates default maximum
  pitch to 85 degrees. ([#103](https://github.com/mapbox/mapbox-maps-ios/pull/103))
* Fixed an issue where quick zoom did not work at higher zoom levels. Also made
  the duration argument of the setCamera methods non-optional with default of 0.
  ([#109](https://github.com/mapbox/mapbox-maps-ios/pull/109))
* GestureManager.delegate is now weak ([#134](https://github.com/mapbox/mapbox-maps-ios/pull/134))
* Using heuristic to provide pan drift when the map is pitched ([#120](https://github.com/mapbox/mapbox-maps-ios/pull/120))

## 10.0.0-beta.13 - February 12, 2021

### Breaking changes ⚠️

* Rely on consumer provided view models directly to customize location pucks  ([#86](https://github.com/mapbox/mapbox-maps-ios/pull/86))
* Update Mapbox Common for iOS to v10.0.0-beta.9.1 and MapboxCoreMaps to
  v10.0.0-beta.14.1. ([#89](https://github.com/mapbox/mapbox-maps-ios/pull/89))
* Update to Turf 2.0.0-alpha.2 ([#93](https://github.com/mapbox/mapbox-maps-ios/pull/93))

### Features ✨ and improvements 🏁

* Expose `presentsWithTransaction` property to better synchronize UIKit elements
  with the `MapView`. ([#94](https://github.com/mapbox/mapbox-maps-ios/pull/94))
* Add MapEvents.styleFullyLoaded.  ([#90](https://github.com/mapbox/mapbox-maps-ios/pull/90))

### Bug fixes 🐞

* Refactor Annotation "properties" ([#70](https://github.com/mapbox/mapbox-maps-ios/pull/70))
* Fix Inconsistent Camera Heading ([#68](https://github.com/mapbox/mapbox-maps-ios/pull/68))
* Fix issue where updates to ornament options were not honored ([#84](https://github.com/mapbox/mapbox-maps-ios/pull/84))
* Dictionaries passed to expressions are now sorted by default ([#81](https://github.com/mapbox/mapbox-maps-ios/pull/81))
* Fixed: Pan drift did not work correctly when bearing was non-zero. ([#99](https://github.com/mapbox/mapbox-maps-ios/pull/99))
* Fix issue where toggling LocationOptions.showsUserLocation resulted in options
  not being updated ([#101](https://github.com/mapbox/mapbox-maps-ios/pull/101))
* Pan drift for pitched maps will be disabled. A solution for smooth drifting is
  being worked on. ([#100](https://github.com/mapbox/mapbox-maps-ios/pull/100))

## 10.0.0-beta.12 - January 27, 2021

### Announcement

V10 is the latest version of the Mapbox Maps SDK for iOS. v10 brings substantial
performance improvements, new features like 3D terrain and a more powerful
camera, modern technical foundations, and a better developer experience.

To get started with v10, please refer to our [migration guide](https://docs.mapbox.com/ios/beta/maps/guides/migrate-to-v10/).

### Known Issues

Please visit our [issues](https://github.com/mapbox/mapbox-maps-ios/issues) to
see open bugs, enhancements, or features requests.
