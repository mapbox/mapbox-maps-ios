import CoreLocation

/// A structure that defines additional information about map content gesture
public struct MapContentGestureContext {
    /// The location of gesture in Map view bounds.
    public var point: CGPoint

    /// Geographical coordinate of the map gesture.
    public var coordinate: CLLocationCoordinate2D
}

/// Handles tap on a layer.
///
/// This handler receives a rendered feature from a gesture input and context with the related information.
public typealias MapLayerGestureHandler = (QueriedFeature, MapContentGestureContext) -> Bool
