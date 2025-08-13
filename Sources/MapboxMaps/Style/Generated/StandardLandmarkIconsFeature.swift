// This file is generated.

/// Icons for landmark buildings
///
/// Use ``FeaturesetDescriptor/standardLandmarkIcons`` descriptor to handle interactions on Landmark Icons features:
///
/// ```swift
/// mapboxMap.addInteraction(TapInteraction(.standardLandmarkIcons) { feature, ctx in
///     // Handle the tapped feature here
/// })
/// ```
public final class StandardLandmarkIconsFeature: FeaturesetFeatureType {
    /// No states supported.
    public struct State: Codable, Equatable {
        /// Creates an empty state.
        public init() {}
    }

    public struct StateKey: CustomStringConvertible {
        public let description: String
    }

    /// Unique landmark ID.
    public var landmarkId: String? { impl.properties["id"]??.string }

    /// Name of the Landmark in local language.
    public var name: String? { impl.properties["name"]??.string }

    /// Name of the Landmark in English.
    public var nameEn: String? { impl.properties["name_en"]??.string }

    /// Short name of the Landmark in local language.
    public var shortName: String? { impl.properties["short_name"]??.string }

    /// Short name of the Landmark in English.
    public var shortNameEn: String? { impl.properties["short_name_en"]??.string }

    /// Landmark type or building use.
    public var type: String? { impl.properties["type"]??.string }

    private let impl: FeaturesetFeature

    /// An identifier of the feature.
    ///
    /// The identifier can be `nil` if the underlying source doesn't have identifiers for features.
    /// In this case it's impossible to set a feature state for an individual feature.
    public var id: FeaturesetFeatureId? { impl.id }

    /// A featureset descriptor denoting a featureset this feature belongs to.
    public var featureset: FeaturesetDescriptor<StandardLandmarkIconsFeature> { impl.featureset.converted() }

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

extension FeaturesetDescriptor where FeatureType == StandardLandmarkIconsFeature {
    /// Icons for landmark buildings
    public static var standardLandmarkIcons: FeaturesetDescriptor {
       FeaturesetDescriptor<FeaturesetFeature>.featureset("landmark-icons").converted()
    }

    /// Icons for landmark buildings
    ///
    /// Use this function if you import the style instead of loading it directly. See ``StyleImport`` for more information.
    ///
    ///
    /// - Parameters:
    ///   - importId: The import identifier of the imported style that defines the featureset.
    public static func standardLandmarkIcons(importId: String) -> FeaturesetDescriptor {
        FeaturesetDescriptor<FeaturesetFeature>.featureset("landmark-icons", importId: importId).converted()
    }
}
