// This file is generated

extension PointAnnotation: PrimitiveMapContent {
    func _visit(_ visitor: MapContentVisitor) {
        let group = PointAnnotationGroup([0], id: \.self) { _ in
            self
        }
        visitor.add(annotationGroup: group.eraseToAny(visitor.id))
    }
}

/// Displays a group of point annotations.
///
/// Always prefer to use annotation group over individual annotation if more than one annotation of the same type is displayed.
/// The annotation group is usually more performant, since only one underlying layer is used to draw multiple annotations.
///
/// Annotation group allows to configure group-related options, such as clustering (only for point annotations) and others.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
@_spi(Experimental)
public struct PointAnnotationGroup<Data: RandomAccessCollection, ID: Hashable>: PrimitiveMapContent {
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    var data: Data
    var idGenerator: (Data.Element) -> ID
    var content: (Data.Element) -> PointAnnotation

#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public init(_ data: Data, id: KeyPath<Data.Element, ID>, content: @escaping (Data.Element) -> PointAnnotation) {
        self.data = data
        self.idGenerator = { $0[keyPath: id] }
        self.content = content
    }

#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    @available(iOS 13.0, *)
    public init(_ data: Data, content: @escaping (Data.Element) -> PointAnnotation) where Data.Element: Identifiable, Data.Element.ID == ID {
        self.init(data, id: \.id, content: content)
    }

    func _visit(_ visitor: MapContentVisitor) {
        let anyGroup = eraseToAny(visitor.id)
        visitor.add(annotationGroup: anyGroup)
    }

    func eraseToAny(_ prefixId: [AnyHashable]) -> AnyAnnotationGroup {
        AnyAnnotationGroup { orchestrator, id, idMap in
            let manager = orchestrator.annotationManagersById[id]
                as? PointAnnotationManager
            ?? orchestrator.makePointAnnotationManager(id: id, layerPosition: self.layerPosition, clusterOptions: self.clusterOptions)
            self.updateProperties(manager: manager)
            manager.isSwiftUI = true

            let annotations = data.map { element in
                var annotation = content(element)
                let id = prefixId + [idGenerator(element)]
                let stringId = idMap[id] ?? annotation.id
                idMap[id] = stringId
                annotation.id = stringId
                annotation.isDraggable = false
                annotation.isSelected = false
                return annotation
            }
            manager.annotations = annotations
        }
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
        assign(manager, \.iconTranslate, value: iconTranslate)
        assign(manager, \.iconTranslateAnchor, value: iconTranslateAnchor)
        assign(manager, \.textTranslate, value: textTranslate)
        assign(manager, \.textTranslateAnchor, value: textTranslateAnchor)
    }

    // MARK: - Common layer properties

    private var iconAllowOverlap: Bool?
    /// If true, the icon will be visible even if it collides with other previously drawn symbols.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func iconAllowOverlap(_ newValue: Bool) -> Self {
        with(self, setter(\.iconAllowOverlap, newValue))
    }

    private var iconIgnorePlacement: Bool?
    /// If true, other symbols can be visible even if they collide with the icon.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func iconIgnorePlacement(_ newValue: Bool) -> Self {
        with(self, setter(\.iconIgnorePlacement, newValue))
    }

    private var iconKeepUpright: Bool?
    /// If true, the icon may be flipped to prevent it from being rendered upside-down.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func iconKeepUpright(_ newValue: Bool) -> Self {
        with(self, setter(\.iconKeepUpright, newValue))
    }

    private var iconOptional: Bool?
    /// If true, text will display without their corresponding icons when the icon collides with other symbols and the text does not.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func iconOptional(_ newValue: Bool) -> Self {
        with(self, setter(\.iconOptional, newValue))
    }

    private var iconPadding: Double?
    /// Size of the additional area around the icon bounding box used for detecting symbol collisions.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func iconPadding(_ newValue: Double) -> Self {
        with(self, setter(\.iconPadding, newValue))
    }

    private var iconPitchAlignment: IconPitchAlignment?
    /// Orientation of icon when map is pitched.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func iconPitchAlignment(_ newValue: IconPitchAlignment) -> Self {
        with(self, setter(\.iconPitchAlignment, newValue))
    }

    private var iconRotationAlignment: IconRotationAlignment?
    /// In combination with `symbol-placement`, determines the rotation behavior of icons.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func iconRotationAlignment(_ newValue: IconRotationAlignment) -> Self {
        with(self, setter(\.iconRotationAlignment, newValue))
    }

    private var symbolAvoidEdges: Bool?
    /// If true, the symbols will not cross tile edges to avoid mutual collisions. Recommended in layers that don't have enough padding in the vector tile to prevent collisions, or if it is a point symbol layer placed after a line symbol layer. When using a client that supports global collision detection, like Mapbox GL JS version 0.42.0 or greater, enabling this property is not needed to prevent clipped labels at tile boundaries.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func symbolAvoidEdges(_ newValue: Bool) -> Self {
        with(self, setter(\.symbolAvoidEdges, newValue))
    }

    private var symbolPlacement: SymbolPlacement?
    /// Label placement relative to its geometry.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func symbolPlacement(_ newValue: SymbolPlacement) -> Self {
        with(self, setter(\.symbolPlacement, newValue))
    }

    private var symbolSpacing: Double?
    /// Distance between two symbol anchors.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func symbolSpacing(_ newValue: Double) -> Self {
        with(self, setter(\.symbolSpacing, newValue))
    }

    private var symbolZOrder: SymbolZOrder?
    /// Determines whether overlapping symbols in the same layer are rendered in the order that they appear in the data source or by their y-position relative to the viewport. To control the order and prioritization of symbols otherwise, use `symbol-sort-key`.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func symbolZOrder(_ newValue: SymbolZOrder) -> Self {
        with(self, setter(\.symbolZOrder, newValue))
    }

    private var textAllowOverlap: Bool?
    /// If true, the text will be visible even if it collides with other previously drawn symbols.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func textAllowOverlap(_ newValue: Bool) -> Self {
        with(self, setter(\.textAllowOverlap, newValue))
    }

    private var textFont: [String]?
    /// Font stack to use for displaying text.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func textFont(_ newValue: [String]) -> Self {
        with(self, setter(\.textFont, newValue))
    }

    private var textIgnorePlacement: Bool?
    /// If true, other symbols can be visible even if they collide with the text.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func textIgnorePlacement(_ newValue: Bool) -> Self {
        with(self, setter(\.textIgnorePlacement, newValue))
    }

    private var textKeepUpright: Bool?
    /// If true, the text may be flipped vertically to prevent it from being rendered upside-down.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func textKeepUpright(_ newValue: Bool) -> Self {
        with(self, setter(\.textKeepUpright, newValue))
    }

    private var textMaxAngle: Double?
    /// Maximum angle change between adjacent characters.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func textMaxAngle(_ newValue: Double) -> Self {
        with(self, setter(\.textMaxAngle, newValue))
    }

    private var textOptional: Bool?
    /// If true, icons will display without their corresponding text when the text collides with other symbols and the icon does not.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func textOptional(_ newValue: Bool) -> Self {
        with(self, setter(\.textOptional, newValue))
    }

    private var textPadding: Double?
    /// Size of the additional area around the text bounding box used for detecting symbol collisions.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func textPadding(_ newValue: Double) -> Self {
        with(self, setter(\.textPadding, newValue))
    }

    private var textPitchAlignment: TextPitchAlignment?
    /// Orientation of text when map is pitched.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func textPitchAlignment(_ newValue: TextPitchAlignment) -> Self {
        with(self, setter(\.textPitchAlignment, newValue))
    }

    private var textRotationAlignment: TextRotationAlignment?
    /// In combination with `symbol-placement`, determines the rotation behavior of the individual glyphs forming the text.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func textRotationAlignment(_ newValue: TextRotationAlignment) -> Self {
        with(self, setter(\.textRotationAlignment, newValue))
    }

    private var textVariableAnchor: [TextAnchor]?
    /// To increase the chance of placing high-priority labels on the map, you can provide an array of `text-anchor` locations: the renderer will attempt to place the label at each location, in order, before moving onto the next label. Use `text-justify: auto` to choose justification based on anchor position. To apply an offset, use the `text-radial-offset` or the two-dimensional `text-offset`.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func textVariableAnchor(_ newValue: [TextAnchor]) -> Self {
        with(self, setter(\.textVariableAnchor, newValue))
    }

    private var textWritingMode: [TextWritingMode]?
    /// The property allows control over a symbol's orientation. Note that the property values act as a hint, so that a symbol whose language doesn’t support the provided orientation will be laid out in its natural orientation. Example: English point symbol will be rendered horizontally even if array value contains single 'vertical' enum value. For symbol with point placement, the order of elements in an array define priority order for the placement of an orientation variant. For symbol with line placement, the default text writing mode is either ['horizontal', 'vertical'] or ['vertical', 'horizontal'], the order doesn't affect the placement.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func textWritingMode(_ newValue: [TextWritingMode]) -> Self {
        with(self, setter(\.textWritingMode, newValue))
    }

    private var iconTranslate: [Double]?
    /// Distance that the icon's anchor is moved from its original placement. Positive values indicate right and down, while negative values indicate left and up.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func iconTranslate(_ newValue: [Double]) -> Self {
        with(self, setter(\.iconTranslate, newValue))
    }

    private var iconTranslateAnchor: IconTranslateAnchor?
    /// Controls the frame of reference for `icon-translate`.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func iconTranslateAnchor(_ newValue: IconTranslateAnchor) -> Self {
        with(self, setter(\.iconTranslateAnchor, newValue))
    }

    private var textTranslate: [Double]?
    /// Distance that the text's anchor is moved from its original placement. Positive values indicate right and down, while negative values indicate left and up.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func textTranslate(_ newValue: [Double]) -> Self {
        with(self, setter(\.textTranslate, newValue))
    }

    private var textTranslateAnchor: TextTranslateAnchor?
    /// Controls the frame of reference for `text-translate`.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func textTranslateAnchor(_ newValue: TextTranslateAnchor) -> Self {
        with(self, setter(\.textTranslateAnchor, newValue))
    }

    private var clusterOptions: ClusterOptions?

    /// Defines point annotation clustering options.
    ///
    /// - NOTE: Clustering options aren't updatable. Only the first value passed to this function set will take effect.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func clusterOptions(_ newValue: ClusterOptions) -> Self {
        with(self, setter(\.clusterOptions, newValue))
    }

    private var layerPosition: LayerPosition?

    /// Defines relative position of the layers drawing the annotations managed by the current group.
    ///
    /// - NOTE: Layer position isn't updatable. Only the first value passed to this function set will take effect.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func layerPosition(_ newValue: LayerPosition) -> Self {
        with(self, setter(\.layerPosition, newValue))
    }
}

// End of generated file.
