// This file is generated

/// Displays a group of ``PointAnnotation``s.
///
/// When multiple annotation grouped, they render by a single layer. This makes annotations more performant and
/// allows to modify group-specific parameters.  For example, you can create clustering with ``clusterOptions(_:)`` or define layer slot with ``slot(_:)``.
///
/// - Note: `PointAnnotationGroup` is a SwiftUI analog to ``PointAnnotationManager``.
///
/// The group can be created with dynamic data, or static data. When first method is used, you specify array of identified data and provide a closure that creates a ``PointAnnotation`` from that data, similar to ``ForEvery``:
///
/// ```swift
/// Map {
///   PointAnnotationGroup(favorites) { favorite in
///     PointAnnotation(coordinate: favorite.coordinate)
///       .image(named: "star")
///   }
///   .clusterOptions(ClusterOptions(...))
///   .slot("top")
/// }
/// ```
///
/// When the number of annotations is static, you use static that groups one or more annotations:
///
/// ```swift
/// Map {
///     PointAnnotationGroup {
///         PointAnnotation(coordinate: startCoordinate)
///             .image(named: "start-icon")
///         PointAnnotation(coordinate: endCoordinate)
///             .image(named: "end-icon")
///     }
///     .slot("top")
/// }
/// ```
@_documentation(visibility: public)
@_spi(Experimental)
@available(iOS 13.0, *)
public struct PointAnnotationGroup<Data: RandomAccessCollection, ID: Hashable> {
    let annotations: [(ID, PointAnnotation)]

