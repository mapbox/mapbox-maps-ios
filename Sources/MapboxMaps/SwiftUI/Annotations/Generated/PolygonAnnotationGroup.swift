// This file is generated

/// Displays a group of ``PolygonAnnotation``s.
///
/// When multiple annotation grouped, they render by a single layer. This makes annotations more performant and
/// allows to modify group-specific parameters.  For example, you can define layer slot with ``slot(_:)``.
///
/// - Note: `PolygonAnnotationGroup` is a SwiftUI analog to ``PolygonAnnotationManager``.
///
/// The group can be created with dynamic data, or static data. When first method is used, you specify array of identified data and provide a closure that creates a ``PolygonAnnotation`` from that data, similar to ``ForEvery``:
///
/// ```swift
/// Map {
///    PolygonAnnotationGroup(parkingZones) { zone in
///        PolygonAnnotation(polygon: zone.polygon)
///            .fillColor("blue")
///    }
/// }
/// .slot(.bottom)
/// ```
///
/// When the number of annotations is static, you use static that groups one or more annotations:
///
/// ```swift
/// Map {
///     PolygonAnnotationGroup {
///         PolygonAnnotation(polygon: parkingZone.polygon)
///             .fillColor("blue")
///     }
///     .layerId("parking")
///     .slot(.bottom)
/// }
/// ```
import UIKit

public struct PolygonAnnotationGroup<Data: RandomAccessCollection, ID: Hashable> {
    let annotations: [(ID, PolygonAnnotation)]

    /// Creates a group that identifies data by given key path.
    ///
    /// - Parameters:
    ///     - data: Collection of data.
    ///     - id: Data identifier key path.
    ///     - content: A closure that creates annotation for a given data item.
    public init(_ data: Data, id: KeyPath<Data.Element, ID>, content: @escaping (Data.Element) -> PolygonAnnotation) {
        annotations = data.map { element in
            (element[keyPath: id], content(element))
        }
    }

    /// Creates a group from identifiable data.
    ///
    /// - Parameters:
    ///     - data: Collection of identifiable data.
    ///     - content: A closure that creates annotation for a given data item.
    public init(_ data: Data, content: @escaping (Data.Element) -> PolygonAnnotation) where Data.Element: Identifiable, Data.Element.ID == ID {
        self.init(data, id: \.id, content: content)
    }

    /// Creates static group.
    ///
    /// - Parameters:
    ///     - content: A builder closure that creates annotations.
    public init(@ArrayBuilder<PolygonAnnotation> content: @escaping () -> [PolygonAnnotation?])
        where Data == [(Int, PolygonAnnotation)], ID == Int {

        let annotations = content()
            .enumerated()
            .compactMap { $0.element == nil ? nil : ($0.offset, $0.element!) }
        self.init(annotations, id: \.0, content: \.1)
    }

