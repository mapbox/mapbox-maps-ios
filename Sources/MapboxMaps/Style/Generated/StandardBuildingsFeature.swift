// This file is generated.

/// Featureset describing the buildings.
///
/// Use ``FeaturesetDescriptor/standardBuildings`` descriptor to handle interactions on Buildings features:
///
/// ```swift
/// mapboxMap.addInteraction(TapInteraction(.standardBuildings) { feature, ctx in
///     // Handle the tapped feature here
/// })
/// ```
@_spi(Experimental)
@_documentation(visibility: public)
public final class StandardBuildingsFeature: FeaturesetFeatureType {
    /// The state that can be set for the feature.
    ///
    /// Each feature of this class can receive the following states: `highlight`, `select`.
    /// Use ``FeatureState`` (SwiftUI) or ``MapboxMap/setFeatureState(_:state:callback:)`` (UIKit) to set the states:
    ///
    /// ```swift
    /// // SwiftUI
    /// Map {
    ///     FeatureState(aBuildingsFeature, state: .init(highlight: true))
    /// }
    ///
    /// // UIKit:
    /// mapboxMap.setFeatureState(aBuildingsFeature, state: .init(highlight: true))
    /// ```
    ///
    /// To configure appearance of the states use the following configuration options: `buildingHighlightColor`, `buildingSelectColor`.
    /// For more information see ``MapStyle/standardExperimental(theme:lightPreset:font:showPointOfInterestLabels:showTransitLabels:showPlaceLabels:showRoadLabels:show3dObjects:buildingHighlightColor:buildingSelectColor:placeLabelHighlightColor:placeLabelSelectColor:)``.
    @_documentation(visibility: public)
    public struct State: Codable, Equatable {
        /// When `true`, the building is highlighted. Use this state to create a temporary effect (e.g. hover).
        @_documentation(visibility: public)
        public var highlight: Bool?

        /// When `true`, the building is selected. Use this state to create a permanent effect. Note: the `select` state has a higher priority than `highlight`.
        @_documentation(visibility: public)
        public var select: Bool?

        /// Creates the state.
        ///
        /// - Parameters:
        ///   - highlight: When `true`, the building is highlighted. Use this state to create a temporary effect (e.g. hover).
        ///   - select: When `true`, the building is selected. Use this state to create a permanent effect. Note: the `select` state has a higher priority than `highlight`.
        @_documentation(visibility: public)
        public init(highlight: Bool? = nil, select: Bool? = nil) {
            self.highlight = highlight
            self.select = select
        }
    }

    @_documentation(visibility: public)
    public struct StateKey: CustomStringConvertible {
        public let description: String

        /// When `true`, the building is highlighted. Use this state to create a temporary effect (e.g. hover).
        @_documentation(visibility: public)
        public static let highlight: StateKey = .init(description: "highlight")

        /// When `true`, the building is selected. Use this state to create a permanent effect. Note: the `select` state has a higher priority than `highlight`.
        @_documentation(visibility: public)
        public static let select: StateKey = .init(description: "select")
    }

    /// A high-level building group like building-2d, building-3d, etc.
    @_documentation(visibility: public)
    public var group: String? { impl.properties["group"]??.string }

    private let impl: FeaturesetFeature

    /// An identifier of the feature.
    ///
    /// The identifier can be `nil` if the underlying source doesn't have identifiers for features.
    /// In this case it's impossible to set a feature state for an individual feature.
    @_documentation(visibility: public)
    public var id: FeaturesetFeatureId? { impl.id }

    /// A featureset descriptor denoting a featureset this feature belongs to.
    @_documentation(visibility: public)
    public var featureset: FeaturesetDescriptor<StandardBuildingsFeature> { impl.featureset.converted() }

    /// A feature state.
    ///
    /// This is a **snapshot** of the state that the feature had when it was interacted with.
    /// To update and read the original state, use ``MapboxMap/setFeatureState(_:state:callback:)`` and ``MapboxMap/getFeatureState(_:callback:)``.
    @_documentation(visibility: public)
    private(set) public lazy var state: State = { impl.typedState(default: State()) }()

    /// A feature geometry.
    @_documentation(visibility: public)
    public var geometry: Geometry { impl.geometry }

    /// Feature properties in JSON format.
    @_documentation(visibility: public)
    public var properties: JSONObject { impl.properties }

    /// Converts a generic feature to the typed one.
    ///
    /// - Parameters:
    ///    - other: A generic feature.
    @_documentation(visibility: public)
    public init?(from other: FeaturesetFeature) {
        self.impl = other
    }
}

@_documentation(visibility: public)
extension FeaturesetDescriptor where FeatureType == StandardBuildingsFeature {
    /// Featureset describing the buildings.
    /// - Important: This featureset is only available when Experimental Standard Style is loaded directly or imported, using the ``MapStyle/standardExperimental`` style.
    /// **Don't use the Standard Experimental Style in production.**
    @_spi(Experimental)
    @_documentation(visibility: public)
    public static var standardBuildings: FeaturesetDescriptor {
       FeaturesetDescriptor<FeaturesetFeature>.featureset("buildings").converted()
    }

    /// Featureset describing the buildings.
    ///
    /// Use this function if you import the style instead of loading it directly. See ``StyleImport`` for more information.
    ///
    /// - Important: This featureset is only available when Experimental Standard Style is loaded directly or imported, using the ``MapStyle/standardExperimental`` style.
    /// **Don't use the Standard Experimental Style in production.**
    ///
    /// - Parameters:
    ///   - importId: The import identifier of the imported style that defines the featureset.
    @_spi(Experimental)
    @_documentation(visibility: public)
    public static func standardBuildings(importId: String) -> FeaturesetDescriptor {
        FeaturesetDescriptor<FeaturesetFeature>.featureset("buildings", importId: importId).converted()
    }
}
