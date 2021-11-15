# Changelog for Mapbox Maps SDK v10 for iOS

Mapbox welcomes participation and contributions from everyone.

## main

* Fixed an issue where camera animations triggered with `startAnimation(afterDelay:)` could appear jerky after a pan gesture. ([#789](https://github.com/mapbox/mapbox-maps-ios/pull/789))
* Send location update when puck is nil and other location-related improvements. ([#765](https://github.com/mapbox/mapbox-maps-ios/pull/765))
* Update to MapboxCoreMaps 10.2.0-beta.1 and MapboxCommon 21.0.0-rc.1. ([#]())

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
