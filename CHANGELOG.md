# Changelog for Mapbox Maps SDK v10 for iOS

Mapbox welcomes participation and contributions from everyone.

# 10.0.0-beta.5 - January 13, 2021

## Breaking changes ⚠️
* Use `ValidExpressionArgument` protocol to support stops dictionaries ([#639](https://github.com/mapbox/mapbox-maps-ios/pull/639))
* The `Snapshotter` class now uses an event-based callback mechanism to notify about changes, similar to `MapView`. Conformance to `MapSnapshotterObserver` is no longer required. ([#622](https://github.com/mapbox/mapbox-maps-ios/pull/622))

## Features ✨ and improvements 🏁
* Integrate location indicator layer with puck manager ([#624](https://github.com/mapbox/mapbox-maps-ios/pull/624))
* MapboxCoreMaps and MapboxCommon no longer need to be explicitly imported. ([#623](https://github.com/mapbox/mapbox-maps-ios/pull/623))
* Restrict gestures when `MapCameraOptions.restrictedCoordinateBounds` is set ([#648](https://github.com/mapbox/mapbox-maps-ios/pull/648))
* Update dependencies to GL-Native v10.0.0-beta.11 ([#673](https://github.com/mapbox/mapbox-maps-ios/pull/673))
* Deprecate user tracking modes ([#683](https://github.com/mapbox/mapbox-maps-ios/pull/683))
* Ensure that location indicator layer is reloaded whenever the style is changed ([#684](https://github.com/mapbox/mapbox-maps-ios/pull/684))
* Adds convenience initializer and default for GlyphsRasterizationOptions ([#694](https://github.com/mapbox/mapbox-maps-ios/pull/694))
* Enable granular customization of the location indicator layer ([#690](https://github.com/mapbox/mapbox-maps-ios/pull/690))

## Bug fixes 🐞
* Fixed some `MapView` retain cycles by making references weak. ([#635](https://github.com/mapbox/mapbox-maps-ios/pull/635))
* Allow pan to drift across the antimeridian ([#671](https://github.com/mapbox/mapbox-maps-ios/pull/671))
* Fixed bug with camera(fitting geometry:edgePadding:bearing:pitch:) returning a default value. ([#696](https://github.com/mapbox/mapbox-maps-ios/pull/696))
* Honor updates to location options ([#689](https://github.com/mapbox/mapbox-maps-ios/pull/689))


# 10.0.0-beta.4 - December 16, 2020

## Breaking changes ⚠️

* Migrated `MapViewController` logic to `MapView`. ([#594](https://github.com/mapbox/mapbox-maps-ios/pull/594))
* Updated `MapView` and `BaseMapView` to take a single `ResourceOptions` parameter instead of separate access token and base URL parameters. ([#603](https://github.com/mapbox/mapbox-maps-ios/pull/603))
* Changed `MapView` style parameter to be of type `StyleURL`, instead of `URL`. ([#612](https://github.com/mapbox/mapbox-maps-ios/pull/612))
* Updated access control to classes/methods across the project. ([#618](https://github.com/mapbox/mapbox-maps-ios/pull/618))
* Set base deployment target to iOS 11. ([#572](https://github.com/mapbox/mapbox-maps-ios/pull/572))
* Migrated to new event API. ([#591](https://github.com/mapbox/mapbox-maps-ios/pull/591))
* Deleted unused MapDelegate and MapCameraDelegate protocols. ([#626](https://github.com/mapbox/mapbox-maps-ios/pull/626))

## Features ✨ and improvements 🏁

* Introduced Location indicator manager. ([#599](https://github.com/mapbox/mapbox-maps-ios/pull/599))
* Added support for Model Sources. ([#621](https://github.com/mapbox/mapbox-maps-ios/pull/621))
* Added storyboard support. ([#607](https://github.com/mapbox/mapbox-maps-ios/pull/607))
* Made the GestureManager the GestureHandlerDelegate. ([#478](https://github.com/mapbox/mapbox-maps-ios/pull/478))
* Introduced Swift base map view. ([#569](https://github.com/mapbox/mapbox-maps-ios/pull/569))
* Generated Sky and Model layers. ([#581](https://github.com/mapbox/mapbox-maps-ios/pull/581))
* Provided CGContext used by snapshotter. ([#588](https://github.com/mapbox/mapbox-maps-ios/pull/588))
* Added telemetry opt-out property. ([#595](https://github.com/mapbox/mapbox-maps-ios/pull/595))
* Added example for using external vector tile sources which use the {z}/{x}/{y} URL scheme. ([#597](https://github.com/mapbox/mapbox-maps-ios/pull/597))

## Bug fixes 🐞

* Required double tap to fail for quick zoom. ([#552](https://github.com/mapbox/mapbox-maps-ios/pull/552))
* Accept `UInt64` as cacheSize argument of `ResourceOptions` convenience init. ([#614](https://github.com/mapbox/mapbox-maps-ios/pull/614))