@_spi(Experimental) @_spi(Internal) import MapboxCommon

@_spi(Experimental)
extension GeofenceState {
    /// Create `GeofenceState`
    @_spi(Experimental)
    public init(feature: Turf.Feature, timestamp: Date?) {
        self.init(_feature: MapboxCommon.Feature(feature), timestamp: timestamp)
    }

    /// The feature linked to this state
    @_spi(Experimental)
    public var feature: Turf.Feature { Turf.Feature(_feature) }
}

@_spi(Experimental)
extension GeofencingEvent {
    /// Create `GeofenceEvent`
    @_spi(Experimental)
    public init(feature: Turf.Feature, timestamp: Date) {
        self.init(_feature: MapboxCommon.Feature(feature), timestamp: timestamp)
    }

    /// The feature linked to this event
    @_spi(Experimental)
    public var feature: Turf.Feature { Turf.Feature(_feature) }
}

@_spi(Experimental)
extension GeofencingService {
    /// Adds a feature to be monitored for geofencing activities.
    /// You can add extra properties (see GeofencingPropertiesKeys) to the Feature to configure how geofencing engine behaves per each specific feature.
    /// If a feature with the same ID already exist it will be overwritten and its state reset
    @_spi(Experimental)
    public func addFeature(feature: Turf.Feature, callback: @escaping (Result<String, GeofencingError>) -> Void) {
        self.addFeature(feature: MapboxCommon.Feature(feature)) { result in
            callback(result)
        }
    }
}
