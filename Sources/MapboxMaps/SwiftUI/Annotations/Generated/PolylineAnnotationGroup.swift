// This file is generated

/// Displays a group of ``PolylineAnnotation``s.
///
/// When multiple annotation grouped, they render by a single layer. This makes annotations more performant and
/// allows to modify group-specific parameters.  For example, you canmodify ``lineCap(_:)`` or define layer slot with ``slot(_:)``.
///
/// - Note: `PolylineAnnotationGroup` is a SwiftUI analog to ``PolylineAnnotationManager``.
///
/// The group can be created with dynamic data, or static data. When first method is used, you specify array of identified data and provide a closure that creates a ``PolylineAnnotation`` from that data, similar to ``ForEvery``:
////// ```swift
/// Map {
///   PolylineAnnotationGroup(routes) { route in
///     PolylineAnnotation(lineCoordinates: route.coordinates)
///       .lineColor("blue")
///   }
///   .lineCap(.round)
///   .slot("middle")
/// }
/// ```
///
/// When the number of annotations is static, you use static that groups one or more annotations:
////// ```swift
/// Map {
///     PolylineAnnotationGroup {
///         PolylineAnnotation(lineCoordinates: route.coordinates)
///             .lineColor("blue")
///         if let alternativeRoute {
///             PolylineAnnotation(lineCoordinates: alternativeRoute.coordinates)
///                 .lineColor("green")
///         }
///     }
///     .lineCap(.round)
///     .slot("middle")
/// }
/// ```
@_documentation(visibility: public)
@_spi(Experimental)
@available(iOS 13.0, *)
public struct PolylineAnnotationGroup<Data: RandomAccessCollection, ID: Hashable> {
    let annotations: [(ID, PolylineAnnotation)]

