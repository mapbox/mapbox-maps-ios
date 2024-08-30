import UIKit

/// Used to configure Ornament-specific capabilities of the map
///
/// All margin values are relative to the ``MapView``'s safe area. To allow the safe area
/// (and thereby ornaments) to track the presence of navigation bars and tab bars,
/// make MapView the root view of a view controller.
public struct OrnamentOptions: Equatable, Sendable {

    // MARK: - Scale Bar

    /// The ornament options for the map's scale bar.
    public var scaleBar: ScaleBarViewOptions

    // MARK: - Compass

    /// The ornament options for the map's compass view.
    public var compass: CompassViewOptions

    // MARK: - Logo View

    /// The ornament options for the map's logo view.
    ///
    /// Per our terms of service, a Mapbox map is required to display both
    /// a Mapbox logo as well as an information icon that contains attribution
    /// information. See https://docs.mapbox.com/help/how-mapbox-works/attribution/
    /// for details.
    public var logo: LogoViewOptions

    // MARK: - Attribution Button

    /// The ornament options for the map's attribution button.
    public var attributionButton: AttributionButtonOptions

    /// Initializes an `OrnamentOptions`.
    /// - Parameters:
    ///   - scaleBar: The ornament options for the map's scale bar.
    ///   - compass: The ornament options for the map's compass view.
    ///   - logo: The ornament options for the map's logo view.
    ///   - attributionButton: The ornament options for the map's attribution button.
    public init(
        scaleBar: ScaleBarViewOptions = .init(),
        compass: CompassViewOptions = .init(),
        logo: LogoViewOptions = .init(),
        attributionButton: AttributionButtonOptions = .init()
    ) {
        self.scaleBar = scaleBar
        self.compass = compass
        self.logo = logo
        self.attributionButton = attributionButton
    }
}

/// Used to configure position, margin, and visibility for the map's scale bar view.
public struct ScaleBarViewOptions: Equatable, Sendable {

    /// The position of the scale bar view.
    ///
    /// The default value for this property is `.topLeading`.
    public var position: OrnamentPosition

    /// The margins of the scale bar view.
    ///
    /// The default value for this property is `CGPoint(x: 8.0, y: 8.0)`.
    public var margins: CGPoint

    /// The visibility of the scale bar view.
    ///
    /// The default value for this property is `.adaptive`.
    public var visibility: OrnamentVisibility

    /// Specifies the whether the scale bar uses the metric system.
    /// True if the scale bar is using metric units, false if the scale bar is using imperial units.
    ///
    /// The default value for this property is `Locale.current.usesMetricSystem`.
    public var useMetricUnits: Bool

    /// Initializes a `ScaleBarViewOptions`.
    /// - Parameters:
    ///   - position: The position of the scale bar view.
    ///   - margins: The margins of the scale bar view.
    ///   - visibility: The visibility of the scale bar view.
    ///   - useMetricUnits: Whether the scale bar uses the metric system.
    public init(
        position: OrnamentPosition = .topLeading,
        margins: CGPoint = .init(x: 8.0, y: 8.0),
        visibility: OrnamentVisibility = .adaptive,
        useMetricUnits: Bool = Locale.current.usesMetricSystem
    ) {
        self.position = position
        self.margins = margins
        self.visibility = visibility
        self.useMetricUnits = useMetricUnits
    }
}

/// Used to configure position, margin, image, and visibility for the map's compass view.
public struct CompassViewOptions: Equatable, Sendable {

    /// The position of the compass view.
    ///
    /// The default value for this property is `.topTrailing`.
    public var position: OrnamentPosition

    /// The margins of the compass view.
    ///
    /// The default value for this property is `CGPoint(x: 8.0, y: 8.0)`.
    public var margins: CGPoint

    /// The image used for displaying the compass.
    ///
    /// The default value for this property is nil, default compass image will be drawn.
    public var image: UIImage?

    /// The visibility of the compass view.
    ///
    /// The default value for this property is `.adaptive`.
    public var visibility: OrnamentVisibility

    /// Initializes a `CompassViewOptions`.
    /// - Parameters:
    ///   - position: The position of the compass view.
    ///   - margins: The margins of the compass view.
    ///   - image: The image used for displaying the compass.
    ///   - visibility: The visibility of the compass view.
    public init(
        position: OrnamentPosition = .topTrailing,
        margins: CGPoint = .init(x: 8.0, y: 8.0),
        image: UIImage? = nil,
        visibility: OrnamentVisibility = .adaptive
    ) {
        self.position = position
        self.margins = margins
        self.image = image
        self.visibility = visibility
    }
}

/// Used to configure position, margin, and visibility for the map's attribution button.
public struct AttributionButtonOptions: Equatable, Sendable {

    /// The position of the attribution button.
    ///
    /// The default value for this property is `.bottomTrailing`.
    public var position: OrnamentPosition

    /// The margins of the attribution button.
    ///
    /// The default value for this property is `CGPoint(x: 8.0, y: 8.0)`.
    public var margins: CGPoint

    /// The default value for this property is `visible`. Setting this property to `.adaptive`
    /// will lead to the same behavior as `.visible`. The attribution button will be visible
    /// as long as the map view is visible.
    /// :nodoc:
    /// Restricted API. Please contact Mapbox to discuss your use case if you intend to use this property.
    @_spi(Restricted) public var visibility: OrnamentVisibility = .visible

    /// Initializes an `AttributionButtonOptions`.
    /// - Parameters:
    ///   - position: The position of the attribution button.
    ///   - margins: The margins of the attribution button.
    public init(
        position: OrnamentPosition = .bottomTrailing,
        margins: CGPoint = .init(x: 8.0, y: 8.0)
    ) {
        self.position = position
        self.margins = margins
    }
}

/// Used to configure position, margin, and visibility for the map's logo view.
public struct LogoViewOptions: Equatable, Sendable {

    /// The position of the logo view.
    ///
    /// The default value for this property is `.bottomLeading`.
    public var position: OrnamentPosition

    /// The margins of the logo view.
    ///
    /// The default value for this property is `CGPoint(x: 8.0, y: 8.0)`.
    public var margins: CGPoint

    /// The default value for this property is `visible`. Setting this property to `.adaptive`
    /// willl lead to the same behavior as `.visible`. The logo view will be visible as long
    /// as the map view is visible.
    /// :nodoc:
    /// Restricted API. Please contact Mapbox to discuss your use case if you intend to use this property.
    @_spi(Restricted) public var visibility: OrnamentVisibility = .visible

    /// Initializes a `LogoViewOptions`.
    /// - Parameters:
    ///   - position: The position of the logo view.
    ///   - margins: The margins of the logo view.
    public init(
        position: OrnamentPosition = .bottomLeading,
        margins: CGPoint = .init(x: 8.0, y: 8.0)
    ) {
        self.position = position
        self.margins = margins
    }
}
