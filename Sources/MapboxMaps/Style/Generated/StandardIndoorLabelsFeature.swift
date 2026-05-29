// This file is generated.

/// Labels for indoor buildings.
///
/// Use ``FeaturesetDescriptor/standardIndoorLabels`` descriptor to handle interactions on Indoor Labels features:
///
/// ```swift
/// mapboxMap.addInteraction(TapInteraction(.standardIndoorLabels) { feature, ctx in
///     // Handle the tapped feature here
/// })
/// ```
public final class StandardIndoorLabelsFeature: FeaturesetFeatureType {
    /// The state that can be set for the feature.
    ///
    /// Each feature of this class can receive the following states: `highlight`, `select`.
    /// Use ``FeatureState`` (SwiftUI) or ``MapboxMap/setFeatureState(_:state:callback:)`` (UIKit) to set the states:
    ///
    /// ```swift
    /// // SwiftUI
    /// Map {
    ///     FeatureState(aIndoorLabelsFeature, state: .init(highlight: true))
    /// }
    ///
    /// // UIKit:
    /// mapboxMap.setFeatureState(aIndoorLabelsFeature, state: .init(highlight: true))
    /// ```
    ///
    /// To configure appearance of the states use the following configuration options: `colorIndoorLabelHighlight`, `colorIndoorLabelSelect`.
    /// For more information see ``MapStyle/standard(theme:lightPreset:font:showPointOfInterestLabels:showTransitLabels:showPlaceLabels:showRoadLabels:showPedestrianRoads:show3dObjects:backgroundPointOfInterestLabels:colorAdminBoundaries:colorBuildingHighlight:colorBuildings:colorBuildingSelect:colorCommercial:colorEducation:colorGreenspace:colorIndoorLabelHighlight:colorIndoorLabelSelect:colorIndustrial:colorLand:colorMedical:colorModePointOfInterestLabels:colorMotorways:colorPlaceLabelHighlight:colorPlaceLabels:colorPlaceLabelSelect:colorPointOfInterestLabels:colorRoadLabels:colorRoads:colorTrunks:colorWater:densityPointOfInterestLabels:fuelingStationModePointOfInterestLabels:roadsBrightness:show3dBuildings:show3dFacades:show3dLandmarks:show3dTrees:showAdminBoundaries:showIndoor:showIndoorLabels:showLandmarkIconLabels:showLandmarkIcons:themeData:)``.
    public struct State: Codable, Equatable {
        /// When `true`, the feature is highlighted. Use this state to create a temporary effect (e.g. hover).
        public var highlight: Bool?

        /// When `true`, the feature is selected. Use this state to create a permanent effect. Note: the `select` state has a higher priority than `highlight`.
        public var select: Bool?

        /// Creates the state.
        ///
        /// - Parameters:
        ///   - highlight: When `true`, the feature is highlighted. Use this state to create a temporary effect (e.g. hover).
        ///   - select: When `true`, the feature is selected. Use this state to create a permanent effect. Note: the `select` state has a higher priority than `highlight`.
        public init(highlight: Bool? = nil, select: Bool? = nil) {
            self.highlight = highlight
            self.select = select
        }
    }

    public struct StateKey: CustomStringConvertible {
        public let description: String

        /// When `true`, the feature is highlighted. Use this state to create a temporary effect (e.g. hover).
        public static let highlight: StateKey = .init(description: "highlight")

        /// When `true`, the feature is selected. Use this state to create a permanent effect. Note: the `select` state has a higher priority than `highlight`.
        public static let select: StateKey = .init(description: "select")
    }

    /// Name of the point of interest.
    public var name: String? { impl.properties["name"]??.string }

    /// A description of the room or area type.
    public var shapeType: String? { impl.properties["shape_type"]??.string }

    /// A sub-category, like cafe, newsstand, etc.
    public var type: String? { impl.properties["type"]??.string }

    /// A high-level category, like restaurant, retail, etc.
    public var `class`: String? { impl.properties["class"]??.string }

    private let impl: FeaturesetFeature

    /// An identifier of the feature.
    ///
    /// The identifier can be `nil` if the underlying source doesn't have identifiers for features.
    /// In this case it's impossible to set a feature state for an individual feature.
    public var id: FeaturesetFeatureId? { impl.id }

    /// A featureset descriptor denoting a featureset this feature belongs to.
    public var featureset: FeaturesetDescriptor<StandardIndoorLabelsFeature> { impl.featureset.converted() }

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

extension FeaturesetDescriptor where FeatureType == StandardIndoorLabelsFeature {
    /// Labels for indoor buildings.
    public static var standardIndoorLabels: FeaturesetDescriptor {
       FeaturesetDescriptor<FeaturesetFeature>.featureset("indoor-labels").converted()
    }

    /// Labels for indoor buildings.
    ///
    /// Use this function if you import the style instead of loading it directly. See ``StyleImport`` for more information.
    ///
    ///
    /// - Parameters:
    ///   - importId: The import identifier of the imported style that defines the featureset.
    public static func standardIndoorLabels(importId: String) -> FeaturesetDescriptor {
        FeaturesetDescriptor<FeaturesetFeature>.featureset("indoor-labels", importId: importId).converted()
    }
}