    private func updateProperties(manager: PolygonAnnotationManager) {
        assign(manager, \.fillConstructBridgeGuardRail, value: fillConstructBridgeGuardRail)
        assign(manager, \.fillElevationReference, value: fillElevationReference)
        assign(manager, \.fillSortKey, value: fillSortKey)
        assign(manager, \.fillAntialias, value: fillAntialias)
        assign(manager, \.fillBridgeGuardRailColor, value: fillBridgeGuardRailColor)
        assign(manager, \.fillBridgeGuardRailColorUseTheme, value: fillBridgeGuardRailColorUseTheme)
        assign(manager, \.fillBridgeGuardRailColorTransition, value: fillBridgeGuardRailColorTransition)
        assign(manager, \.fillColor, value: fillColor)
        assign(manager, \.fillColorUseTheme, value: fillColorUseTheme)
        assign(manager, \.fillColorTransition, value: fillColorTransition)
        assign(manager, \.fillEmissiveStrength, value: fillEmissiveStrength)
        assign(manager, \.fillEmissiveStrengthTransition, value: fillEmissiveStrengthTransition)
        assign(manager, \.fillOpacity, value: fillOpacity)
        assign(manager, \.fillOpacityTransition, value: fillOpacityTransition)
        assign(manager, \.fillOutlineColor, value: fillOutlineColor)
        assign(manager, \.fillOutlineColorUseTheme, value: fillOutlineColorUseTheme)
        assign(manager, \.fillOutlineColorTransition, value: fillOutlineColorTransition)
        assign(manager, \.fillPattern, value: fillPattern)
        assign(manager, \.fillTranslate, value: fillTranslate)
        assign(manager, \.fillTranslateTransition, value: fillTranslateTransition)
        assign(manager, \.fillTranslateAnchor, value: fillTranslateAnchor)
        assign(manager, \.fillTunnelStructureColor, value: fillTunnelStructureColor)
        assign(manager, \.fillTunnelStructureColorUseTheme, value: fillTunnelStructureColorUseTheme)
        assign(manager, \.fillTunnelStructureColorTransition, value: fillTunnelStructureColorTransition)
        assign(manager, \.fillZOffset, value: fillZOffset)
        assign(manager, \.fillZOffsetTransition, value: fillZOffsetTransition)
        assign(manager, \.slot, value: slot)
        manager.tapRadius = tapRadius
        manager.longPressRadius = longPressRadius
    }

    // MARK: - Common layer properties

    private var fillConstructBridgeGuardRail: Bool?
    /// Determines whether bridge guard rails are added for elevated roads.
    /// Default value: "true".
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func fillConstructBridgeGuardRail(_ newValue: Bool) -> Self {
        with(self, setter(\.fillConstructBridgeGuardRail, newValue))
    }

    private var fillElevationReference: FillElevationReference?
    /// Selects the base of fill-elevation. Some modes might require precomputed elevation data in the tileset.
    /// Default value: "none".
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func fillElevationReference(_ newValue: FillElevationReference) -> Self {
        with(self, setter(\.fillElevationReference, newValue))
    }

    private var fillSortKey: Double?
    /// Sorts features in ascending order based on this value. Features with a higher sort key will appear above features with a lower sort key.
    public func fillSortKey(_ newValue: Double) -> Self {
        with(self, setter(\.fillSortKey, newValue))
    }

    private var fillAntialias: Bool?
    /// Whether or not the fill should be antialiased.
    /// Default value: true.
    public func fillAntialias(_ newValue: Bool) -> Self {
        with(self, setter(\.fillAntialias, newValue))
    }

    /// The color of bridge guard rail.
    /// Default value: "rgba(241, 236, 225, 255)".
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func fillBridgeGuardRailColor(_ color: UIColor) -> Self {
        with(self, setter(\.fillBridgeGuardRailColor, StyleColor(color)))
    }