    /// Creates a group that identifies data by given key path.
    ///
    /// - Parameters:
    ///     - data: Collection of data.
    ///     - id: Data identifier key path.
    ///     - content: A closure that creates annotation for a given data item.
    @_documentation(visibility: public)
    public init(_ data: Data, id: KeyPath<Data.Element, ID>, content: @escaping (Data.Element) -> PointAnnotation) {
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
    public init(_ data: Data, content: @escaping (Data.Element) -> PointAnnotation) where Data.Element: Identifiable, Data.Element.ID == ID {
        self.init(data, id: \.id, content: content)
    }

    /// Creates static group.
    ///
    /// - Parameters:
    ///     - content: A builder closure that creates annotations.
    @_documentation(visibility: public)
    public init(@ArrayBuilder<PointAnnotation> content: @escaping () -> [PointAnnotation?])
        where Data == [(Int, PointAnnotation)], ID == Int {

        let annotations = content()
            .enumerated()
            .compactMap { $0.element == nil ? nil : ($0.offset, $0.element!) }
        self.init(annotations, id: \.0, content: \.1)
    }

    private func updateProperties(manager: PointAnnotationManager) {
        assign(manager, \.iconAllowOverlap, value: iconAllowOverlap)
        assign(manager, \.iconIgnorePlacement, value: iconIgnorePlacement)
        assign(manager, \.iconKeepUpright, value: iconKeepUpright)
        assign(manager, \.iconOptional, value: iconOptional)
        assign(manager, \.iconPadding, value: iconPadding)
        assign(manager, \.iconPitchAlignment, value: iconPitchAlignment)
        assign(manager, \.iconRotationAlignment, value: iconRotationAlignment)
        assign(manager, \.symbolAvoidEdges, value: symbolAvoidEdges)
        assign(manager, \.symbolPlacement, value: symbolPlacement)
        assign(manager, \.symbolSpacing, value: symbolSpacing)
        assign(manager, \.symbolZElevate, value: symbolZElevate)
        assign(manager, \.symbolZOrder, value: symbolZOrder)
        assign(manager, \.textAllowOverlap, value: textAllowOverlap)
        assign(manager, \.textFont, value: textFont)
        assign(manager, \.textIgnorePlacement, value: textIgnorePlacement)
        assign(manager, \.textKeepUpright, value: textKeepUpright)
        assign(manager, \.textMaxAngle, value: textMaxAngle)
        assign(manager, \.textOptional, value: textOptional)
        assign(manager, \.textPadding, value: textPadding)
        assign(manager, \.textPitchAlignment, value: textPitchAlignment)
        assign(manager, \.textRotationAlignment, value: textRotationAlignment)
        assign(manager, \.textVariableAnchor, value: textVariableAnchor)
        assign(manager, \.textWritingMode, value: textWritingMode)
        assign(manager, \.iconColorSaturation, value: iconColorSaturation)
        assign(manager, \.iconOcclusionOpacity, value: iconOcclusionOpacity)
        assign(manager, \.iconTranslate, value: iconTranslate)
        assign(manager, \.iconTranslateAnchor, value: iconTranslateAnchor)
        assign(manager, \.textOcclusionOpacity, value: textOcclusionOpacity)
        assign(manager, \.textTranslate, value: textTranslate)
        assign(manager, \.textTranslateAnchor, value: textTranslateAnchor)
        assign(manager, \.slot, value: slot)

        manager.onClusterTap = onClusterTap
        manager.onClusterLongPress = onClusterLongPress
    }

    // MARK: - Common layer properties

    private var iconAllowOverlap: Bool?
    /// If true, the icon will be visible even if it collides with other previously drawn symbols.
    /// Default value: false.
    @_documentation(visibility: public)
    public func iconAllowOverlap(_ newValue: Bool) -> Self {
        with(self, setter(\.iconAllowOverlap, newValue))
    }

    private var iconIgnorePlacement: Bool?
    /// If true, other symbols can be visible even if they collide with the icon.
    /// Default value: false.
    @_documentation(visibility: public)
    public func iconIgnorePlacement(_ newValue: Bool) -> Self {
        with(self, setter(\.iconIgnorePlacement, newValue))
    }

    private var iconKeepUpright: Bool?
    /// If true, the icon may be flipped to prevent it from being rendered upside-down.
    /// Default value: false.
    @_documentation(visibility: public)
    public func iconKeepUpright(_ newValue: Bool) -> Self {
        with(self, setter(\.iconKeepUpright, newValue))
    }

    private var iconOptional: Bool?
    /// If true, text will display without their corresponding icons when the icon collides with other symbols and the text does not.
    /// Default value: false.
    @_documentation(visibility: public)
    public func iconOptional(_ newValue: Bool) -> Self {
        with(self, setter(\.iconOptional, newValue))
    }

    private var iconPadding: Double?
    /// Size of the additional area around the icon bounding box used for detecting symbol collisions.
    /// Default value: 2. Minimum value: 0.
    @_documentation(visibility: public)
    public func iconPadding(_ newValue: Double) -> Self {
        with(self, setter(\.iconPadding, newValue))
    }

    private var iconPitchAlignment: IconPitchAlignment?
    /// Orientation of icon when map is pitched.
    /// Default value: "auto".
    @_documentation(visibility: public)
    public func iconPitchAlignment(_ newValue: IconPitchAlignment) -> Self {
        with(self, setter(\.iconPitchAlignment, newValue))
    }

    private var iconRotationAlignment: IconRotationAlignment?
    /// In combination with `symbol-placement`, determines the rotation behavior of icons.
    /// Default value: "auto".
    @_documentation(visibility: public)
    public func iconRotationAlignment(_ newValue: IconRotationAlignment) -> Self {
        with(self, setter(\.iconRotationAlignment, newValue))
    }

    private var symbolAvoidEdges: Bool?
    /// If true, the symbols will not cross tile edges to avoid mutual collisions. Recommended in layers that don't have enough padding in the vector tile to prevent collisions, or if it is a point symbol layer placed after a line symbol layer. When using a client that supports global collision detection, like Mapbox GL JS version 0.42.0 or greater, enabling this property is not needed to prevent clipped labels at tile boundaries.
    /// Default value: false.
    @_documentation(visibility: public)
    public func symbolAvoidEdges(_ newValue: Bool) -> Self {
        with(self, setter(\.symbolAvoidEdges, newValue))
    }

    private var symbolPlacement: SymbolPlacement?
    /// Label placement relative to its geometry.
    /// Default value: "point".
    @_documentation(visibility: public)
    public func symbolPlacement(_ newValue: SymbolPlacement) -> Self {
        with(self, setter(\.symbolPlacement, newValue))
    }

    private var symbolSpacing: Double?
    /// Distance between two symbol anchors.
    /// Default value: 250. Minimum value: 1.
    @_documentation(visibility: public)
    public func symbolSpacing(_ newValue: Double) -> Self {
        with(self, setter(\.symbolSpacing, newValue))
    }

    private var symbolZElevate: Bool?
    /// Position symbol on buildings (both fill extrusions and models) rooftops. In order to have minimal impact on performance, this is supported only when `fill-extrusion-height` is not zoom-dependent and remains unchanged. For fading in buildings when zooming in, fill-extrusion-vertical-scale should be used and symbols would raise with building rooftops. Symbols are sorted by elevation, except in cases when `viewport-y` sorting or `symbol-sort-key` are applied.
    /// Default value: false.
    @_documentation(visibility: public)
    public func symbolZElevate(_ newValue: Bool) -> Self {
        with(self, setter(\.symbolZElevate, newValue))
    }

    private var symbolZOrder: SymbolZOrder?
    /// Determines whether overlapping symbols in the same layer are rendered in the order that they appear in the data source or by their y-position relative to the viewport. To control the order and prioritization of symbols otherwise, use `symbol-sort-key`.
    /// Default value: "auto".
    @_documentation(visibility: public)
    public func symbolZOrder(_ newValue: SymbolZOrder) -> Self {
        with(self, setter(\.symbolZOrder, newValue))
    }

    private var textAllowOverlap: Bool?
    /// If true, the text will be visible even if it collides with other previously drawn symbols.
    /// Default value: false.
    @_documentation(visibility: public)
    public func textAllowOverlap(_ newValue: Bool) -> Self {
        with(self, setter(\.textAllowOverlap, newValue))
    }

    private var textFont: [String]?
    /// Font stack to use for displaying text.
    @_documentation(visibility: public)
    public func textFont(_ newValue: [String]) -> Self {
        with(self, setter(\.textFont, newValue))
    }

    private var textIgnorePlacement: Bool?
    /// If true, other symbols can be visible even if they collide with the text.
    /// Default value: false.
    @_documentation(visibility: public)
    public func textIgnorePlacement(_ newValue: Bool) -> Self {
        with(self, setter(\.textIgnorePlacement, newValue))
    }

    private var textKeepUpright: Bool?
    /// If true, the text may be flipped vertically to prevent it from being rendered upside-down.
    /// Default value: true.
    @_documentation(visibility: public)
    public func textKeepUpright(_ newValue: Bool) -> Self {
        with(self, setter(\.textKeepUpright, newValue))
    }

    private var textMaxAngle: Double?
    /// Maximum angle change between adjacent characters.
    /// Default value: 45.
    @_documentation(visibility: public)
    public func textMaxAngle(_ newValue: Double) -> Self {
        with(self, setter(\.textMaxAngle, newValue))
    }

    private var textOptional: Bool?
    /// If true, icons will display without their corresponding text when the text collides with other symbols and the icon does not.
    /// Default value: false.
    @_documentation(visibility: public)
    public func textOptional(_ newValue: Bool) -> Self {
        with(self, setter(\.textOptional, newValue))
    }

    private var textPadding: Double?
    /// Size of the additional area around the text bounding box used for detecting symbol collisions.
    /// Default value: 2. Minimum value: 0.
    @_documentation(visibility: public)
    public func textPadding(_ newValue: Double) -> Self {
        with(self, setter(\.textPadding, newValue))
    }

    private var textPitchAlignment: TextPitchAlignment?
    /// Orientation of text when map is pitched.
    /// Default value: "auto".
    @_documentation(visibility: public)
    public func textPitchAlignment(_ newValue: TextPitchAlignment) -> Self {
        with(self, setter(\.textPitchAlignment, newValue))
    }

    private var textRotationAlignment: TextRotationAlignment?
    /// In combination with `symbol-placement`, determines the rotation behavior of the individual glyphs forming the text.
    /// Default value: "auto".
    @_documentation(visibility: public)
    public func textRotationAlignment(_ newValue: TextRotationAlignment) -> Self {
        with(self, setter(\.textRotationAlignment, newValue))
    }

    private var textVariableAnchor: [TextAnchor]?
    /// To increase the chance of placing high-priority labels on the map, you can provide an array of `text-anchor` locations: the renderer will attempt to place the label at each location, in order, before moving onto the next label. Use `text-justify: auto` to choose justification based on anchor position. To apply an offset, use the `text-radial-offset` or the two-dimensional `text-offset`.
    @_documentation(visibility: public)
    public func textVariableAnchor(_ newValue: [TextAnchor]) -> Self {
        with(self, setter(\.textVariableAnchor, newValue))
    }

    private var textWritingMode: [TextWritingMode]?
    /// The property allows control over a symbol's orientation. Note that the property values act as a hint, so that a symbol whose language doesn’t support the provided orientation will be laid out in its natural orientation. Example: English point symbol will be rendered horizontally even if array value contains single 'vertical' enum value. For symbol with point placement, the order of elements in an array define priority order for the placement of an orientation variant. For symbol with line placement, the default text writing mode is either ['horizontal', 'vertical'] or ['vertical', 'horizontal'], the order doesn't affect the placement.
    @_documentation(visibility: public)
    public func textWritingMode(_ newValue: [TextWritingMode]) -> Self {
        with(self, setter(\.textWritingMode, newValue))
    }

    private var iconColorSaturation: Double?
    /// Increase or reduce the saturation of the symbol icon.
    /// Default value: 0. Value range: [-1, 1]
    @_documentation(visibility: public)
    public func iconColorSaturation(_ newValue: Double) -> Self {
        with(self, setter(\.iconColorSaturation, newValue))
    }

    private var iconOcclusionOpacity: Double?
    /// The opacity at which the icon will be drawn in case of being depth occluded. Not supported on globe zoom levels.
    /// Default value: 1. Value range: [0, 1]
    @_documentation(visibility: public)
    public func iconOcclusionOpacity(_ newValue: Double) -> Self {
        with(self, setter(\.iconOcclusionOpacity, newValue))
    }

    private var iconTranslate: [Double]?
    /// Distance that the icon's anchor is moved from its original placement. Positive values indicate right and down, while negative values indicate left and up.
    /// Default value: [0,0].
    @_documentation(visibility: public)
    public func iconTranslate(_ newValue: [Double]) -> Self {
        with(self, setter(\.iconTranslate, newValue))
    }

    private var iconTranslateAnchor: IconTranslateAnchor?
    /// Controls the frame of reference for `icon-translate`.
    /// Default value: "map".
    @_documentation(visibility: public)
    public func iconTranslateAnchor(_ newValue: IconTranslateAnchor) -> Self {
        with(self, setter(\.iconTranslateAnchor, newValue))
    }

    private var textOcclusionOpacity: Double?
    /// The opacity at which the text will be drawn in case of being depth occluded. Not supported on globe zoom levels.
    /// Default value: 1. Value range: [0, 1]
    @_documentation(visibility: public)
    public func textOcclusionOpacity(_ newValue: Double) -> Self {
        with(self, setter(\.textOcclusionOpacity, newValue))
    }

    private var textTranslate: [Double]?
    /// Distance that the text's anchor is moved from its original placement. Positive values indicate right and down, while negative values indicate left and up.
    /// Default value: [0,0].
    @_documentation(visibility: public)
    public func textTranslate(_ newValue: [Double]) -> Self {
        with(self, setter(\.textTranslate, newValue))
    }

    private var textTranslateAnchor: TextTranslateAnchor?
    /// Controls the frame of reference for `text-translate`.
    /// Default value: "map".
    @_documentation(visibility: public)
    public func textTranslateAnchor(_ newValue: TextTranslateAnchor) -> Self {
        with(self, setter(\.textTranslateAnchor, newValue))
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

    private var clusterOptions: ClusterOptions?

    /// Defines point annotation clustering options.
    ///
    /// - NOTE: Clustering options aren't updatable. Only the first value passed to this function set will take effect.
    @_documentation(visibility: public)
    public func clusterOptions(_ newValue: ClusterOptions) -> Self {
        with(self, setter(\.clusterOptions, newValue))
    }

    private var onClusterTap: ((AnnotationClusterGestureContext) -> Void)?

    /// Adds a handler for tap gesture on annotations cluster.
    ///
    /// The handler should return `true` if the gesture is handled, or `false` to propagate it to the annotations or layers below.
    ///
    /// - Parameters:
    ///   - action: A handler for tap gesture on cluster.
    @_documentation(visibility: public)
    public func onClusterTapGesture(perform action: @escaping (AnnotationClusterGestureContext) -> Void) -> Self {
        with(self, setter(\.onClusterTap, action))
    }

    private var onClusterLongPress: ((AnnotationClusterGestureContext) -> Void)?

    /// Adds a handler for long press gesture on annotation cluster formed by annotations from the group.
    ///
    /// The handler should return `true` if the gesture is handled, or `false` to propagate it to the annotations or layers below.
    ///
    /// - Parameters:
    ///   - action: A handler for long press gesture on cluster.
    @_documentation(visibility: public)
    public func onClusterLongPressGesture(perform action: @escaping (AnnotationClusterGestureContext) -> Void) -> Self {
        with(self, setter(\.onClusterLongPress, action))
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
extension PointAnnotationGroup: MapContent, PrimitiveMapContent {
    func visit(_ node: MapContentNode) {
        let group = MountedAnnotationGroup(
            layerId: layerId ?? node.id.stringId,
            clusterOptions: clusterOptions,
            annotations: annotations,
            updateProperties: updateProperties
        )
        node.mount(group)
    }
}

@available(iOS 13.0, *)
extension PointAnnotationManager: MapContentAnnotationManager {
    static func make(
        layerId: String,
        layerPosition: LayerPosition?,
        clusterOptions: ClusterOptions? = nil,
        using orchestrator: AnnotationOrchestrator
    ) -> Self {
        orchestrator.makePointAnnotationManager(id: layerId, layerPosition: layerPosition, clusterOptions: clusterOptions) as! Self
    }
}

// End of generated file.
