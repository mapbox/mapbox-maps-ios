// This file is generated

extension PolygonAnnotation: PrimitiveMapContent {
    func _visit(_ visitor: MapContentVisitor) {
        let group = PolygonAnnotationGroup([0], id: \.self) { _ in
            self
        }
        visitor.add(annotationGroup: group.eraseToAny(visitor.id))
    }
}

/// Displays a group of polygon annotations.
///
/// Always prefer to use annotation group over individual annotation if more than one annotation of the same type is displayed.
/// The annotation group is usually more performant, since only one underlying layer is used to draw multiple annotations.
///
/// Annotation group allows to configure group-related options, such as clustering (only for point annotations) and others.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
@_spi(Experimental)
public struct PolygonAnnotationGroup<Data: RandomAccessCollection, ID: Hashable>: PrimitiveMapContent {
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    var data: Data
    var idGenerator: (Data.Element) -> ID
    var content: (Data.Element) -> PolygonAnnotation

#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public init(_ data: Data, id: KeyPath<Data.Element, ID>, content: @escaping (Data.Element) -> PolygonAnnotation) {
        self.data = data
        self.idGenerator = { $0[keyPath: id] }
        self.content = content
    }

#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    @available(iOS 13.0, *)
    public init(_ data: Data, content: @escaping (Data.Element) -> PolygonAnnotation) where Data.Element: Identifiable, Data.Element.ID == ID {
        self.init(data, id: \.id, content: content)
    }

    func _visit(_ visitor: MapContentVisitor) {
        let anyGroup = eraseToAny(visitor.id)
        visitor.add(annotationGroup: anyGroup)
    }

    func eraseToAny(_ prefixId: [AnyHashable]) -> AnyAnnotationGroup {
        AnyAnnotationGroup(layerId: layerId) { orchestrator, id, idMap in
            let manager = orchestrator.annotationManagersById[id]
                as? PolygonAnnotationManager
            ?? orchestrator.makePolygonAnnotationManager(id: id, layerPosition: self.layerPosition)
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

    private func updateProperties(manager: PolygonAnnotationManager) {
        assign(manager, \.fillAntialias, value: fillAntialias)
        assign(manager, \.fillEmissiveStrength, value: fillEmissiveStrength)
        assign(manager, \.fillTranslate, value: fillTranslate)
        assign(manager, \.fillTranslateAnchor, value: fillTranslateAnchor)
    }

    // MARK: - Common layer properties

    private var fillAntialias: Bool?
    /// Whether or not the fill should be antialiased.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func fillAntialias(_ newValue: Bool) -> Self {
        with(self, setter(\.fillAntialias, newValue))
    }

    private var fillEmissiveStrength: Double?
    /// Controls the intensity of light emitted on the source features. This property works only with 3D light, i.e. when `lights` root property is defined.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func fillEmissiveStrength(_ newValue: Double) -> Self {
        with(self, setter(\.fillEmissiveStrength, newValue))
    }

    private var fillTranslate: [Double]?
    /// The geometry's offset. Values are [x, y] where negatives indicate left and up, respectively.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func fillTranslate(_ newValue: [Double]) -> Self {
        with(self, setter(\.fillTranslate, newValue))
    }

    private var fillTranslateAnchor: FillTranslateAnchor?
    /// Controls the frame of reference for `fill-translate`.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func fillTranslateAnchor(_ newValue: FillTranslateAnchor) -> Self {
        with(self, setter(\.fillTranslateAnchor, newValue))
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

    var layerId: String?

    /// Specifies identifier for underlying implementation layer.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func layerId(_ newValue: String) -> Self {
        with(self, setter(\.layerId, newValue))
    }
}

// End of generated file.
