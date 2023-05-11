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
            __cameraState: MapboxCoreMaps.CameraState(cameraState),
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
        sourceID: String,
        type: SourceDataLoadedType,
        loaded: Bool?,
        tileID: CanonicalTileID,
        dataID: String?,
        timeInterval: EventTimeInterval) {
        self.init(
            __sourceID: sourceID,
            type: type,
            loaded: loaded.map(NSNumber.init(value:)),
            tileID: tileID,
            dataID: dataID,
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
