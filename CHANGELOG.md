## Breaking changes ⚠️
* Rely on consumer provided view models directly to customize location pucks  ([#86](https://github.com/mapbox/mapbox-maps-ios/pull/86))
* Update Mapbox Common for iOS to v10.0.0-beta.9.1 and MapboxCoreMaps to v10.0.0-beta.14.1. ([#89](https://github.com/mapbox/mapbox-maps-ios/pull/89))


## Features ✨ and improvements 🏁
* Expose `presentsWithTransaction` property to better synchronize UIKit elements with the `MapView`. ([#94](https://github.com/mapbox/mapbox-maps-ios/pull/94))


## Bug fixes 🐞
* Refactor Annotation "properties" ([#70](https://github.com/mapbox/mapbox-maps-ios/pull/70))
* Fix Inconsistent Camera Heading ([#68](https://github.com/mapbox/mapbox-maps-ios/pull/68))
* Fix issue where updates to ornament options were not honored ([#84](https://github.com/mapbox/mapbox-maps-ios/pull/84))
* Dictionaries passed to expressions are now sorted by default ([#81](https://github.com/mapbox/mapbox-maps-ios/pull/81))
* Fixed: Pan drift did not work correctly when bearing was non-zero. ([#99](https://github.com/mapbox/mapbox-maps-ios/pull/99))
* Fix issue where toggling LocationOptions.showsUserLocation resulted in options not being updated ([#101](https://github.com/mapbox/mapbox-maps-ios/pull/101))
* Pan drift for pitched maps will be disabled. A solution for smooth drifting is being worked on. ([#100](https://github.com/mapbox/mapbox-maps-ios/pull/100))


## MAYBE INTERNAL (workflow changes, issues filed since last release)
* [tests] Adding generated integration tests ([#75](https://github.com/mapbox/mapbox-maps-ios/pull/75))


## Skipped (no entry needed)
* Fix example tests & search functionality ([#55](https://github.com/mapbox/mapbox-maps-ios/pull/55))
* Remove unused MapboxMapsCommons files ([#61](https://github.com/mapbox/mapbox-maps-ios/pull/61))
* [Tests] Re-enables and updates the HTTP stack replacement tests ([#64](https://github.com/mapbox/mapbox-maps-ios/pull/64))
* Include generated files in code coverage number ([#71](https://github.com/mapbox/mapbox-maps-ios/pull/71))
* [style] Convert `ColorRepresentable` to a struct ([#76](https://github.com/mapbox/mapbox-maps-ios/pull/76))
* Check that displayLink is not nil in updateDisplayLinkPreferredFramesPerSecond ([#77](https://github.com/mapbox/mapbox-maps-ios/pull/77))
* [build] Add version script and update Mapbox project targets (only) ([#82](https://github.com/mapbox/mapbox-maps-ios/pull/82))
* Update CI/CD Automation For Releases ([#83](https://github.com/mapbox/mapbox-maps-ios/pull/83))
* Fix MapViewIntegrationTests ([#87](https://github.com/mapbox/mapbox-maps-ios/pull/87))
* Use a proxy target for BaseMapView.displayLink ([#92](https://github.com/mapbox/mapbox-maps-ios/pull/92))
* Make internal representation of colorRepresentable an expression  ([#98](https://github.com/mapbox/mapbox-maps-ios/pull/98))


## UNCATEGORIZED
* Release 10.0.0-beta.12 ([#44](https://github.com/mapbox/mapbox-maps-ios/pull/44))
* Update Pull Request & Issue Templates ([#46](https://github.com/mapbox/mapbox-maps-ios/pull/46))
* Update documentation links in podspec ([#47](https://github.com/mapbox/mapbox-maps-ios/pull/47))
* [CLA] Updates CLA agreement text; adds badge ([#49](https://github.com/mapbox/mapbox-maps-ios/pull/49))
* [ci] Temporarily disable the make-docs step ([#50](https://github.com/mapbox/mapbox-maps-ios/pull/50))
* [ci] Fix SDK Registry automation script ([#52](https://github.com/mapbox/mapbox-maps-ios/pull/52))
* Fix pull request template ([#53](https://github.com/mapbox/mapbox-maps-ios/pull/53))
* Enable code coverage generation ([#54](https://github.com/mapbox/mapbox-maps-ios/pull/54))
* [Example] Add an animate a line example ([#60](https://github.com/mapbox/mapbox-maps-ios/pull/60))
* Run examples tests on devices ([#58](https://github.com/mapbox/mapbox-maps-ios/pull/58))
* Update to Turf 2.0.0-alpha.2 ([#93](https://github.com/mapbox/mapbox-maps-ios/pull/93))
*  Add MapEvents.styleFullyLoaded.  ([#90](https://github.com/mapbox/mapbox-maps-ios/pull/90))
* Release v10.0.0 beta.13 ([#104](https://github.com/mapbox/mapbox-maps-ios/pull/104))


# Changelog for Mapbox Maps SDK v10 for iOS

Mapbox welcomes participation and contributions from everyone.

# 10.0.0-beta.12 - January 27, 2021

## Announcement

V10 is the latest version of the Mapbox Maps SDK for iOS. v10 brings substantial performance improvements, new features like 3D terrain and a more powerful camera, modern technical foundations, and a better developer experience.

To get started with v10, please refer to our [migration guide](https://docs.mapbox.com/ios/beta/maps/guides/migrate-to-v10/).

## Known Issues

### Annotations

* Annotation selection may have a false positive if the selection of an annotation occurs on the edge of the display.
* Point, line, and polygon colors cannot be customized.
* Annotation interaction cannot be disabled.
* Point annotations may not be rendered when `PointAnnotation.properties` is non-nil.

### Camera

* The camera can jump while pinching or panning.
* `UIViewPropertyAnimator` and keyframe animations do not work; please use `UIView.animate` to selectively animate camera properties.

### Ornaments

* Unable to toggle `scaleBar` and `compass` visibility.
* Ornaments do not reposition after a navigation bar is displayed.

### Style

* An `NSException` can occur when accessing symbol style layers that contain a value for `textField` using `Style.getLayer()`.

### 3D Terrain

* 3D Terrain is in an experimental state.
