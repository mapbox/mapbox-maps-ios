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
