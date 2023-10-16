// This file is generated

extension CircleAnnotation: PrimitiveMapContent {
    func _visit(_ visitor: MapContentVisitor) {
        let group = CircleAnnotationGroup([0], id: \.self) { _ in
            self
        }
        visitor.add(annotationGroup: group.eraseToAny(visitor.id))
    }
}

/// Displays a group of circle annotations.
///
/// Always prefer to use annotation group over individual annotation if more than one annotation of the same type is displayed.
/// The annotation group is usually more performant, since only one underlying layer is used to draw multiple annotations.
///
/// Annotation group allows to configure group-related options, such as clustering (only for point annotations) and others.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
@_spi(Experimental)
public struct CircleAnnotationGroup<Data: RandomAccessCollection, ID: Hashable>: PrimitiveMapContent {
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    var data: Data
    var idGenerator: (Data.Element) -> ID
    var content: (Data.Element) -> CircleAnnotation

#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public init(_ data: Data, id: KeyPath<Data.Element, ID>, content: @escaping (Data.Element) -> CircleAnnotation) {
        self.data = data
        self.idGenerator = { $0[keyPath: id] }
        self.content = content
    }

#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    @available(iOS 13.0, *)
    public init(_ data: Data, content: @escaping (Data.Element) -> CircleAnnotation) where Data.Element: Identifiable, Data.Element.ID == ID {
        self.init(data, id: \.id, content: content)
    }

    func _visit(_ visitor: MapContentVisitor) {
        let anyGroup = eraseToAny(visitor.id)
        visitor.add(annotationGroup: anyGroup)
    }

    func eraseToAny(_ prefixId: [AnyHashable]) -> AnyAnnotationGroup {
        AnyAnnotationGroup(layerId: layerId) { orchestrator, id, idMap in
            let manager = orchestrator.annotationManagersById[id]
                as? CircleAnnotationManager
            ?? orchestrator.makeCircleAnnotationManager(id: id, layerPosition: self.layerPosition)
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

    private func updateProperties(manager: CircleAnnotationManager) {
        assign(manager, \.circleEmissiveStrength, value: circleEmissiveStrength)
        assign(manager, \.circlePitchAlignment, value: circlePitchAlignment)
        assign(manager, \.circlePitchScale, value: circlePitchScale)
        assign(manager, \.circleTranslate, value: circleTranslate)
        assign(manager, \.circleTranslateAnchor, value: circleTranslateAnchor)
    }

    // MARK: - Common layer properties

    private var circleEmissiveStrength: Double?
    /// Controls the intensity of light emitted on the source features. This property works only with 3D light, i.e. when `lights` root property is defined.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func circleEmissiveStrength(_ newValue: Double) -> Self {
        with(self, setter(\.circleEmissiveStrength, newValue))
    }

    private var circlePitchAlignment: CirclePitchAlignment?
    /// Orientation of circle when map is pitched.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func circlePitchAlignment(_ newValue: CirclePitchAlignment) -> Self {
        with(self, setter(\.circlePitchAlignment, newValue))
    }

    private var circlePitchScale: CirclePitchScale?
    /// Controls the scaling behavior of the circle when the map is pitched.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func circlePitchScale(_ newValue: CirclePitchScale) -> Self {
        with(self, setter(\.circlePitchScale, newValue))
    }

    private var circleTranslate: [Double]?
    /// The geometry's offset. Values are [x, y] where negatives indicate left and up, respectively.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func circleTranslate(_ newValue: [Double]) -> Self {
        with(self, setter(\.circleTranslate, newValue))
    }

    private var circleTranslateAnchor: CircleTranslateAnchor?
    /// Controls the frame of reference for `circle-translate`.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func circleTranslateAnchor(_ newValue: CircleTranslateAnchor) -> Self {
        with(self, setter(\.circleTranslateAnchor, newValue))
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
