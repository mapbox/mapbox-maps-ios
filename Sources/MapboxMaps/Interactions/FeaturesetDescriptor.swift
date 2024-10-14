/// A featureset descriptor.
///
/// The descriptor instance acts as a universal target for interactions or querying rendered features (see  ``TapInteraction``, ``LongPressInteraction``,
/// ``MapboxMap/queryRenderedFeatures(with:featureset:filter:completion:)``).
///
/// Depending on the use case, you can create the descriptor using multiple methods:
/// - When adding an interaction to a layer, use ``FeaturesetDescriptor/layer(_:)`` to create the descriptor.
/// - When working with the Standard Style use pre-defined descriptors such as ``FeaturesetDescriptor-struct/standardPoi``, ``FeaturesetDescriptor-struct/standardPlaceLabels``, ``FeaturesetDescriptor-struct/standardBuildings``.
/// - When working with any other imported style that has defined featuresets, use ``FeaturesetDescriptor-struct/featureset(_:importId:)`` to create the descriptor.
///
/// - Important: The production version of Standard Style does not support the featuresets yet. Use the ``MapStyle/standardExperimental`` for feature preview. **Don't use the Standard Experimental in production.**
@_spi(Experimental)
@_documentation(visibility: public)
public struct FeaturesetDescriptor<FeatureType: FeaturesetFeatureType>: Equatable {
    /// An optional unique identifier for the featureset within the style.
    /// This id is used to reference a specific featureset.
    ///
    /// * Note: If `featuresetId` is provided and valid, it takes precedence over `layerId`,
    /// meaning `layerId` will not be considered even if it has a valid value.
    @_documentation(visibility: public)
    public let featuresetId: String?

    /// An optional import id that is required if the featureset is defined within an imported style.
    /// If the featureset belongs to the current style, this field should be set to a null string.
    ///
    /// * Note: `importId` is only applicable when used in conjunction with `featuresetId`
    /// and has no effect when used with `layerId`.
    @_documentation(visibility: public)
    public let importId: String?

    /// An optional unique identifier for the layer within the current style.
    ///
    /// * Note: If `featuresetId` is valid, `layerId` will be ignored even if it has a valid value.
    /// Additionally, `importId` does not apply when using `layerId`.
    @_documentation(visibility: public)
    public let layerId: String?

    private init(featuresetId: String? = nil, importId: String? = nil, layerId: String? = nil) {
        self.featuresetId = featuresetId
        self.importId = importId
        self.layerId = layerId
    }

    /// Creates a new featureset with a different type.
    ///
    /// Use this method if you create a custom typed descriptor.
    public func converted<U: FeaturesetFeatureType>() -> FeaturesetDescriptor<U> {
        FeaturesetDescriptor<U>(featuresetId: featuresetId, importId: importId, layerId: layerId)
    }
}

@_documentation(visibility: public)
extension FeaturesetDescriptor where FeatureType == FeaturesetFeature {
    /// Creates a featureset descriptor targeting a featureset created in the imported style.
    ///
    /// By default, the `importId` is `basemap` which is a well-known for a basemap when
    /// Evolving Basemap (e.g Standard) style is loaded directly.
    /// If you import a style with a different id, use that id to add interaction for that imported style.
    ///
    /// See more info in ``StyleImport``.
    ///
    /// - Parameters:
    ///   - id: An id of the featureset.
    ///   - importId: An id of the Style import where the featureset is defined.
    @_spi(Experimental)
    @_documentation(visibility: public)
    public static func featureset(_ id: String, importId: String? = "basemap") -> FeaturesetDescriptor {
        .init(featuresetId: id, importId: importId)
    }

    /// Creates a featureset descriptor targeting an individual layer.
    ///
    /// An individual layer added in the root style (not in the imported style) can be treated as a featureset too.
    /// This way you can add ``Interaction`` to any layer in your style.
    ///
    /// - Parameters:
    ///   - layerId: An id of the layer.
    @_spi(Experimental)
    @_documentation(visibility: public)
    public static func layer(_ layerId: String) -> FeaturesetDescriptor {
        .init(layerId: layerId)
    }
}

extension FeaturesetDescriptor {
    init(core: CoreFeaturesetDescriptor) {
        self.featuresetId = core.featuresetId
        self.importId = core.importId
        self.layerId = core.layerId
    }

    var core: CoreFeaturesetDescriptor {
        CoreFeaturesetDescriptor(
            featuresetId: featuresetId,
            importId: importId,
            layerId: layerId
        )
    }
}
