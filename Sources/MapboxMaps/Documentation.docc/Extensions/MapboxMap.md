# ``MapboxMap``

## Topics

### Style loading

- ``MapboxMap/loadStyle(_:transition:completion:)-6icex``
- ``MapboxMap/loadStyle(_:transition:completion:)-1ilz1``

### Map events

- ``MapboxMap/onMapLoaded``
- ``MapboxMap/onMapLoadingError``
- ``MapboxMap/onStyleLoaded``
- ``MapboxMap/onStyleDataLoaded``
- ``MapboxMap/onCameraChanged``
- ``MapboxMap/onMapIdle``
- ``MapboxMap/onSourceAdded``
- ``MapboxMap/onSourceRemoved``
- ``MapboxMap/onSourceDataLoaded``
- ``MapboxMap/onStyleImageMissing``
- ``MapboxMap/onStyleImageRemoveUnused``
- ``MapboxMap/onRenderFrameStarted``
- ``MapboxMap/onRenderFrameFinished``
- ``MapboxMap/onResourceRequest``

### Prefetching

- ``MapboxMap/prefetchZoomDelta``
- ``MapboxMap/setTileCacheBudget(size:)``
- ``MapboxMap/shouldRenderWorldCopies``
- ``MapboxMap/elevation(at:)``

### Camera Fitting

- ``MapboxMap/coordinateBounds(for:)-54bmw``
- ``MapboxMap/rect(for:)``
- ``MapboxMap/camera(for:padding:bearing:pitch:)-1il0f``
- ``MapboxMap/camera(for:padding:bearing:pitch:)-5juqy``
- ``MapboxMap/camera(for:camera:rect:)``
- ``MapboxMap/camera(for:padding:bearing:pitch:maxZoom:offset:)``
- ``MapboxMap/camera(for:camera:coordinatesPadding:maxZoom:offset:)``

### CameraOptions to CoordinateBounds

- ``MapboxMap/coordinateBounds(for:)-gs8h``
- ``MapboxMap/coordinateBoundsUnwrapped(for:)``
- ``MapboxMap/coordinateBoundsZoom(for:)``
- ``MapboxMap/coordinateBoundsZoomUnwrapped(for:)``

### Screen coordinate conversion

- ``MapboxMap/coordinate(for:)``
- ``MapboxMap/point(for:)``
- ``MapboxMap/coordinates(for:)``
- ``MapboxMap/points(for:)``

### Camera options setters/getters

- ``MapboxMap/setCamera(to:)``
- ``MapboxMap/cameraState``
- ``MapboxMap/freeCameraOptions``
- ``MapboxMap/cameraBounds``
- ``MapboxMap/setCameraBounds(with:)``
- ``MapboxMap/dragCameraOptions(from:to:)``

### Gesture and Animation Flags

- ``MapboxMap/beginAnimation()``
- ``MapboxMap/endAnimation()``
- ``MapboxMap/beginGesture()``
- ``MapboxMap/endGesture()``

### Quering map features

- ``MapboxMap/queryRenderedFeatures(with:options:completion:)-5p9gh``
- ``MapboxMap/queryRenderedFeatures(with:options:completion:)-8iu3i``
- ``MapboxMap/queryRenderedFeatures(with:options:completion:)-2qoxs``
- ``MapboxMap/querySourceFeatures(for:options:completion:)``
- ``MapboxMap/getGeoJsonClusterLeaves(forSourceId:feature:limit:offset:completion:)``
- ``MapboxMap/getGeoJsonClusterChildren(forSourceId:feature:completion:)``
- ``MapboxMap/getGeoJsonClusterExpansionZoom(forSourceId:feature:completion:)``

### Render loop

- ``MapboxMap/triggerRepaint()``

### Map data clearing

- ``MapboxMap/clearData(completion:)``

### Feature state

- ``MapboxMap/getFeatureState(sourceId:sourceLayerId:featureId:callback:)``
- ``MapboxMap/setFeatureState(sourceId:sourceLayerId:featureId:state:callback:)``
- ``MapboxMap/resetFeatureStates(sourceId:sourceLayerId:callback:)``
- ``MapboxMap/removeFeatureState(sourceId:sourceLayerId:featureId:stateKey:callback:)``

### Tile Cover

- ``MapboxMap/tileCover(for:)``
