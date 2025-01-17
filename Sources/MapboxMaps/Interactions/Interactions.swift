import Foundation
import MapboxCoreMaps

/// An interaction that can be added to the map.
///
/// To create an interaction use ``TapInteraction`` and ``LongPressInteraction`` implementations.
///
/// See also: ``MapboxMap/addInteraction(_:)``.
@_documentation(visibility: public)
@_spi(Experimental)
public protocol Interaction {
    /// An interaction opaque type.
    @_spi(Internal)
    var impl: InteractionImpl { get }
}

/// A single tap interaction.
///
/// To add interaction, use ``MapboxMap/addInteraction(_:)`` in UIKit, or put it inside the ``Map`` view in SwiftUI.
///
/// ```swift
/// // UIKit
/// map.addInteraction(TapInteraction(.layer("my-layer") { feature, context in
///     // Handle tap on the feature
///     return true // Stops propagation to features below or the map.
/// })
///
/// // SwiftUI
/// Map {
///     TapInteraction(.layer("my-layer") { feature, context in
///         // Handle tap on the feature
///         return true // Stops propagation to features below or the map.
///     }
/// }
/// ```
@_documentation(visibility: public)
@_spi(Experimental)
public struct TapInteraction: Interaction {
    /// Implementation.
    @_spi(Internal)
    public let impl: InteractionImpl

    /// Creates a Tap interaction on the map itself.
    ///
    /// The action will be called last, when no other other interactions targeted to a featureset handled it.
    /// If multiple interactions are added to the map, the last-added one is invoked first.
    ///
    /// If the `action` returns `true` as a default, the interaction stops propagation.
    /// - Parameters:
    ///    - action: Interaction action.
    @_documentation(visibility: public)
    public init(action: @escaping (InteractionContext) -> Bool) {
        self.impl = InteractionImpl(.tap, action)
    }

    /// Creates a Tap interaction on the specified featureset.
    ///
    /// The interactions are handled in the features rendering order.
    /// If one feature handles multiple interactions, the last-added interaction is called first.
    ///
    /// If the `action` returns `true` as a default, the interaction stops propagation.
    ///
    /// - Parameters:
    ///    - featureset: A featureset descriptor denoting the featureset id or layer.
    ///    - filter: An optional filter of features that should trigger the interaction.
    ///    - radius: Radius of a tappable area, in points.
    ///    - action: An interaction action.
    @_documentation(visibility: public)
    public init<T: FeaturesetFeatureType>(
        _ featureset: FeaturesetDescriptor<T>,
        filter: Exp? = nil,
        radius: CGFloat? = nil,
        action: @escaping (T, InteractionContext) -> Bool
    ) {
        self.impl = InteractionImpl(.tap, featureset, filter, radius, action)
    }
}

/// Creates a Long Press interaction.
///
/// To add interaction, use ``MapboxMap/addInteraction(_:)`` in UIKit, or put it inside the ``Map`` view in SwiftUI.
///
/// ```swift
/// // UIKit
/// map.addInteraction(LongPressInteraction(.layer("my-layer") { feature, context in
///     // Handle long press on the feature
///     return true // Stops propagation to features below or the map.
/// })
///
/// // SwiftUI
/// Map {
///     LongPressInteraction(.layer("my-layer") { feature, context in
///         // Handle long press on the feature
///         return true // Stops propagation to features below or the map.
///     }
/// }
/// ```
@_documentation(visibility: public)
@_spi(Experimental)
public struct LongPressInteraction: Interaction {
    @_spi(Internal)
    public let impl: InteractionImpl

    /// Creates a Long Press interaction on the map itself.
    ///
    /// If multiple interactions are added to the map, the last-added one is invoked first.
    ///
    /// The action will be called if no other interaction handled the tap gesture.
    /// - Parameters:
    ///    - action: Interaction action.
    @_documentation(visibility: public)
    public init(action: @escaping (InteractionContext) -> Bool) {
        self.impl = InteractionImpl(.longPress, action)
    }

