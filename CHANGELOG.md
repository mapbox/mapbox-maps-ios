# Changelog for Mapbox Maps SDK v10 for iOS

Mapbox welcomes participation and contributions from everyone.
## Breaking changes ⚠️
* The `CameraManager.moveCamera` method has been removed. ([#217](https://github.com/mapbox/mapbox-maps-ios/pull/217))
* `UIView.animate` is no longer supported. Instead, use `CameraAnimators`. ([#217](https://github.com/mapbox/mapbox-maps-ios/pull/217))
* Developers should make camera changes directly to `MapView`'s camera properties. Previously, changes could be applied to `MapView.cameraView`. ([#217](https://github.com/mapbox/mapbox-maps-ios/pull/217))
* `CameraAnimator` objects are managed by developers and should be stored in by developers to prevent the animations from falling out of scope. 

## Features ✨ and improvements 🏁
* Introduced the platform-driven Drag API for shifting the map’s camera.  ([#217](https://github.com/mapbox/mapbox-maps-ios/pull/217))
* Introduced `CameraAnimator`, a UIViewPropertyAnimator-based class for animating camera changes. ([#217](https://github.com/mapbox/mapbox-maps-ios/pull/217))
* The `AnimatorOwner` enum has been added to track owners for individual animators. ([#217](https://github.com/mapbox/mapbox-maps-ios/pull/217))


# 10.0.0-beta.15 - March 4, 2021

## Breaking changes ⚠️
* Updates MapboxCoreMaps to v10.0.0.beta.16 and MapboxCommon to v10.0.0-beta.12 ([#152](https://github.com/mapbox/mapbox-maps-ios/pull/152))

## New Events API
* The above breaking change introduces the new Map Events API which will:
    * Simplify the Map API and align it with other weakly typed interfaces (addStyleLayer, addStyleSource, etc.).
    * Minimize the effort for addition of new events.
    * Expose experimental events.
    * Suppress events that a developer hasn't subscribed to.
    * Automatically expose new events for Snapshotter (eliminating the need to modify MapObserver and MapSnapshotterObserver separately).
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

## Features ✨ and improvements 🏁
* Maps SDK now supports a static bundle via direct download ([#149](https://github.com/mapbox/mapbox-maps-ios/pull/149))

# 10.0.0-beta.14 - February 24, 2021

## Breaking changes ⚠️
* Updates Turf to v2.0.0-alpha.3 ([#133](https://github.com/mapbox/mapbox-maps-ios/pull/133))

## Features ✨ and improvements 🏁
* Added SwiftUI example. ([#78](https://github.com/mapbox/mapbox-maps-ios/pull/78))
* Allow a developer to synchronously update a layer with one API call -- no longer have to retrieve and re-add a layer. ([#85](https://github.com/mapbox/mapbox-maps-ios/pull/85))
* MapboxMaps can now be built and tested using Swift Package Manager ([#125](https://github.com/mapbox/mapbox-maps-ios/pull/125))

## Bug fixes 🐞
* Prevent pitch and zoom from exceeding limits. Also updates default maximum pitch to 85 degrees. ([#103](https://github.com/mapbox/mapbox-maps-ios/pull/103))
* Fixed an issue where quick zoom did not work at higher zoom levels. Also made the duration argument of the setCamera methods non-optional with default of 0. ([#109](https://github.com/mapbox/mapbox-maps-ios/pull/109))
* GestureManager.delegate is now weak ([#134](https://github.com/mapbox/mapbox-maps-ios/pull/134))
* Using heuristic to provide pan drift when the map is pitched ([#120](https://github.com/mapbox/mapbox-maps-ios/pull/120))

# 10.0.0-beta.13 - February 12, 2021

## Breaking changes ⚠️
* Rely on consumer provided view models directly to customize location pucks  ([#86](https://github.com/mapbox/mapbox-maps-ios/pull/86))
* Update Mapbox Common for iOS to v10.0.0-beta.9.1 and MapboxCoreMaps to v10.0.0-beta.14.1. ([#89](https://github.com/mapbox/mapbox-maps-ios/pull/89))
* Update to Turf 2.0.0-alpha.2 ([#93](https://github.com/mapbox/mapbox-maps-ios/pull/93))

## Features ✨ and improvements 🏁
* Expose `presentsWithTransaction` property to better synchronize UIKit elements with the `MapView`. ([#94](https://github.com/mapbox/mapbox-maps-ios/pull/94))
* Add MapEvents.styleFullyLoaded.  ([#90](https://github.com/mapbox/mapbox-maps-ios/pull/90))


## Bug fixes 🐞
* Refactor Annotation "properties" ([#70](https://github.com/mapbox/mapbox-maps-ios/pull/70))
* Fix Inconsistent Camera Heading ([#68](https://github.com/mapbox/mapbox-maps-ios/pull/68))
* Fix issue where updates to ornament options were not honored ([#84](https://github.com/mapbox/mapbox-maps-ios/pull/84))
* Dictionaries passed to expressions are now sorted by default ([#81](https://github.com/mapbox/mapbox-maps-ios/pull/81))
* Fixed: Pan drift did not work correctly when bearing was non-zero. ([#99](https://github.com/mapbox/mapbox-maps-ios/pull/99))
* Fix issue where toggling LocationOptions.showsUserLocation resulted in options not being updated ([#101](https://github.com/mapbox/mapbox-maps-ios/pull/101))
* Pan drift for pitched maps will be disabled. A solution for smooth drifting is being worked on. ([#100](https://github.com/mapbox/mapbox-maps-ios/pull/100))


# 10.0.0-beta.12 - January 27, 2021

## Announcement

V10 is the latest version of the Mapbox Maps SDK for iOS. v10 brings substantial performance improvements, new features like 3D terrain and a more powerful camera, modern technical foundations, and a better developer experience.

To get started with v10, please refer to our [migration guide](https://docs.mapbox.com/ios/beta/maps/guides/migrate-to-v10/).

## Known Issues

Please visit our [issues](https://github.com/mapbox/mapbox-maps-ios/issues) to see open bugs, enhancements, or features requests.
