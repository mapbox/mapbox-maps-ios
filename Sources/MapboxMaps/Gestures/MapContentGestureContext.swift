import CoreLocation

/// A structure that defines context information for an interaction.
@available(*, deprecated, renamed: "InteractionContext")
public typealias MapContentGestureContext = InteractionContext

/// A structure that defines context information for an interaction.
public struct InteractionContext: Sendable {

    /// The location of gesture in Map view bounds.
    public var point: CGPoint

    /// Geographical coordinate of the map gesture.
    public var coordinate: CLLocationCoordinate2D

    /// A flag indicating whether the screen coordinate is on the map surface or not.
    public var isOnSurface: Bool

    /// Creates the context
    public init(point: CGPoint, coordinate: CLLocationCoordinate2D, isOnSurface: Bool = true) {
        self.point = point
        self.coordinate = coordinate
        self.isOnSurface = isOnSurface
    }

    init(coreContext: CoreInteractionContext) {
        self.point = coreContext.screenCoordinate.point
        self.coordinate = coreContext.coordinateInfo.coordinate
        self.isOnSurface = coreContext.coordinateInfo.isOnSurface
    }
}

/// Handles tap on a layer.
///
/// This handler receives a rendered feature from a gesture input and context with the related information.
public typealias MapLayerGestureHandler = (QueriedFeature, InteractionContext) -> Bool
