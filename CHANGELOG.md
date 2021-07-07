# Changelog for Mapbox Maps SDK v10 for iOS

Mapbox welcomes participation and contributions from everyone.

## main

### Features ✨ and improvements 🏁

* Support `text-writing-mode` property for line symbol-placement text labels. ([#522](https://github.com/mapbox/mapbox-maps-ios/pull/522))
  Note: This change will bring following changes for CJK text block:
  1. For vertical CJK text, all the characters including Latin and Numbers will be vertically placed now. Previously, Latin and Numbers are horizontally placed.
  2. For horizontal CJK text, it may have a slight horizontal shift due to the anchor shift.

### Breaking changes ⚠️

* `TileRegionError` has a new case `tileCountExceeded(String)`. ([#522](https://github.com/mapbox/mapbox-maps-ios/pull/522))
* FlyToCameraAnimator.state will now be `.inactive` after it completes or is stopped. This change makes its behavior consistent with the behavior of `BasicCameraAnimator`. ([#519](https://github.com/mapbox/mapbox-maps-ios/pull/519))
* Completion blocks added to `BasicCameraAnimator` will no longer be invoked as a side-effect of deinitialization. ([#519](https://github.com/mapbox/mapbox-maps-ios/pull/519))

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
- Annotations now will persist across style changes by default. ([#475](https://github.com/mapbox/mapbox-maps-ios/pull/475))
- Adds localization support for v10 Maps SDK. This can be used by setting the `mapView.locale`. Use the `SupportedLanguages` enum, which lists currently supported `Locale`. ([#480](https://github.com/mapbox/mapbox-maps-ios/pull/480))
- Fixed Tileset descriptor bug: Completion handler is called even if the `OfflineManager` instance goes out of scope.
- Fixed text rendering when both 'text-rotate' and 'text-offset' are set.

### Breaking changes ⚠️

- MapboxMaps now pins exactly to `MapboxCommon`. ([#485](https://github.com/mapbox/mapbox-maps-ios/pull/485), [#481](https://github.com/mapbox/mapbox-maps-ios/pull/481))

## 10.0.0-rc.1 - June 9, 2021

**The Mapbox Maps SDK for iOS has moved to release candidate status and is now ready for production use.**

### Breaking changes ⚠️

- Converted `MapSnapshotOptions` to a struct. ([#430](https://github.com/mapbox/mapbox-maps-ios/pull/430))
- Removed `CacheManager`. In the following releases, an API to control temporary map data may be provided. ([#440](https://github.com/mapbox/mapbox-maps-ios/pull/440))
- Changed `ResourceOptions.cachePathURL` to `dataPathURL` and removed `cacheSize`. ([#440](https://github.com/mapbox/mapbox-maps-ios/pull/440))
- Annotations don't have a `type` property since they can be directly compared to a type. ([451](https://github.com/mapbox/mapbox-maps-ios/pull/451))
- Internalize extensions of Core and Common types. ([#449](https://github.com/mapbox/mapbox-maps-ios/pull/449))

### Features ✨ and improvements 🏁
- Allows a developer to choose whether the puck is oriented based on `heading` or `course` via a new `puckBearingSource` option in `mapView.location.options`. By default, the puck will be oriented using `heading`. ([#428](https://github.com/mapbox/mapbox-maps-ios/pull/428))
- All stock gesture recognizers are now public on the `GestureManager`. ([450](https://github.com/mapbox/mapbox-maps-ios/pull/450))
- The tap gesture recognizer controlled by any given annotation manager is now public. ([451](https://github.com/mapbox/mapbox-maps-ios/pull/451))

### Bug fixes 🐞

- Fixed a bug where animations were not always honored. ([#443](https://github.com/mapbox/mapbox-maps-ios/pull/443))
- Fixed an issue that vertical text was not positioned correctly if the `text-offset` property was used. ([#440](https://github.com/mapbox/mapbox-maps-ios/pull/440))
- Emit `.mapLoadingError` when an empty token is provided for accessing Mapbox data sources. Before the fix, the application may crash if an empty token was provided and map tries to load data from Mapbox data source. ([#440](https://github.com/mapbox/mapbox-maps-ios/pull/440))
- Do not emit `.mapLoadingError` when an empty URL is set to GeoJSON source. ([#440](https://github.com/mapbox/mapbox-maps-ios/pull/440))

### Dependencies

- Updated MapboxCoreMaps, MapboxCommon and Turf dependencies. ([#440](https://github.com/mapbox/mapbox-maps-ios/pull/440))

## 10.0.0-beta.21 - June 3, 2021

### Breaking changes ⚠️

- Updated MapboxCoreMaps and MapboxCommon dependencies. ([#388](https://github.com/mapbox/mapbox-maps-ios/pull/388))
  - Removed the `MBX` prefix from `MBXGeometry`, `MBXGeometryType` and `MBXFeature`. Existing uses of the similar Turf types need to be fully namespaced, i.e. `Turf.Feature`
  - Introduced separate minZoom/maxZoom fields into CustomGeometrySourceOptions API instead of the formerly used `zoomRange`
  - Improved zooming performance.
  - Fixed terrain transparency issue when a sky layer is not used.
- `MapboxMap.__map` is now private. ([#374](https://github.com/mapbox/mapbox-maps-ios/pull/374))
- Added `CameraManagerProtocol.setCameraBounds`, `MapboxMap.prefetchZoomDelta`, `MapboxMap.options`, `MapboxMap.reduceMemoryUse()`, `MapboxMap.resourceOptions` and `MapboxMap.elevation(at:)`. ([#374](https://github.com/mapbox/mapbox-maps-ios/pull/374))
- Removed `OfflineError.invalidResult` and `OfflineError.typeMismatch`. ([#374](https://github.com/mapbox/mapbox-maps-ios/pull/374))
- Updated `Projection` APIs to be more Swift-like. ([#390](https://github.com/mapbox/mapbox-maps-ios/pull/390))
- Added `ResourceOptionsManager` and removed `CredentialsManager` which it replaces. `ResourceOptions` is now a struct. ([#396](https://github.com/mapbox/mapbox-maps-ios/pull/396))
- Updated the ambient cache path. ([#396](https://github.com/mapbox/mapbox-maps-ios/pull/396))
- Removed `CameraAnimationsManager.setCamera()` and renamed `CameraManagerProtocol._setCamera` to `CameraManagerProtocol.setCamera()`. Use `MapView.mapboxMap.setCamera()` to set the camera. ([#426](https://github.com/mapbox/mapbox-maps-ios/pull/426))
- Removed `MapCameraOptions` and `RenderOptions`; this behavior has moved to both `MapboxMap` and `MapView`. ([#427](https://github.com/mapbox/mapbox-maps-ios/pull/427/files))
- The Annotations library has been rebuilt to expose many more customization options for each annotation. ([#398](https://github.com/mapbox/mapbox-maps-ios/pull/398))
- High level animations return `Cancelable` instead of `CameraAnimator`. ([#400](https://github.com/mapbox/mapbox-maps-ios/pull/400))

### Bug fixes 🐞

- Fixed a bug with `TileStore.tileRegionGeometry` returning invalid value. ([#390](https://github.com/mapbox/mapbox-maps-ios/pull/390))
- Fixed a bug where the underlying renderer was not being destroyed. ([#395](https://github.com/mapbox/mapbox-maps-ios/pull/395))
- Fixed a bug where the snapshotter completion handler was being called twice on cancellation.
([#382](https://github.com/mapbox/mapbox-maps-ios/pull/382))
- Fixed a bug where `GestureManager.delegate` was inaccessible. ([#401](https://github.com/mapbox/mapbox-maps-ios/pull/401))

### Features ✨ and improvements 🏁

- Added `Snapshotter.coordinateBounds(for:)` and `Snapshotter.camera(for:padding:bearing:pitch:)`. ([#386](https://github.com/mapbox/mapbox-maps-ios/pull/386))

### Development 🛠

- Dependency management for development of the SDK has moved to Swift Package Manager and the existing Cartfile has been removed.

## 10.0.0-beta.20 - May 20, 2021

### Breaking changes ⚠️

 - `BaseMapView.on()` has now been replaced by `mapView.mapboxMap.onNext(...) -> Cancelable` and `mapView.mapboxMap.onEvery(...) -> Cancelable`. ([#339](https://github.com/mapbox/mapbox-maps-ios/pull/339))
 - `StyleURI`, `PreferredFPS`, and `AnimationOwner` are now structs. ([#285](https://github.com/mapbox/mapbox-maps-ios/pull/285))
 - The `layout` and `paint` substructs for each layer are now merged into the root layer struct. ([#362](https://github.com/mapbox/mapbox-maps-ios/pull/362))
 - `GestureOptions` are owned by `GestureManager` directly. ([#343](https://github.com/mapbox/mapbox-maps-ios/pull/343))
 - `LocationOptions` are owned by `LocationManager` directly. ([#344](https://github.com/mapbox/mapbox-maps-ios/pull/344))
 - `MapCameraOptions` are owned by `mapView.camera` directly. ([#345](https://github.com/mapbox/mapbox-maps-ios/pull/345))
 - `RenderOptions` are owned by `BaseMapView` directly. ([#350](https://github.com/mapbox/mapbox-maps-ios/pull/350))
 - `AnnotationOptions` are owned by `AnnotationManager` directly. ([#351](https://github.com/mapbox/mapbox-maps-ios/pull/351))
 - `MapView` has been coalesced into `BaseMapView` and the resulting object is called `MapView`. ([#353](https://github.com/mapbox/mapbox-maps-ios/pull/353))
 - `Style.uri` is now an optional property. ([#347](https://github.com/mapbox/mapbox-maps-ios/pull/347))
 - `Style` is no longer a dependency on `LocationSupportableMapView`. ([#352](https://github.com/mapbox/mapbox-maps-ios/pull/352))
 - `Style` now has a more flat structure. `Layout` and `Paint` structs are now obsolete and `Layer` properties are at the root layer. ([#362](https://github.com/mapbox/mapbox-maps-ios/pull/362))
 - Changed `LayerPosition` to an enum. ([#](https://github.com/mapbox/mapbox-maps-ios/pull/221))
 - Removed `style` from MapView; updated tests and examples to use `mapboxMap.style`. ([#361](https://github.com/mapbox/mapbox-maps-ios/pull/361))
 - The `visibleFeatures` APIs have been renamed to `queryRenderedFeatures`. ([#361](https://github.com/mapbox/mapbox-maps-ios/pull/361))
 - `LoggingConfiguration` is no longer public. ([#361](https://github.com/mapbox/mapbox-maps-ios/pull/361))
 - The following Swift wrappers have been added for existing types; these primarily change callbacks from using an internal `MBXExpected` type to using Swift's `Result` type. ([#361](https://github.com/mapbox/mapbox-maps-ios/pull/361))
     - `CacheManager`
     - `HttpResponse`
     - `OfflineSwitch` (which replaces NetworkConnectivity)
     - `OfflineRegionManager` (though this API is deprecated)
 - Adds `loadStyleURI` and `loadStyleJSON` to `MapboxMap`. ([#354](https://github.com/mapbox/mapbox-maps-ios/pull/354))

### Bug fixes 🐞

- Fixed an issue where the map's scale bar and compass view could trigger `layoutSubviews()` for the map view. ([#338](https://github.com/mapbox/mapbox-maps-ios/pull/338))

## 10.0.0-beta.19.1 - May 7, 2021

### Breaking changes ⚠️

  - `OrnamentOptions.logo._isVisible` and `OrnamentOptions.attributionButton._isVisible` have been replaced with `OrnamentOptions.logo.visibility` and `OrnamentOptions.attributionButton.visibility`. ([#326](https://github.com/mapbox/mapbox-maps-ios/pull/326))

### Bug fixes 🐞

  - Fixed an issue where location pucks would not be rendered. ([#331](https://github.com/mapbox/mapbox-maps-ios/pull/331))

## 10.0.0-beta.19 - May 6, 2021

### Breaking changes ⚠️

- `camera(for:)` methods have moved from `BaseMapView` to `MapboxMap` ([#286](https://github.com/mapbox/mapbox-maps-ios/pull/286))
  * The API has also been aligned with Android by:
      * Removing default values for parameters
      * Making `bearing` and `pitch` parameters optional
      * Adding the `camera(for:camera:rect:)` variant
- `OrnamentOptions` should now be accessed via `MapView.ornaments.options`. `MapConfig.ornaments` has been removed. Updates can be applied directly to `OrnamentsManager.options`. Previously the map's ornament options were updated on `MapConfig.ornaments` with `MapView.update`. ([#310](https://github.com/mapbox/mapbox-maps-ios/pull/310))
- `OrnamentOptions` now uses structs to manage options for individual ornaments. For example, `OrnamentOptions.scaleBarPosition` is now `OrnamentOptions.scaleBar.position`. ([#318](https://github.com/mapbox/mapbox-maps-ios/pull/318))
- The `LogoView` class is now private. ([#310](https://github.com/mapbox/mapbox-maps-ios/pull/310))
- `Style` has been significantly refactored, for example:
  - Synchronous APIs returning `Result` types now throw.
  - A number of APIs previously accessed via `__map` are now available via the `Style` object.
  - APIs with a `get` prefix have been renamed; for example `getLayer<T>(with:type:)` to `layer<T>(withId:type:) throws` and `getSource<T>(id:type:)` to `source<T>(withId:type:) throws`

### Features ✨ and improvements 🏁

- `OrnamentsManager` is now a public class and can be accessed via the `MapView`'s `ornaments` property.
- `CompassDirectionFormatter` is now public. It provides a string representation of a `CLLocationDirection` and supports the same languages as in pre-v10 versions of the Maps SDK. ([#300](https://github.com/mapbox/mapbox-maps-ios/pull/300))- `OrnamentOptions` should now be accessed via `MapView.ornaments.options`. Updates can be applied directly to the `options` property. Previously the map's ornament options were updated via `MapConfig.ornaments`. ([#310](https://github.com/mapbox/mapbox-maps-ios/pull/310))
- The `LogoView` class is now private. ([#310](https://github.com/mapbox/mapbox-maps-ios/pull/310))

## 10.0.0-beta.18.1 - April 28, 2021

### Breaking changes ⚠️

- #### Camera Animations
  * A new `CameraTransition` struct has been introduced to allow better control on the "from" and "to" values of a camera animation ([#282](https://github.com/mapbox/mapbox-maps-ios/pull/282))
     * A mutable version of the `CameraTransition` struct is passed into every animation block.
  * Animations can only be constructor injected into `CameraAnimator` as part of the `makeAnimator*` methods on `mapView.camera`.
  * The `makeCameraAnimator*` methods have been renamed to `makeAnimator*` methods

- #### Gestures
  - Gestures now directly call `__map.setCamera()` instead of using CoreAnimation

## 10.0.0-beta.18 - April 23, 2021

### Breaking changes ⚠️

- #### `MapView`
  * The initializer has changed to `public init(frame: CGRect, mapInitOptions: MapInitOptions = MapInitOptions(), styleURI: StyleURI? = .streets)`.
  * `MapOptions` has been renamed `MapConfig`. A new `MapOptions` has been introduced; its properties are required to initialize the underlying map object.
  * A `MapInitOptions` configuration struct has been introduced. It currently wraps both `ResourceOptions` and `MapOptions` and is used when initializing a `MapView`.
  * `baseURL` and `accessToken` can no longer be set from a nib or storyboard. Instead a new `MapInitOptionsProvider` protocol and an `IBOutlet` on `MapView` has been introduced to allow a customer `MapInitOptions` to be provided to the `MapView`. This provider is not used when initializing a `MapView` programmatically.
  * The `Manager` suffix has been removed from `MapView.gesturesManager`, `MapView.ornamentsManager`, `MapView.cameraManager`, `MapView.locationManager`, and `MapView.annotationsManager`.
  * `BaseMapView.camera` has been renamed to `BaseMapView.cameraOptions`.

- #### Foundation
  * `AccountManager` has been removed. A new `CredentialsManager` replaces it. You can use `CredentialsManager.default` to set a global access token.
  * MapboxCoreMaps protocol conformances have been encapsulated. ([#265](https://github.com/mapbox/mapbox-maps-ios/pull/265))
      * `ObserverConcrete` has been removed.
      * `BaseMapView` no longer conforms to `MapClient` or `MBMMetalViewProvider`, and the methods they required are now internal.
      * The setter for `BaseMapView.__map` is now private
      * `Snapshotter` no longer conforms to `Observer`, and the method it required is now internal.
  * The `BaseMapView.__map` property has been moved to `BaseMapView.mapboxMap.__map`. ([#280](https://github.com/mapbox/mapbox-maps-ios/pull/280))
  * A `CameraOptions` struct has been introduced. This shadows the class of the same name from MapboxCoreMaps and. This avoids unintended sharing and better reflects the intended value semantics of the `CameraOptions` concept. ([#284](https://github.com/mapbox/mapbox-maps-ios/pull/284))  

- #### Dependencies
  * Updated dependencies to MapboxCoreMaps 10.0.0-beta.20 and MapboxCommon 11.0.1
  * ResourceOptions now contains a `TileStore` instance. Tile store usage is enabled by default, the resource option `tileStoreEnabled` flag is introduced to disable it.  
  * `TileStore` no longer returns cached responses for 401, 403 and unauthorized requests.
  * Fixed a bug where `TileStore` would not invoke completion closures (when client code did not keep a strong reference to the tile store instance).


### Features ✨ and improvements 🏁

- Introduced the `OfflineManager` API that manages style packs and produces tileset descriptors for use with the tile store. The `OfflineManager` and `TileStore` APIs are used in conjunction to download offline regions and associated "style packs". These new APIs replace the deprecated `OfflineRegionManager`. Please see the new `OfflineManager` guide for more details.

### Bug fixes 🐞

- Fixed a crash in line layer rendering, where the uniform buffer size had an incorrect value.

## 10.0.0-beta.17 - April 13, 2021

### Breaking changes ⚠️

- `AnnotationManager` no longer conforms to `Observer` and no longer has a `peer` ([#246](https://github.com/mapbox/mapbox-maps-ios/pull/246))
- `AnnotationSupportableMap` is now internal ([#246](https://github.com/mapbox/mapbox-maps-ios/pull/246))

- #### MapView
    * Initializer has been changed to `public init(frame: CGRect, resourceOptions: ResourceOptions, glyphsRasterizationOptions: GlyphsRasterizationOptions = GlyphsRasterizationOptions.default, styleURI: StyleURI? = .streets)`.
    * `StyleURL` has been renamed to `StyleURI`
    * `OrnamentSupportableMapView` is not internal.

- #### Ornaments
    * `LayoutPosition` has been deprecated in favor of `OrnamentPosition`.
    * `LayoutVisibility` has been deprecated in favor of `OrnamentVisibility`.
    * `showsLogoView` has been renamed to `_showsLogoView`.
    * `showsCompass` and `showsScale` have been deprecated. Visibility properties can be used to set how the Compass and Scale Bar should be shown.

- #### Foundation
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

- #### Style
    * Initializer is now marked as internal.
    * `styleUri` property has been renamed to `uri`.
    * The `url` property from `StyleURL` has been removed.

- #### Expressions
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
