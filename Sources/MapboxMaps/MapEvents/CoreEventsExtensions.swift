import MapboxCoreMaps

extension MapLoadingError: LocalizedError {
    public var errorDescription: String? { message }
}

extension CameraChanged {
    /// The current state of the camera.
    public var cameraState: CameraState {
        CameraState(__cameraState)
    }

    /// Creates `CameraChanged` event.
    public convenience init(cameraState: CameraState, timestamp: Date) {
        self.init(
            __cameraState: CoreCameraState(cameraState),
            timestamp: timestamp
        )
    }
}

extension SourceDataLoaded {
    /// When the `type` of an event is `SourceDataLoadedType.Tile`, the `loaded`
    /// property will be set to `true` if all the source data required for the visible
    /// viewport of the `map` are loaded.
    public var loaded: Bool? { __loaded.map(\.boolValue) }

    /// Creates `SourceDataLoaded` event.
    public convenience init(
        sourceId: String,
        type: SourceDataLoadedType,
        loaded: Bool?,
        tileId: CanonicalTileID,
        dataId: String?,
        timeInterval: EventTimeInterval) {
        self.init(
            __sourceId: sourceId,
            type: type,
            loaded: loaded.map(NSNumber.init(value:)),
            tileId: tileId,
            dataId: dataId,
            timeInterval: timeInterval)
    }
}

extension RequestInfo {
    /// The loading methods for the resource request.
    public var loadingMethod: [RequestLoadingMethodType] {
        __loadingMethod.compactMap { number in
            let result = RequestLoadingMethodType(rawValue: number.intValue)
            assert(result != nil, "Unknown request loading method type")
            return result
        }
    }
}
