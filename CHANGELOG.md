# Changelog for Mapbox Maps SDK v10 for iOS

Mapbox welcomes participation and contributions from everyone.

### Breaking changes ⚠️

- `AnnotationManager` no longer conforms to `Observer` and no longer has a `peer` ([#246](https://github.com/mapbox/mapbox-maps-ios/pull/246))
- `AnnotationSupportableMap` is now internal ([#246](https://github.com/mapbox/mapbox-maps-ios/pull/246))

- #### MapView
    * Initializer has been changed to `public init(frame: CGRect, resourceOptions: ResourceOptions, glyphsRasterizationOptions: GlyphsRasterizationOptions = GlyphsRasterizationOptions.default, styleURI: StyleURI? = .streets)`.
    * `OrnamentSupportableMapView` is not internal.

- #### Ornaments
    * `LayoutPosition` has been deprecated in favor of `OrnamentPosition`.
    * `LayoutVisibility` has been depracted in favor of `OrnamentVisibility`.
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
    * `EventType` is internal.
    * `MBXEdgeInsets` extension is internal.
    * `ScreenCoordinate` extension is internal.
    * `MapboxLogoView` has been renamed to `LogoView`.
    * `MapboxLogoSize` has been renamed to `LogoSize`.

- #### Style
    * Initializer is now marked as internal.
    * `styleUri` has been renamed to `uri`.
    * The `url` property from `StyleURL` has been removed.

- #### Expressions
    * `ExpressionBuilder` has been renamed to `FunctionBuilder`.
    * `init(from: jsonObject)` and `public func jsonObject()` have been removed.
    * `Element.op` has been renamed to `Element.operator`.
    * `Argument.array` has been renamed to `Argument.numberArray`.
    * `ValidExpressionArgument` has been renamed to `ExpressionArgumentConvertible`


### Bug fixes 🐞

- Fixes an issue that could cause issues with annotations including causing them to not be selectable ([#246](https://github.com/mapbox/mapbox-maps-ios/pull/246))

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
