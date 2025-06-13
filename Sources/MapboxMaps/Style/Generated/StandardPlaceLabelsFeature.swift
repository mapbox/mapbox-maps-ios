// This file is generated.

/// Points for labeling places including countries, states, cities, towns, and neighborhoods.
///
/// Use ``FeaturesetDescriptor/standardPlaceLabels`` descriptor to handle interactions on Place Labels features:
///
/// ```swift
/// mapboxMap.addInteraction(TapInteraction(.standardPlaceLabels) { feature, ctx in
///     // Handle the tapped feature here
/// })
/// ```
public final class StandardPlaceLabelsFeature: FeaturesetFeatureType {
    /// The state that can be set for the feature.
    ///
    /// Each feature of this class can receive the following states: `hide`, `highlight`, `select`.
    /// Use ``FeatureState`` (SwiftUI) or ``MapboxMap/setFeatureState(_:state:callback:)`` (UIKit) to set the states:
    ///
    /// ```swift
    /// // SwiftUI
    /// Map {
    ///     FeatureState(aPlaceLabelsFeature, state: .init(hide: true))
    /// }
    ///
    /// // UIKit:
    /// mapboxMap.setFeatureState(aPlaceLabelsFeature, state: .init(hide: true))
    /// ```
    ///
    /// To configure appearance of the states use the following configuration options: `colorPlaceLabelHighlight`, `colorPlaceLabelSelect`.
    /// For more information see ``MapStyle/standardSatellite(lightPreset:font:showPointOfInterestLabels:showTransitLabels:showPlaceLabels:showRoadLabels:showRoadsAndTransit:showPedestrianRoads:colorMotorways:colorPlaceLabelHighlight:colorPlaceLabelSelect:colorRoads:colorTrunks:)``.
    public struct State: Codable, Equatable {
        /// When `true`, hides the label. Use this state when displaying a custom annotation on top.
        public var hide: Bool?

        /// When `true`, the feature is highlighted. Use this state to create a temporary effect (e.g. hover).
        public var highlight: Bool?

        /// When `true`, the feature is selected. Use this state to create a permanent effect. Note: the `select` state has a higher priority than `highlight`.
        public var select: Bool?

        /// Creates the state.
        ///
        /// - Parameters:
        ///   - hide: When `true`, hides the label. Use this state when displaying a custom annotation on top.
        ///   - highlight: When `true`, the feature is highlighted. Use this state to create a temporary effect (e.g. hover).
        ///   - select: When `true`, the feature is selected. Use this state to create a permanent effect. Note: the `select` state has a higher priority than `highlight`.
        public init(hide: Bool? = nil, highlight: Bool? = nil, select: Bool? = nil) {
            self.hide = hide
            self.highlight = highlight
            self.select = select
        }
    }

    public struct StateKey: CustomStringConvertible {
        public let description: String

        /// When `true`, hides the label. Use this state when displaying a custom annotation on top.
        public static let hide: StateKey = .init(description: "hide")

        /// When `true`, the feature is highlighted. Use this state to create a temporary effect (e.g. hover).
        public static let highlight: StateKey = .init(description: "highlight")

        /// When `true`, the feature is selected. Use this state to create a permanent effect. Note: the `select` state has a higher priority than `highlight`.
        public static let select: StateKey = .init(description: "select")
    }

    /// Name of the place label.
    public var name: String? { impl.properties["name"]??.string }

    /// Provides a broad distinction between place types.
    public var `class`: String? { impl.properties["class"]??.string }

    private let impl: FeaturesetFeature

    /// An identifier of the feature.
    ///
    /// The identifier can be `nil` if the underlying source doesn't have identifiers for features.
    /// In this case it's impossible to set a feature state for an individual feature.
    public var id: FeaturesetFeatureId? { impl.id }

    /// A featureset descriptor denoting a featureset this feature belongs to.
    public var featureset: FeaturesetDescriptor<StandardPlaceLabelsFeature> { impl.featureset.converted() }

    /// A feature state.
    ///
    /// This is a **snapshot** of the state that the feature had when it was interacted with.
    /// To update and read the original state, use ``MapboxMap/setFeatureState(_:state:callback:)`` and ``MapboxMap/getFeatureState(_:callback:)``.
    private(set) public lazy var state: State = { impl.typedState(default: State()) }()

    /// A feature geometry.
    public var geometry: Geometry { impl.geometry }

    /// Feature properties in JSON format.
    public var properties: JSONObject { impl.properties }

    /// Converts a generic feature to the typed one.
    ///
    /// - Parameters:
    ///    - other: A generic feature.
    public init?(from other: FeaturesetFeature) {
        self.impl = other
    }
}

extension FeaturesetDescriptor where FeatureType == StandardPlaceLabelsFeature {
    /// Points for labeling places including countries, states, cities, towns, and neighborhoods.
    public static var standardPlaceLabels: FeaturesetDescriptor {
       FeaturesetDescriptor<FeaturesetFeature>.featureset("place-labels").converted()
    }

    /// Points for labeling places including countries, states, cities, towns, and neighborhoods.
    ///
    /// Use this function if you import the style instead of loading it directly. See ``StyleImport`` for more information.
    ///
    ///
    /// - Parameters:
    ///   - importId: The import identifier of the imported style that defines the featureset.
    public static func standardPlaceLabels(importId: String) -> FeaturesetDescriptor {
        FeaturesetDescriptor<FeaturesetFeature>.featureset("place-labels", importId: importId).converted()
    }
}
