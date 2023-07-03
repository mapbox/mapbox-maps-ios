# ``MapboxMaps``

Interactive, thoroughly customizable maps for iOS powered by vector tiles and Metal.

## Overview

The Mapbox Maps SDK for iOS is a public library for displaying interactive, thoroughly customizable maps in native iOS. It takes map styles that conform to the [Mapbox Style Specification](https://docs.mapbox.com/mapbox-gl-js/style-spec/), applies them to vector tiles that conform to the [Mapbox Vector Tile Specification](https://github.com/mapbox/vector-tile-spec), and renders them using Metal.


## Topics

### MapView

- ``MapView``
- ``MapInitOptions``
- ``MapInitOptionsProvider``
- ``ResourceOptions-swift.struct``
- ``ResourceOptionsManager``
- ``MapOptions``
- ``GlyphsRasterizationOptions``
- ``InterfaceOrientationProvider``
- ``AttributionURLOpener``

### Snapshotter

- ``Snapshotter``
- ``MapSnapshotOptions-swift.struct``
- ``SnapshotOverlay``
- ``SnapshotOverlayHandler``

### MapboxMap

- ``MapboxMap``
- ``CameraState-swift.struct``
- ``CameraOptions-swift.struct``
- ``CameraBounds-swift.struct``
- ``CameraBoundsOptions-swift.struct``
- ``CoordinateBounds``
- ``RenderedQueryOptions``
- ``QueriedFeature``
- ``FeatureExtensionValue``
- ``MapError``
- ``MapLoadingError``

### Style

- ``Style``
- ``StyleURI``
- ``LayerPosition-swift.enum``
- ``TransitionOptions``
- ``Light``
- ``Terrain``
- ``StyleDecodable``
- ``StyleEncodable``
- ``StyleError``
- ``TypeConversionError``

### Sources

- ``Source``
- ``SourceType``
- ``SourceInfo``
- ``GeoJSONSource``
- ``GeoJSONSourceData-swift.enum``
- ``ImageSource``
- ``RasterDemSource``
- ``RasterSource``
- ``VectorSource``
- ``CustomGeometrySourceOptions``
- ``CanonicalTileID``
- ``PromoteId``
- ``Scheme``
- ``Encoding``

### Layers

- ``Layer``
- ``LayerType``
- ``LayerInfo``
- ``BackgroundLayer``
- ``CircleLayer``
- ``FillExtrusionLayer``
- ``FillLayer``
- ``HeatmapLayer``
- ``HillshadeLayer``
- ``LineLayer``
- ``LocationIndicatorLayer``
- ``RasterLayer``
- ``SkyLayer``
- ``SymbolLayer``
- ``ModelLayer``

### Layer Property Values

- ``Value``
- ``Anchor``
- ``CirclePitchAlignment``
- ``CirclePitchScale``
- ``CircleTranslateAnchor``
- ``FillExtrusionTranslateAnchor``
- ``FillTranslateAnchor``
- ``HillshadeIlluminationAnchor``
- ``IconAnchor``
- ``IconPitchAlignment``
- ``IconRotationAlignment``
- ``IconTextFit``
- ``IconTranslateAnchor``
- ``LineCap``
- ``LineJoin``
- ``LineTranslateAnchor``
- ``RasterResampling``
- ``ResolvedImage``
- ``ResolvedImageData``
- ``SkyType``
- ``ModelType``
- ``StyleColor``
- ``StyleTransition``
- ``SymbolPlacement``
- ``SymbolZOrder``
- ``TextAnchor``
- ``TextJustify``
- ``TextPitchAlignment``
- ``TextRotationAlignment``
- ``TextTransform``
- ``TextTranslateAnchor``
- ``TextWritingMode``
- ``Visibility``

### Expressions

- ``Expression``
- ``Exp``
- ``FormatOptions``
- ``NumberFormatOptions``
- ``CollatorOptions``

### Annotations

- ``AnnotationOrchestrator``
- ``AnnotationInteractionDelegate``
- ``Annotation``
- ``AnnotationManager``
- ``CircleAnnotation``
- ``CircleAnnotationManager``
- ``PointAnnotation``
- ``PointAnnotationManager``
- ``PolygonAnnotation``
- ``PolygonAnnotationManager``
- ``PolylineAnnotation``
- ``PolylineAnnotationManager``
- ``ClusterOptions``

### View Annotations

- ``ViewAnnotationManager``
- ``ViewAnnotationUpdateObserver``
- ``ViewAnnotationOptions-swift.struct``
- ``ViewAnnotationManagerError``

### Camera Animations

- ``CameraAnimationsManager``
- ``CameraAnimator``
- ``BasicCameraAnimator``
- ``CameraTransition``
- ``FlyToCameraAnimator``
- ``AnimationCompletion``
- ``AnimationOwner``

### Ornaments

- ``OrnamentsManager``
- ``OrnamentOptions``
- ``OrnamentPosition``
- ``OrnamentVisibility``
- ``AttributionButtonOptions``
- ``CompassViewOptions``
- ``LogoViewOptions``
- ``ScaleBarViewOptions``

### Gestures

- ``GestureManager``
- ``GestureOptions``
- ``PanMode``
- ``GestureManagerDelegate``
- ``GestureType``

### Location

- ``LocationManager``
- ``LocationOptions``
- ``PuckType``
- ``Puck2DConfiguration``
- ``Puck3DConfiguration``
- ``Model``
- ``PuckBearing``
- ``Location-swift.struct``
- ``LocationConsumer``
- ``LocationPermissionsDelegate``
- ``LocationProvider``
- ``LocationProviderDelegate``
- ``AppleLocationProvider``

### Viewport

- ``Viewport``
- ``ViewportOptions``
- ``ViewportStatus``
- ``ViewportStatusObserver``
- ``ViewportStatusChangeReason``
- ``ViewportState``
- ``FollowPuckViewportState``
- ``FollowPuckViewportStateOptions``
- ``FollowPuckViewportStateBearing``
- ``OverviewViewportState``
- ``OverviewViewportStateOptions``
- ``ViewportTransition``
- ``DefaultViewportTransition``
- ``DefaultViewportTransitionOptions``
- ``ImmediateViewportTransition``

### Offline

- ``OfflineManager``
- ``OfflineRegion``
- ``OfflineRegionManager``
- ``OfflineRegionGeometryDefinition``
<!--- ``OfflineSwitch-swift.class``-->
- ``StylePackError-swift.enum``
- ``StylePackLoadOptions``
- ``TileRegionError-swift.enum``
- ``TileRegionLoadOptions``
- ``TilesetDescriptorOptions``
- ``TileStore``
- ``TileStoreObserver``

### Custom Networking Stack

- ``DownloadError``
- ``DownloadStatus``
- ``HttpRequestError``
- ``HttpResponse``

### GeoJSON

- ``Feature-swift.struct``
- ``Geometry-swift.enum``

### Utilities

- ``CompassDirectionFormatter``
<!--- ``Projection``-->

