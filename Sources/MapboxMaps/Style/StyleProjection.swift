/// Describes the projection used to render the map.
public struct StyleProjection: Hashable, Codable, StyleEncodable, Equatable, Sendable {

    /// The name of the projection.
    public var name: StyleProjectionName

    /// The reference longitude and latitude of the projection. `center` takes the form of [lng, lat]. This property is only configurable for conic projections (Albers and Lambert Conformal Conic). All other projections are centered on [0, 0].
    @_documentation(visibility: public)
    @_spi(Experimental) public var center: CLLocationCoordinate2D? {
        get {
            guard let centerCodable, centerCodable.count == 2 else { return nil }
            return CLLocationCoordinate2D(latitude: centerCodable[1], longitude: centerCodable[0])
        }
        set { centerCodable = newValue.map { [$0.longitude, $0.latitude] } }
    }

    /// The standard parallels of the projection, denoting the desired latitude range with minimal distortion. `parallels` takes the form of [lat0, lat1]. This property is only configurable for conic projections (Albers and Lambert Conformal Conic).
    @_documentation(visibility: public)
    @_spi(Experimental) public var parallels: ClosedRange<CLLocationDegrees>? {
        get {
            guard let parallelsCodable, parallelsCodable.count == 2 else { return nil }
            return min(parallelsCodable[0], parallelsCodable[1])...max(parallelsCodable[0], parallelsCodable[1])
        }
        set { parallelsCodable = newValue.map { [$0.lowerBound, $0.upperBound] } }
    }

    var centerCodable: [Double]?
    var parallelsCodable: [Double]?

    /// Initializes a projection
    public init(name: StyleProjectionName) {
        self.name = name
    }

    /// An Albers equal-area projection centered on the continental United States. You can configure the projection for a different region by setting `center` and `parallels` properties. You may want to set max bounds to constrain the map to the relevant region.
    ///
    /// - Parameters:
    ///   - center: The reference longitude and latitude of the projection.
    ///   - parallels: The standard parallels of the projection.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public static func albers(center: CLLocationCoordinate2D? = nil, parallels: ClosedRange<CLLocationDegrees>? = nil) -> StyleProjection {
        var projection = StyleProjection(name: .albers)
        projection.center = center
        projection.parallels = parallels
        return projection
    }

    internal enum CodingKeys: String, CodingKey {
        case name
        case centerCodable = "center"
        case parallelsCodable = "parallels"
    }
}

@_spi(Experimental)
extension StyleProjection: MapStyleContent, PrimitiveMapContent {
    func visit(_ node: MapContentNode) {
        node.mount(MountedUniqueProperty(keyPath: \.projection, value: self))
    }
}