    private var fillBridgeGuardRailColorUseTheme: ColorUseTheme?
    /// This property defines whether the `fillBridgeGuardRailColor` uses colorTheme from the style or not.
    /// By default it will use color defined by the root theme in the style.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func fillBridgeGuardRailColorUseTheme(_ useTheme: ColorUseTheme) -> Self {
        with(self, setter(\.fillBridgeGuardRailColorUseTheme, useTheme))
    }

    private var fillBridgeGuardRailColorTransition: StyleTransition?
    /// Transition property for `fillBridgeGuardRailColor`
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func fillBridgeGuardRailColorTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.fillBridgeGuardRailColorTransition, transition))
    }

    private var fillBridgeGuardRailColor: StyleColor?
    /// The color of bridge guard rail.
    /// Default value: "rgba(241, 236, 225, 255)".
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func fillBridgeGuardRailColor(_ newValue: StyleColor) -> Self {
        with(self, setter(\.fillBridgeGuardRailColor, newValue))
    }

    /// The color of the filled part of this layer. This color can be specified as `rgba` with an alpha component and the color's opacity will not affect the opacity of the 1px stroke, if it is used.
    /// Default value: "#000000".
    public func fillColor(_ color: UIColor) -> Self {
        with(self, setter(\.fillColor, StyleColor(color)))
    }

    private var fillColorUseTheme: ColorUseTheme?
    /// This property defines whether the `fillColor` uses colorTheme from the style or not.
    /// By default it will use color defined by the root theme in the style.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func fillColorUseTheme(_ useTheme: ColorUseTheme) -> Self {
        with(self, setter(\.fillColorUseTheme, useTheme))
    }

    private var fillColorTransition: StyleTransition?
    /// Transition property for `fillColor`
    public func fillColorTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.fillColorTransition, transition))
    }

    private var fillColor: StyleColor?
    /// The color of the filled part of this layer. This color can be specified as `rgba` with an alpha component and the color's opacity will not affect the opacity of the 1px stroke, if it is used.
    /// Default value: "#000000".
    public func fillColor(_ newValue: StyleColor) -> Self {
        with(self, setter(\.fillColor, newValue))
    }

    private var fillEmissiveStrengthTransition: StyleTransition?
    /// Transition property for `fillEmissiveStrength`
    public func fillEmissiveStrengthTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.fillEmissiveStrengthTransition, transition))
    }

    private var fillEmissiveStrength: Double?
    /// Controls the intensity of light emitted on the source features.
    /// Default value: 0. Minimum value: 0. The unit of fillEmissiveStrength is in intensity.
    public func fillEmissiveStrength(_ newValue: Double) -> Self {
        with(self, setter(\.fillEmissiveStrength, newValue))
    }

    private var fillOpacityTransition: StyleTransition?
    /// Transition property for `fillOpacity`
    public func fillOpacityTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.fillOpacityTransition, transition))
    }

    private var fillOpacity: Double?
    /// The opacity of the entire fill layer. In contrast to the `fill-color`, this value will also affect the 1px stroke around the fill, if the stroke is used.
    /// Default value: 1. Value range: [0, 1]
    public func fillOpacity(_ newValue: Double) -> Self {
        with(self, setter(\.fillOpacity, newValue))
    }

    /// The outline color of the fill. Matches the value of `fill-color` if unspecified.
    public func fillOutlineColor(_ color: UIColor) -> Self {
        with(self, setter(\.fillOutlineColor, StyleColor(color)))
    }

    private var fillOutlineColorUseTheme: ColorUseTheme?
    /// This property defines whether the `fillOutlineColor` uses colorTheme from the style or not.
    /// By default it will use color defined by the root theme in the style.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func fillOutlineColorUseTheme(_ useTheme: ColorUseTheme) -> Self {
        with(self, setter(\.fillOutlineColorUseTheme, useTheme))
    }

    private var fillOutlineColorTransition: StyleTransition?
    /// Transition property for `fillOutlineColor`
    public func fillOutlineColorTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.fillOutlineColorTransition, transition))
    }

    private var fillOutlineColor: StyleColor?
    /// The outline color of the fill. Matches the value of `fill-color` if unspecified.
    public func fillOutlineColor(_ newValue: StyleColor) -> Self {
        with(self, setter(\.fillOutlineColor, newValue))
    }

    private var fillPattern: String?
    /// Name of image in sprite to use for drawing image fills. For seamless patterns, image width and height must be a factor of two (2, 4, 8, ..., 512). Note that zoom-dependent expressions will be evaluated only at integer zoom levels.
    public func fillPattern(_ newValue: String) -> Self {
        with(self, setter(\.fillPattern, newValue))
    }

    private var fillTranslateTransition: StyleTransition?
    /// Transition property for `fillTranslate`
    public func fillTranslateTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.fillTranslateTransition, transition))
    }

    private var fillTranslate: [Double]?
    /// The geometry's offset. Values are [x, y] where negatives indicate left and up, respectively.
    /// Default value: [0,0]. The unit of fillTranslate is in pixels.
    public func fillTranslate(x: Double, y: Double) -> Self {
        with(self, setter(\.fillTranslate, [x, y]))
    }

    private var fillTranslateAnchor: FillTranslateAnchor?
    /// Controls the frame of reference for `fill-translate`.
    /// Default value: "map".
    public func fillTranslateAnchor(_ newValue: FillTranslateAnchor) -> Self {
        with(self, setter(\.fillTranslateAnchor, newValue))
    }

    /// The color of tunnel structures (tunnel entrance and tunnel walls).
    /// Default value: "rgba(241, 236, 225, 255)".
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func fillTunnelStructureColor(_ color: UIColor) -> Self {
        with(self, setter(\.fillTunnelStructureColor, StyleColor(color)))
    }

    private var fillTunnelStructureColorUseTheme: ColorUseTheme?
    /// This property defines whether the `fillTunnelStructureColor` uses colorTheme from the style or not.
    /// By default it will use color defined by the root theme in the style.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func fillTunnelStructureColorUseTheme(_ useTheme: ColorUseTheme) -> Self {
        with(self, setter(\.fillTunnelStructureColorUseTheme, useTheme))
    }

    private var fillTunnelStructureColorTransition: StyleTransition?
    /// Transition property for `fillTunnelStructureColor`
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func fillTunnelStructureColorTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.fillTunnelStructureColorTransition, transition))
    }

    private var fillTunnelStructureColor: StyleColor?
    /// The color of tunnel structures (tunnel entrance and tunnel walls).
    /// Default value: "rgba(241, 236, 225, 255)".
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func fillTunnelStructureColor(_ newValue: StyleColor) -> Self {
        with(self, setter(\.fillTunnelStructureColor, newValue))
    }

    private var fillZOffsetTransition: StyleTransition?
    /// Transition property for `fillZOffset`
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func fillZOffsetTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.fillZOffsetTransition, transition))
    }

    private var fillZOffset: Double?
    /// Specifies an uniform elevation in meters. Note: If the value is zero, the layer will be rendered on the ground. Non-zero values will elevate the layer from the sea level, which can cause it to be rendered below the terrain.
    /// Default value: 0. Minimum value: 0.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func fillZOffset(_ newValue: Double) -> Self {
        with(self, setter(\.fillZOffset, newValue))
    }

    private var slot: String?
    /// Slot for the underlying layer.
    ///
    /// Use this property to position the annotations relative to other map features if you use Mapbox Standard Style.
    /// See <doc:Migrate-to-v11##21-The-Mapbox-Standard-Style> for more info.
    @available(*, deprecated, message: "Use Slot type instead of string")
    public func slot(_ newValue: String) -> Self {
        with(self, setter(\.slot, newValue))
    }

    /// Slot for the underlying layer.
    ///
    /// Use this property to position the annotations relative to other map features if you use Mapbox Standard Style.
    /// See <doc:Migrate-to-v11##21-The-Mapbox-Standard-Style> for more info.
    public func slot(_ newValue: Slot?) -> Self {
        with(self, setter(\.slot, newValue?.rawValue))
    }

    private var layerId: String?

    /// Specifies identifier for underlying implementation layer.
    ///
    /// Use the identifier to create view annotations bound the annotations from the group.
    /// For more information, see the ``MapViewAnnotation/init(layerId:featureId:content:)``.
    public func layerId(_ layerId: String) -> Self {
        with(self, setter(\.layerId, layerId))
    }

    var tapRadius: CGFloat?
    var longPressRadius: CGFloat?

    /// A custom tappable area radius. Default value is 0.
    public func tapRadius(_ radius: CGFloat? = nil) -> Self {
        with(self, setter(\.tapRadius, radius))
    }

    /// A custom tappable area radius. Default value is 0.
    public func longPressRadius(_ radius: CGFloat? = nil) -> Self {
        with(self, setter(\.longPressRadius, radius))
    }
}

extension PolygonAnnotationGroup: MapContent, PrimitiveMapContent {
    func visit(_ node: MapContentNode) {
        let group = MountedAnnotationGroup(
            layerId: layerId ?? node.id.stringId,
            clusterOptions: nil,
            annotations: annotations,
            updateProperties: updateProperties
        )
        node.mount(group)
    }
}

// End of generated file.
