// This file is generated.

/// A point of interest.
///
/// Use ``FeaturesetDescriptor/standardPoi`` descriptor to handle interactions on Poi features:
///
/// ```swift
/// mapboxMap.addInteraction(TapInteraction(.standardPoi) { feature, ctx in
///     // Handle the tapped feature here
/// })
/// ```
public final class StandardPoiFeature: FeaturesetFeatureType {
    /// The state that can be set for the feature.
    ///
    /// Each feature of this class can receive the following states: `hide`.
    /// Use ``FeatureState`` (SwiftUI) or ``MapboxMap/setFeatureState(_:state:callback:)`` (UIKit) to set the states:
    ///
    /// ```swift
    /// // SwiftUI
    /// Map {
    ///     FeatureState(aPoiFeature, state: .init(hide: true))
    /// }
    ///
    /// // UIKit:
    /// mapboxMap.setFeatureState(aPoiFeature, state: .init(hide: true))
    /// ```
    public struct State: Codable, Equatable {
        /// When `true`, hides the icon and text. Use this state when displaying a custom annotation on top.
        public var hide: Bool?

        /// Creates the state.
        ///
        /// - Parameters:
        ///   - hide: When `true`, hides the icon and text. Use this state when displaying a custom annotation on top.
        public init(hide: Bool? = nil) {
            self.hide = hide
        }
    }

    public struct StateKey: CustomStringConvertible {
        public let description: String

        /// When `true`, hides the icon and text. Use this state when displaying a custom annotation on top.
        public static let hide: StateKey = .init(description: "hide")
    }

    /// Name of the point of interest.
    public var name: String? { impl.properties["name"]??.string }

    /// A high-level category, like POI, airport, transit, etc.
    public var group: String? { impl.properties["group"]??.string }

    /// A broad category of point of interest.
    public var `class`: String? { impl.properties["class"]??.string }

    /// An icon identifier, designed to assign icons using the Maki icon project or other icons that follow the same naming scheme.
    public var maki: String? { impl.properties["maki"]??.string }

    /// Mode of transport served by a stop/station. Expected to be null for non-transit points of interest.
    public var transitMode: String? { impl.properties["transit_mode"]??.string }

    /// A type of transit stop. Expected to be null for non-transit points of interest.
    public var transitStopType: String? { impl.properties["transit_stop_type"]??.string }

    /// A rail station network identifier that is part of specific local or regional transit systems. Expected to be null for non-transit points of interest.
    public var transitNetwork: String? { impl.properties["transit_network"]??.string }

    /// A short identifier code of the airport. Expected to be null for non-airport points of interest
    public var airportRef: String? { impl.properties["airport_ref"]??.string }

    private let impl: FeaturesetFeature

    /// An identifier of the feature.
    ///
    /// The identifier can be `nil` if the underlying source doesn't have identifiers for features.
    /// In this case it's impossible to set a feature state for an individual feature.
    public var id: FeaturesetFeatureId? { impl.id }

    /// A featureset descriptor denoting a featureset this feature belongs to.
    public var featureset: FeaturesetDescriptor<StandardPoiFeature> { impl.featureset.converted() }

    /// A feature state.
    ///
    /// This is a **snapshot** of the state that the feature had when it was interacted with.
    /// To update and read the original state, use ``MapboxMap/setFeatureState(_:state:callback:)`` and ``MapboxMap/getFeatureState(_:callback:)``.
    private(set) public lazy var state: State = { impl.typedState(default: State()) }()

    /// A feature geometry.
    public var geometry: Geometry { impl.geometry }

    /// Feature properties in JSON format.
    public var properties: JSONObject { impl.properties }

    /// POI coordinate.
    public let coordinate: CLLocationCoordinate2D

    /// Converts a generic feature to the typed one.
    ///
    /// - Parameters:
    ///    - other: A generic feature.
    public init?(from other: FeaturesetFeature) {
        guard let coordinate = other.geometry.point?.coordinates else { return nil }
        self.coordinate = coordinate
        self.impl = other
    }
}

extension FeaturesetDescriptor where FeatureType == StandardPoiFeature {
    /// A point of interest.
    public static var standardPoi: FeaturesetDescriptor {
       FeaturesetDescriptor<FeaturesetFeature>.featureset("poi").converted()
    }

    /// A point of interest.
    ///
    /// Use this function if you import the style instead of loading it directly. See ``StyleImport`` for more information.
    ///
    ///
    /// - Parameters:
    ///   - importId: The import identifier of the imported style that defines the featureset.
    public static func standardPoi(importId: String) -> FeaturesetDescriptor {
        FeaturesetDescriptor<FeaturesetFeature>.featureset("poi", importId: importId).converted()
    }
}