    /// Creates a group that identifies data by given key path.
    ///
    /// - Parameters:
    ///     - data: Collection of data.
    ///     - id: Data identifier key path.
    ///     - content: A closure that creates annotation for a given data item.
    @_documentation(visibility: public)
    public init(_ data: Data, id: KeyPath<Data.Element, ID>, content: @escaping (Data.Element) -> PolylineAnnotation) {
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
    public init(_ data: Data, content: @escaping (Data.Element) -> PolylineAnnotation) where Data.Element: Identifiable, Data.Element.ID == ID {
        self.init(data, id: \.id, content: content)
    }

    /// Creates static group.
    ///
    /// - Parameters:
    ///     - content: A builder closure that creates annotations.
    @_documentation(visibility: public)
    public init(@ArrayBuilder<PolylineAnnotation> content: @escaping () -> [PolylineAnnotation?])
        where Data == [(Int, PolylineAnnotation)], ID == Int {

        let annotations = content()
            .enumerated()
            .compactMap { $0.element == nil ? nil : ($0.offset, $0.element!) }
        self.init(annotations, id: \.0, content: \.1)
    }

    private func updateProperties(manager: PolylineAnnotationManager) {
        assign(manager, \.lineCap, value: lineCap)
        assign(manager, \.lineMiterLimit, value: lineMiterLimit)
        assign(manager, \.lineRoundLimit, value: lineRoundLimit)
        assign(manager, \.lineDasharray, value: lineDasharray)
        assign(manager, \.lineDepthOcclusionFactor, value: lineDepthOcclusionFactor)
        assign(manager, \.lineEmissiveStrength, value: lineEmissiveStrength)
        assign(manager, \.lineOcclusionOpacity, value: lineOcclusionOpacity)
        assign(manager, \.lineTranslate, value: lineTranslate)
        assign(manager, \.lineTranslateAnchor, value: lineTranslateAnchor)
        assign(manager, \.lineTrimOffset, value: lineTrimOffset)
        assign(manager, \.slot, value: slot)
    }

    // MARK: - Common layer properties

    private var lineCap: LineCap?
    /// The display of line endings.
    /// Default value: "butt".
    @_documentation(visibility: public)
    public func lineCap(_ newValue: LineCap) -> Self {
        with(self, setter(\.lineCap, newValue))
    }

    private var lineMiterLimit: Double?
    /// Used to automatically convert miter joins to bevel joins for sharp angles.
    /// Default value: 2.
    @_documentation(visibility: public)
    public func lineMiterLimit(_ newValue: Double) -> Self {
        with(self, setter(\.lineMiterLimit, newValue))
    }

    private var lineRoundLimit: Double?
    /// Used to automatically convert round joins to miter joins for shallow angles.
    /// Default value: 1.05.
    @_documentation(visibility: public)
    public func lineRoundLimit(_ newValue: Double) -> Self {
        with(self, setter(\.lineRoundLimit, newValue))
    }

    private var lineDasharray: [Double]?
    /// Specifies the lengths of the alternating dashes and gaps that form the dash pattern. The lengths are later scaled by the line width. To convert a dash length to pixels, multiply the length by the current line width. Note that GeoJSON sources with `lineMetrics: true` specified won't render dashed lines to the expected scale. Also note that zoom-dependent expressions will be evaluated only at integer zoom levels.
    /// Minimum value: 0.
    @_documentation(visibility: public)
    public func lineDasharray(_ newValue: [Double]) -> Self {
        with(self, setter(\.lineDasharray, newValue))
    }

    private var lineDepthOcclusionFactor: Double?
    /// Decrease line layer opacity based on occlusion from 3D objects. Value 0 disables occlusion, value 1 means fully occluded.
    /// Default value: 1. Value range: [0, 1]
    @_documentation(visibility: public)
    public func lineDepthOcclusionFactor(_ newValue: Double) -> Self {
        with(self, setter(\.lineDepthOcclusionFactor, newValue))
    }

    private var lineEmissiveStrength: Double?
    /// Controls the intensity of light emitted on the source features.
    /// Default value: 0. Minimum value: 0.
    @_documentation(visibility: public)
    public func lineEmissiveStrength(_ newValue: Double) -> Self {
        with(self, setter(\.lineEmissiveStrength, newValue))
    }

    private var lineOcclusionOpacity: Double?
    /// Opacity multiplier (multiplies line-opacity value) of the line part that is occluded by 3D objects. Value 0 hides occluded part, value 1 means the same opacity as non-occluded part. The property is not supported when `line-opacity` has data-driven styling.
    /// Default value: 0. Value range: [0, 1]
    @_documentation(visibility: public)
    public func lineOcclusionOpacity(_ newValue: Double) -> Self {
        with(self, setter(\.lineOcclusionOpacity, newValue))
    }

    private var lineTranslate: [Double]?
    /// The geometry's offset. Values are [x, y] where negatives indicate left and up, respectively.
    /// Default value: [0,0].
    @_documentation(visibility: public)
    public func lineTranslate(_ newValue: [Double]) -> Self {
        with(self, setter(\.lineTranslate, newValue))
    }

    private var lineTranslateAnchor: LineTranslateAnchor?
    /// Controls the frame of reference for `line-translate`.
    /// Default value: "map".
    @_documentation(visibility: public)
    public func lineTranslateAnchor(_ newValue: LineTranslateAnchor) -> Self {
        with(self, setter(\.lineTranslateAnchor, newValue))
    }

    private var lineTrimOffset: [Double]?
    /// The line part between [trim-start, trim-end] will be marked as transparent to make a route vanishing effect. The line trim-off offset is based on the whole line range [0.0, 1.0].
    /// Default value: [0,0]. Minimum value: [0,0]. Maximum value: [1,1].
    @_documentation(visibility: public)
    public func lineTrimOffset(_ newValue: [Double]) -> Self {
        with(self, setter(\.lineTrimOffset, newValue))
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
extension PolylineAnnotationGroup: MapContent, PrimitiveMapContent {
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
extension PolylineAnnotationManager: MapContentAnnotationManager {
    static func make(
        layerId: String,
        layerPosition: LayerPosition?,
        clusterOptions: ClusterOptions? = nil,
        using orchestrator: AnnotationOrchestrator
    ) -> Self {
        orchestrator.makePolylineAnnotationManager(id: layerId, layerPosition: layerPosition) as! Self
    }
}

// End of generated file.
