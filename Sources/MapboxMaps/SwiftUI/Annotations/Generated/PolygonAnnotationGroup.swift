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
    @_documentation(visibility: public)
@_spi(Experimental)
public struct PolygonAnnotationGroup<Data: RandomAccessCollection, ID: Hashable>: PrimitiveMapContent {
    let store: ForEvery<PolygonAnnotation, Data, ID>

    /// Creates a group that identifies data by given key path.
    ///
    /// - Parameters:
    ///     - data: Collection of data.
    ///     - id: Data identifier key path.
    ///     - content: A closure that creates annotation for a given data item.
    @_documentation(visibility: public)
    public init(_ data: Data, id: KeyPath<Data.Element, ID>, content: @escaping (Data.Element) -> PolygonAnnotation) {
        store = ForEvery(data: data, id: id, content: content)
    }

    /// Creates a group from identifiable data.
    ///
    /// - Parameters:
    ///     - data: Collection of identifiable data.
    ///     - content: A closure that creates annotation for a given data item.
    @_documentation(visibility: public)
    @available(iOS 13.0, *)
    public init(_ data: Data, content: @escaping (Data.Element) -> PolygonAnnotation) where Data.Element: Identifiable, Data.Element.ID == ID {
        self.init(data, id: \.id, content: content)
    }

    /// Creates static group.
    ///
    /// - Parameters:
    ///     - content: A builder closure that creates annotations.
    @_documentation(visibility: public)
    public init(@ArrayBuilder<PolygonAnnotation> content: @escaping () -> [PolygonAnnotation?])
        where Data == Array<(Int, PolygonAnnotation)>, ID == Int {
        let annotations = content().enumerated().compactMap {
            $0.element == nil ? nil : ($0.offset, $0.element!)
        }
        self.init(annotations, id: \.0, content: \.1)
    }

    func _visit(_ visitor: MapContentVisitor) {
        let group = AnnotationGroup(
            positionalId: visitor.positionalId,
            layerId: layerId,
            layerPosition: layerPosition,
            store: store,
            make: { $0.makePolygonAnnotationManager(id: $1, layerPosition: $2) },
            updateProperties: { self.updateProperties(manager: $0) })
        visitor.add(annotationGroup: group)
    }

    private func updateProperties(manager: PolygonAnnotationManager) {
        assign(manager, \.fillAntialias, value: fillAntialias)
        assign(manager, \.fillEmissiveStrength, value: fillEmissiveStrength)
        assign(manager, \.fillTranslate, value: fillTranslate)
        assign(manager, \.fillTranslateAnchor, value: fillTranslateAnchor)
        assign(manager, \.slot, value: slot)
    }

    // MARK: - Common layer properties

    private var fillAntialias: Bool?
    /// Whether or not the fill should be antialiased.
    @_documentation(visibility: public)
    public func fillAntialias(_ newValue: Bool) -> Self {
        with(self, setter(\.fillAntialias, newValue))
    }

    private var fillEmissiveStrength: Double?
    /// Controls the intensity of light emitted on the source features.
    @_documentation(visibility: public)
    public func fillEmissiveStrength(_ newValue: Double) -> Self {
        with(self, setter(\.fillEmissiveStrength, newValue))
    }

    private var fillTranslate: [Double]?
    /// The geometry's offset. Values are [x, y] where negatives indicate left and up, respectively.
    @_documentation(visibility: public)
    public func fillTranslate(_ newValue: [Double]) -> Self {
        with(self, setter(\.fillTranslate, newValue))
    }

    private var fillTranslateAnchor: FillTranslateAnchor?
    /// Controls the frame of reference for `fill-translate`.
    @_documentation(visibility: public)
    public func fillTranslateAnchor(_ newValue: FillTranslateAnchor) -> Self {
        with(self, setter(\.fillTranslateAnchor, newValue))
    }

    private var slot: String?
    /// 
    /// Slot for the underlying layer.
    ///
    /// Use this property to position the annotations relative to other map features if you use Mapbox Standard Style.
    /// See <doc:Migrate-to-v11##21-The-Mapbox-Standard-Style> for more info.
    @_documentation(visibility: public)
    public func slot(_ newValue: String) -> Self {
        with(self, setter(\.slot, newValue))
    }


    private var layerPosition: LayerPosition?

    /// Defines relative position of the layers drawing the annotations managed by the current group.
    ///
    /// - NOTE: Layer position isn't updatable. Only the first value passed to this function set will take effect.
    @_documentation(visibility: public)
    public func layerPosition(_ newValue: LayerPosition) -> Self {
        with(self, setter(\.layerPosition, newValue))
    }

    private var layerId: String?

    /// Specifies identifier for underlying implementation layer.
    ///
    /// Use the identifier in ``layerPosition(_:)``, or to create view annotations bound the annotations from the group.
    /// For more information, see the ``MapViewAnnotation/init(layerId:featureId:content:)``.
    @_documentation(visibility: public)
    public func layerId(_ layerId: String) -> Self {
        with(self, setter(\.layerId, layerId))
    }
}

extension PolygonAnnotation: PrimitiveMapContent, MapContentAnnotation {
    func _visit(_ visitor: MapContentVisitor) {
        PolygonAnnotationGroup { self }
            ._visit(visitor)
    }
}

extension PolygonAnnotationManager: MapContentAnnotationManager {}

// End of generated file.
