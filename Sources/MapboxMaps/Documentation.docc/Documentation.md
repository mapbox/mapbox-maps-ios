# ``MapboxMaps``

Interactive, thoroughly customizable maps for iOS powered by vector tiles and Metal.

## Overview

The Mapbox Maps SDK for iOS is a public library for displaying interactive, thoroughly customizable maps in native iOS. It takes map styles that conform to the [Mapbox Style Specification](https://docs.mapbox.com/mapbox-gl-js/style-spec/), applies them to vector tiles that conform to the [Mapbox Vector Tile Specification](https://github.com/mapbox/vector-tile-spec), and renders them using Metal.


## Topics

### Articles

- <doc:Migrate-to-v11>
- <doc:SwiftUI-User-Guide>

### SwiftUI
- ``Map-swift.struct``
- ``MapStyle``
- ``Viewport``
- ``withViewportAnimation(_:body:completion:)``
- ``ViewAnnotation``
- ``PointAnnotationGroup``
- ``CircleAnnotationGroup``
- ``PolygonAnnotationGroup``
- ``PolylineAnnotationGroup``
- ``Puck2D``
- ``Puck3D``
- ``MapReader``

### MapView

- ``MapView``
- ``MapInitOptions``
- ``MapInitOptionsProvider``
- ``InterfaceOrientationProvider``
- ``AttributionURLOpener``

### Snapshotter

- ``Snapshotter``
- ``MapSnapshotOptions``
- ``SnapshotOverlay``
- ``SnapshotOverlayHandler``

### MapboxMap

- ``MapboxMap``
- ``CameraState``
- ``CameraOptions``
- ``CameraBounds``
- ``CameraBoundsOptions``
- ``AnyCancelable``
- ``MapError``

### Style

- ``StyleURI``
- ``LayerPosition``
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
- ``GeoJSONSourceData``
- ``ImageSource``
- ``RasterDemSource``
- ``RasterSource``
- ``VectorSource``
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
- ``ViewAnnotationOptions``
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
- ``Location``
- ``LocationConsumer``
- ``LocationProvider``
- ``AppleLocationProviderDelegate``
- ``AppleLocationProvider``

### Viewport

- ``ViewportManager``
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

### GeoJSON

- ``Feature``
- ``Geometry``

### Utilities

- ``CompassDirectionFormatter``
<!--- ``Projection``-->

