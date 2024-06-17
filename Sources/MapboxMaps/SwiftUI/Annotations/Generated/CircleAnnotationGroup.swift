// This file is generated

/// Displays a group of ``CircleAnnotation``s.
///
/// When multiple annotation grouped, they render by a single layer. This makes annotations more performant and
/// allows to modify group-specific parameters.  For example, you can define layer slot with ``slot(_:)``.
///
/// - Note: `CircleAnnotationGroup` is a SwiftUI analog to ``CircleAnnotationManager``.
///
/// The group can be created with dynamic data, or static data. When first method is used, you specify array of identified data and provide a closure that creates a ``CircleAnnotation`` from that data, similar to ``ForEvery``:
///
/// ```swift
/// Map {
///     CircleAnnotationGroup(pivots) { pivot in
///         CircleAnnotation(centerCoordinate: pivot.coordinate)
///             .circleColor("white")
///             .circleRadius(10)
///     }
/// }
/// .slot("top")
/// ```
///
/// When the number of annotations is static, you use static that groups one or more annotations:
///
/// ```swift
/// Map {
///     CircleAnnotationGroup {
///         CircleAnnotation(centerCoordinate: route.startCoordinate)
///             .circleColor("white")
///             .circleRadius(10)
///         CircleAnnotation(centerCoordinate: route.endCoordinate)
///             .circleColor("gray")
///             .circleRadius(10)
///     }
///     .slot("top")
/// }
/// ```
@_documentation(visibility: public)
@_spi(Experimental)
@available(iOS 13.0, *)
public struct CircleAnnotationGroup<Data: RandomAccessCollection, ID: Hashable> {
    let annotations: [(ID, CircleAnnotation)]

    /// Creates a group that identifies data by given key path.
    ///
    /// - Parameters:
    ///     - data: Collection of data.
    ///     - id: Data identifier key path.
    ///     - content: A closure that creates annotation for a given data item.
    @_documentation(visibility: public)
    public init(_ data: Data, id: KeyPath<Data.Element, ID>, content: @escaping (Data.Element) -> CircleAnnotation) {
        annotations = data.map { element in
            (element[keyPath: id], content(element))
        }
    }

    /// Creates a group from identifiable data.
    ///
    /// - Parameters:
    ///     - data: Collection of identifiable data.
    ///     - content: A closure that creates annotation for a given data item.
    @_documentation(visibility: public)
    @available(iOS 13.0, *)
    public init(_ data: Data, content: @escaping (Data.Element) -> CircleAnnotation) where Data.Element: Identifiable, Data.Element.ID == ID {
        self.init(data, id: \.id, content: content)
    }

    /// Creates static group.
    ///
    /// - Parameters:
    ///     - content: A builder closure that creates annotations.
    @_documentation(visibility: public)
    public init(@ArrayBuilder<CircleAnnotation> content: @escaping () -> [CircleAnnotation?])
        where Data == [(Int, CircleAnnotation)], ID == Int {

        let annotations = content()
            .enumerated()
            .compactMap { $0.element == nil ? nil : ($0.offset, $0.element!) }
        self.init(annotations, id: \.0, content: \.1)
    }

    private func updateProperties(manager: CircleAnnotationManager) {
        assign(manager, \.circleEmissiveStrength, value: circleEmissiveStrength)
        assign(manager, \.circlePitchAlignment, value: circlePitchAlignment)
        assign(manager, \.circlePitchScale, value: circlePitchScale)
        assign(manager, \.circleTranslate, value: circleTranslate)
        assign(manager, \.circleTranslateAnchor, value: circleTranslateAnchor)
        assign(manager, \.slot, value: slot)
    }

    // MARK: - Common layer properties

    private var circleEmissiveStrength: Double?
    /// Controls the intensity of light emitted on the source features.
    /// Default value: 0. Minimum value: 0.
    @_documentation(visibility: public)
    public func circleEmissiveStrength(_ newValue: Double) -> Self {
        with(self, setter(\.circleEmissiveStrength, newValue))
    }

    private var circlePitchAlignment: CirclePitchAlignment?
    /// Orientation of circle when map is pitched.
    /// Default value: "viewport".
    @_documentation(visibility: public)
    public func circlePitchAlignment(_ newValue: CirclePitchAlignment) -> Self {
        with(self, setter(\.circlePitchAlignment, newValue))
    }

    private var circlePitchScale: CirclePitchScale?
    /// Controls the scaling behavior of the circle when the map is pitched.
    /// Default value: "map".
    @_documentation(visibility: public)
    public func circlePitchScale(_ newValue: CirclePitchScale) -> Self {
        with(self, setter(\.circlePitchScale, newValue))
    }

    private var circleTranslate: [Double]?
    /// The geometry's offset. Values are [x, y] where negatives indicate left and up, respectively.
    /// Default value: [0,0].
    @_documentation(visibility: public)
    public func circleTranslate(_ newValue: [Double]) -> Self {
        with(self, setter(\.circleTranslate, newValue))
    }

    private var circleTranslateAnchor: CircleTranslateAnchor?
    /// Controls the frame of reference for `circle-translate`.
    /// Default value: "map".
    @_documentation(visibility: public)
    public func circleTranslateAnchor(_ newValue: CircleTranslateAnchor) -> Self {
        with(self, setter(\.circleTranslateAnchor, newValue))
    }

    private var slot: String?
    /// Slot for the underlying layer.
    ///
    /// Use this property to position the annotations relative to other map features if you use Mapbox Standard Style.
    /// See <doc:Migrate-to-v11##21-The-Mapbox-Standard-Style> for more info.
    @_documentation(visibility: public)
    public func slot(_ newValue: String) -> Self {
        with(self, setter(\.slot, newValue))
    }

    private var layerId: String?

    /// Specifies identifier for underlying implementation layer.
    ///
    /// Use the identifier to create view annotations bound the annotations from the group.
    /// For more information, see the ``MapViewAnnotation/init(layerId:featureId:content:)``.
    @_documentation(visibility: public)
    public func layerId(_ layerId: String) -> Self {
        with(self, setter(\.layerId, layerId))
    }
}

@available(iOS 13.0, *)
extension CircleAnnotationGroup: MapContent, PrimitiveMapContent {
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

@available(iOS 13.0, *)
extension CircleAnnotationManager: MapContentAnnotationManager {
    static func make(
        layerId: String,
        layerPosition: LayerPosition?,
        clusterOptions: ClusterOptions? = nil,
        using orchestrator: AnnotationOrchestrator
    ) -> Self {
        orchestrator.makeCircleAnnotationManager(id: layerId, layerPosition: layerPosition) as! Self
    }
}

// End of generated file.