    /// Creates a Long Press interaction on the specified featureset.
    ///
    /// The interactions are handled in the features rendering order.
    /// If one feature handles multiple interactions, the last-added interaction is called first.
    ///
    /// If the `action` returns `true`, the interaction stops propagation.
    ///
    /// - Parameters:
    ///    - featureset: A featureset descriptor denoting the featureset id or layer.
    ///    - filter: An optional filter of features that should trigger the interaction.
    ///    - radius: Radius of a tappable area, in points.
    ///    - action: An interaction action.
    @_documentation(visibility: public)
    public init<T: FeaturesetFeatureType>(
        _ featureset: FeaturesetDescriptor<T>,
        filter: Exp? = nil,
        radius: CGFloat? = nil,
        action: @escaping (T, InteractionContext) -> Bool
    ) {
        self.impl = InteractionImpl(.longPress, featureset, filter, radius, action)
    }
}

/// For internal use in Annotations.
struct DragInteraction: Interaction {
    let impl: InteractionImpl

    init(
        _ featureset: FeaturesetDescriptor<FeaturesetFeature>,
        filter: Exp? = nil,
        onBegin: @escaping (FeaturesetFeature, InteractionContext) -> Bool,
        onMove: @escaping (InteractionContext) -> Void,
        onEnd: @escaping (InteractionContext) -> Void
    ) {
        self.impl = InteractionImpl(
            featureset: featureset,
            filter: filter,
            type: .drag,
            onBegin: onBegin,
            onChange: onMove,
            onEnd: onEnd)
    }
}

/// An interaction opaque type.
@_spi(Internal)
public struct InteractionImpl {
    /// For some reason, iOS 18 simulator crashes when CoreInteractionType is used in InteractionImpl.
    enum InteractionType {
        case tap
        case longPress
        case drag
        var core: CoreInteractionType {
            switch self {
            case .tap:
                    .click
            case .longPress:
                    .longClick
            case .drag:
                    .drag
            }
        }
    }
    let target: (FeaturesetDescriptor<FeaturesetFeature>, Exp?)?
    let type: InteractionType
    let onBegin: (FeaturesetFeature?, InteractionContext) -> Bool
    let onChange: ((InteractionContext) -> Void)?
    let onEnd: ((InteractionContext) -> Void)?
    let radius: CGFloat?

    init(_ type: InteractionType, _ action: @escaping (InteractionContext) -> Bool) {
        target = nil
        self.type = type
        onBegin = { queriedFeature, context in
            assert(queriedFeature == nil)
            return action(context)
        }
        onChange = nil
        onEnd = nil
        radius = nil
    }

    init(
        featureset: FeaturesetDescriptor<FeaturesetFeature>,
        filter: Exp?,
        radius: CGFloat? = nil,
        type: InteractionType,
        onBegin: @escaping (FeaturesetFeature, InteractionContext) -> Bool,
        onChange: ((InteractionContext) -> Void)? = nil,
        onEnd: ((InteractionContext) -> Void)? = nil
    ) {
        self.type = type
        self.target = (featureset, filter)
        self.onBegin = { feature, context  in
            guard let feature else {
                return false
            }
            return onBegin(feature, context)
        }
        self.onEnd = onEnd
        self.onChange = onChange
        self.radius = radius
    }

    init<T: FeaturesetFeatureType>(
        _ type: InteractionType,
        _ featureset: FeaturesetDescriptor<T>,
        _ filter: Exp? = nil,
        _ radius: CGFloat? = nil,
        _ action: @escaping (T, InteractionContext) -> Bool
    ) {
        self.init(
            featureset: featureset.converted(),
            filter: filter,
            radius: radius,
            type: type,
            onBegin: { feature, context in
                if let converted = T(from: feature) {
                    return action(converted, context)
                }
                return true
            })
    }
}

@_spi(Experimental)
@_documentation(visibility: public)
extension TapInteraction: MapContent, PrimitiveMapContent {
    func visit(_ node: MapContentNode) {
        node.mount(MountedInteraction(interaction: self.impl))
    }
}

@_spi(Experimental)
@_documentation(visibility: public)
extension LongPressInteraction: MapContent, PrimitiveMapContent {
    func visit(_ node: MapContentNode) {
        node.mount(MountedInteraction(interaction: self.impl))
    }
}
