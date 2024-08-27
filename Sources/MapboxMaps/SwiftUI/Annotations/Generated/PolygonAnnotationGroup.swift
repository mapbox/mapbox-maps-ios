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
/// .slot("bottom")
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
///     .slot("bottom")
/// }
/// ```
import UIKit

@available(iOS 13.0, *)
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
    @available(iOS 13.0, *)
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
        assign(manager, \.fillSortKey, value: fillSortKey)
        assign(manager, \.fillAntialias, value: fillAntialias)
        assign(manager, \.fillColor, value: fillColor)
        assign(manager, \.fillEmissiveStrength, value: fillEmissiveStrength)
        assign(manager, \.fillOpacity, value: fillOpacity)
        assign(manager, \.fillOutlineColor, value: fillOutlineColor)
        assign(manager, \.fillPattern, value: fillPattern)
        assign(manager, \.fillTranslate, value: fillTranslate)
        assign(manager, \.fillTranslateAnchor, value: fillTranslateAnchor)
        assign(manager, \.slot, value: slot)
    }

    // MARK: - Common layer properties

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

    private var fillColor: StyleColor?
    /// The color of the filled part of this layer. This color can be specified as `rgba` with an alpha component and the color's opacity will not affect the opacity of the 1px stroke, if it is used.
    /// Default value: "#000000".
    public func fillColor(_ color: UIColor) -> Self {
        with(self, setter(\.fillColor, StyleColor(color)))
    }

    private var fillEmissiveStrength: Double?
    /// Controls the intensity of light emitted on the source features.
    /// Default value: 0. Minimum value: 0.
    public func fillEmissiveStrength(_ newValue: Double) -> Self {
        with(self, setter(\.fillEmissiveStrength, newValue))
    }

    private var fillOpacity: Double?
    /// The opacity of the entire fill layer. In contrast to the `fill-color`, this value will also affect the 1px stroke around the fill, if the stroke is used.
    /// Default value: 1. Value range: [0, 1]
    public func fillOpacity(_ newValue: Double) -> Self {
        with(self, setter(\.fillOpacity, newValue))
    }

    private var fillOutlineColor: StyleColor?
    /// The outline color of the fill. Matches the value of `fill-color` if unspecified.
    public func fillOutlineColor(_ color: UIColor) -> Self {
        with(self, setter(\.fillOutlineColor, StyleColor(color)))
    }

    private var fillPattern: String?
    /// Name of image in sprite to use for drawing image fills. For seamless patterns, image width and height must be a factor of two (2, 4, 8, ..., 512). Note that zoom-dependent expressions will be evaluated only at integer zoom levels.
    public func fillPattern(_ newValue: String) -> Self {
        with(self, setter(\.fillPattern, newValue))
    }

    private var fillTranslate: [Double]?
    /// The geometry's offset. Values are [x, y] where negatives indicate left and up, respectively.
    /// Default value: [0,0].
    public func fillTranslate(_ newValue: [Double]) -> Self {
        with(self, setter(\.fillTranslate, newValue))
    }

    private var fillTranslateAnchor: FillTranslateAnchor?
    /// Controls the frame of reference for `fill-translate`.
    /// Default value: "map".
    public func fillTranslateAnchor(_ newValue: FillTranslateAnchor) -> Self {
        with(self, setter(\.fillTranslateAnchor, newValue))
    }

    private var slot: String?
    /// Slot for the underlying layer.
    ///
    /// Use this property to position the annotations relative to other map features if you use Mapbox Standard Style.
    /// See <doc:Migrate-to-v11##21-The-Mapbox-Standard-Style> for more info.
    public func slot(_ newValue: String) -> Self {
        with(self, setter(\.slot, newValue))
    }

    private var layerId: String?

    /// Specifies identifier for underlying implementation layer.
    ///
    /// Use the identifier to create view annotations bound the annotations from the group.
    /// For more information, see the ``MapViewAnnotation/init(layerId:featureId:content:)``.
    public func layerId(_ layerId: String) -> Self {
        with(self, setter(\.layerId, layerId))
    }
}

@available(iOS 13.0, *)
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
