// This file is generated.

/// Water polygons, such as oceans, lakes, and wide rivers.
///
/// Use ``FeaturesetDescriptor/standardWater`` descriptor to handle interactions on Water features:
///
/// ```swift
/// mapboxMap.addInteraction(TapInteraction(.standardWater) { feature, ctx in
///     // Handle the tapped feature here
/// })
/// ```
public final class StandardWaterFeature: FeaturesetFeatureType {
    /// No states supported.
    public struct State: Codable, Equatable {
        /// Creates an empty state.
        public init() {}
    }

    public struct StateKey: CustomStringConvertible {
        public let description: String
    }


    private let impl: FeaturesetFeature

    /// An identifier of the feature.
    ///
    /// The identifier can be `nil` if the underlying source doesn't have identifiers for features.
    /// In this case it's impossible to set a feature state for an individual feature.
    public var id: FeaturesetFeatureId? { impl.id }

    /// A featureset descriptor denoting a featureset this feature belongs to.
    public var featureset: FeaturesetDescriptor<StandardWaterFeature> { impl.featureset.converted() }

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

extension FeaturesetDescriptor where FeatureType == StandardWaterFeature {
    /// Water polygons, such as oceans, lakes, and wide rivers.
    public static var standardWater: FeaturesetDescriptor {
       FeaturesetDescriptor<FeaturesetFeature>.featureset("water").converted()
    }

    /// Water polygons, such as oceans, lakes, and wide rivers.
    ///
    /// Use this function if you import the style instead of loading it directly. See ``StyleImport`` for more information.
    ///
    ///
    /// - Parameters:
    ///   - importId: The import identifier of the imported style that defines the featureset.
    public static func standardWater(importId: String) -> FeaturesetDescriptor {
        FeaturesetDescriptor<FeaturesetFeature>.featureset("water", importId: importId).converted()
    }
}
