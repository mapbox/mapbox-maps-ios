/// An object representing a spatially bounded geometry.
public typealias Feature = Turf.Feature

extension Feature {

    /// Initialize a `Feature` with a `MapboxCommon.Feature` object.
    /// - Parameter feature: The `MapboxCommon.Feature` to use to create the `Feature`.
    internal init(_ feature: MapboxCommon.Feature) {
        self.init(geometry: Geometry(feature.geometry))

        /**
         Features may or may not have an identifier. If they have one,
         it is either a number or string value.
         */
        switch feature.identifier {
        case let identifier as NSNumber:
            self.identifier = .number(identifier.doubleValue)
        case let identifier as String:
            self.identifier = .string(identifier)
        default:
            break
        }

        properties = JSONObject(turfRawValue: feature.properties)
    }

    /// Set properties on this Feature
    @_spi(Experimental)
    public func properties(_ newValue: JSONObject) -> Self {
        with(self, setter(\.properties, newValue))
    }
}

extension MapboxCommon.Feature {
    /// Initialize a `MapboxCommon.Feature` with a `Feature`
    internal convenience init(_ feature: Feature) {

        let identifier: NSObject

        // Features may or may not have an identifier. If they have one,
        // it is either a number or string value.
        switch feature.identifier {
        case let .number(doubleId):
            identifier = NSNumber(value: doubleId)
        case let .string(stringId):
            identifier = NSString(string: stringId)
        case .none:
            identifier = NSObject()
        #if USING_TURF_WITH_LIBRARY_EVOLUTION
        @unknown default:
            identifier = NSObject()
        #endif
        }

        // A null geometry is valid GeoJSON but not supported by MapboxCommon.
        // The closest thing would be an empty GeometryCollection.
        let nonNullGeometry = feature.geometry ?? .geometryCollection(.init(geometries: []))
        let geometry = MapboxCommon.Geometry(nonNullGeometry)
        let properties = feature.properties?.compactMapValues(\.?.rawValue) as? [String: NSObject]

        self.init(identifier: identifier,
                  geometry: geometry,
                  properties: properties ?? [:])
    }
}
