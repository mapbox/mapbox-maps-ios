// This file is generated

extension PolylineAnnotation: PrimitiveMapContent {
    func _visit(_ visitor: MapContentVisitor) {
        let group = PolylineAnnotationGroup([0], id: \.self) { _ in
            self
        }
        visitor.add(annotationGroup: group.eraseToAny(visitor.id))
    }
}

/// Displays a group of polyline annotations.
///
/// Always prefer to use annotation group over individual annotation if more than one annotation of the same type is displayed.
/// The annotation group is usually more performant, since only one underlying layer is used to draw multiple annotations.
///
/// Annotation group allows to configure group-related options, such as clustering (only for point annotations) and others.
@_spi(Experimental)
public struct PolylineAnnotationGroup<Data: RandomAccessCollection, ID: Hashable>: PrimitiveMapContent {
    public typealias Content = PolylineAnnotation
    var data: Data
    var idGenerator: (Data.Element) -> ID
    var content: (Data.Element) -> Content

    public init(_ data: Data, id: KeyPath<Data.Element, ID>, content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.idGenerator = { $0[keyPath: id] }
        self.content = content
    }

    @available(iOS 13.0, *)
    public init(_ data: Data, content: @escaping (Data.Element) -> Content) where Data.Element: Identifiable, Data.Element.ID == ID {
        self.init(data, id: \.id, content: content)
    }

    func _visit(_ visitor: MapContentVisitor) {
        let anyGroup = eraseToAny(visitor.id)
        visitor.add(annotationGroup: anyGroup)
    }

    func eraseToAny(_ prefixId: [AnyHashable]) -> AnyAnnotationGroup {
        AnyAnnotationGroup { orchestrator, id, idMap in
            let manager = orchestrator.annotationManagersById[id]
                as? PolylineAnnotationManager
            ?? orchestrator.makePolylineAnnotationManager(id: id, layerPosition: self.layerPosition)
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

    private func updateProperties(manager: PolylineAnnotationManager) {
        assign(manager, \.lineCap, value: lineCap)
        assign(manager, \.lineMiterLimit, value: lineMiterLimit)
        assign(manager, \.lineRoundLimit, value: lineRoundLimit)
        assign(manager, \.lineDasharray, value: lineDasharray)
        assign(manager, \.lineDepthOcclusionFactor, value: lineDepthOcclusionFactor)
        assign(manager, \.lineEmissiveStrength, value: lineEmissiveStrength)
        assign(manager, \.lineTranslate, value: lineTranslate)
        assign(manager, \.lineTranslateAnchor, value: lineTranslateAnchor)
        assign(manager, \.lineTrimOffset, value: lineTrimOffset)
    }

    // MARK: - Common layer properties

    /// The display of line endings.
    private var lineCap: LineCap?
    public func lineCap(_ newValue: LineCap) -> Self {
        with(self, setter(\.lineCap, newValue))
    }

    /// Used to automatically convert miter joins to bevel joins for sharp angles.
    private var lineMiterLimit: Double?
    public func lineMiterLimit(_ newValue: Double) -> Self {
        with(self, setter(\.lineMiterLimit, newValue))
    }

    /// Used to automatically convert round joins to miter joins for shallow angles.
    private var lineRoundLimit: Double?
    public func lineRoundLimit(_ newValue: Double) -> Self {
        with(self, setter(\.lineRoundLimit, newValue))
    }

    /// Specifies the lengths of the alternating dashes and gaps that form the dash pattern. The lengths are later scaled by the line width. To convert a dash length to pixels, multiply the length by the current line width. Note that GeoJSON sources with `lineMetrics: true` specified won't render dashed lines to the expected scale. Also note that zoom-dependent expressions will be evaluated only at integer zoom levels.
    private var lineDasharray: [Double]?
    public func lineDasharray(_ newValue: [Double]) -> Self {
        with(self, setter(\.lineDasharray, newValue))
    }

    /// Decrease line layer opacity based on occlusion from 3D objects. Value 0 disables occlusion, value 1 means fully occluded.
    private var lineDepthOcclusionFactor: Double?
    public func lineDepthOcclusionFactor(_ newValue: Double) -> Self {
        with(self, setter(\.lineDepthOcclusionFactor, newValue))
    }

    /// Emission strength
    private var lineEmissiveStrength: Double?
    public func lineEmissiveStrength(_ newValue: Double) -> Self {
        with(self, setter(\.lineEmissiveStrength, newValue))
    }

    /// The geometry's offset. Values are [x, y] where negatives indicate left and up, respectively.
    private var lineTranslate: [Double]?
    public func lineTranslate(_ newValue: [Double]) -> Self {
        with(self, setter(\.lineTranslate, newValue))
    }

    /// Controls the frame of reference for `line-translate`.
    private var lineTranslateAnchor: LineTranslateAnchor?
    public func lineTranslateAnchor(_ newValue: LineTranslateAnchor) -> Self {
        with(self, setter(\.lineTranslateAnchor, newValue))
    }

    /// The line part between [trim-start, trim-end] will be marked as transparent to make a route vanishing effect. The line trim-off offset is based on the whole line range [0.0, 1.0].
    private var lineTrimOffset: [Double]?
    public func lineTrimOffset(_ newValue: [Double]) -> Self {
        with(self, setter(\.lineTrimOffset, newValue))
    }


    private var layerPosition: LayerPosition?

    /// Defines relative position of the layers drawing the annotations managed by the current group.
    ///
    /// - NOTE: Layer position isn't updatable. Only the first value passed to this function set will take effect.
    public func layerPosition(_ newValue: LayerPosition) -> Self {
        with(self, setter(\.layerPosition, newValue))
    }
}

// End of generated file.
