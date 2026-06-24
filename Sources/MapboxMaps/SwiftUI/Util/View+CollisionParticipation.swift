import SwiftUI

struct CollisionBoxPreferenceKey: PreferenceKey {
    static var defaultValue: [CGRect] = []
    static func reduce(value: inout [CGRect], nextValue: () -> [CGRect]) {
        value.append(contentsOf: nextValue())
    }
}

/// Reads the coordinate space of the annotation root and provides it to collision participants.
struct CollisionBoxCoordinateSpaceModifier: ViewModifier {
    @State private var coordinateSpaceName = UUID()

    let onCollisionBoxesChanged: ([CGRect]) -> Void

    func body(content: Content) -> some View {
        content
            .coordinateSpace(name: coordinateSpaceName)
            .environment(\.collisionBoxCoordinateSpaceName, coordinateSpaceName)
            .onPreferenceChange(CollisionBoxPreferenceKey.self, perform: onCollisionBoxesChanged)
    }
}

private struct CollisionBoxCoordinateSpaceKey: EnvironmentKey {
    static let defaultValue: UUID? = nil
}

extension EnvironmentValues {
    var collisionBoxCoordinateSpaceName: UUID? {
        get { self[CollisionBoxCoordinateSpaceKey.self] }
        set { self[CollisionBoxCoordinateSpaceKey.self] = newValue }
    }
}

extension View {
    /// Marks this view as a collision box for the enclosing ``MapViewAnnotation``.
    ///
    /// When at least one subview is marked, only marked subviews' frames are used
    /// as collision boxes. When none are marked, the full annotation bounds are used.
    @_spi(Experimental)
    public func mbxCollisionBox(_ enabled: Bool = true) -> some View {
        modifier(CollisionParticipationModifier(participates: enabled))
    }
}

private struct CollisionParticipationModifier: ViewModifier {
    let participates: Bool
    @Environment(\.collisionBoxCoordinateSpaceName) private var coordinateSpaceName

    func body(content: Content) -> some View {
        content.background(
            GeometryReader { proxy in
                Color.clear.preference(
                    key: CollisionBoxPreferenceKey.self,
                    value: participates ? [resolvedFrame(proxy)] : [])
            }
        )
    }

    private func resolvedFrame(_ proxy: GeometryProxy) -> CGRect {
        guard let coordinateSpaceName else { return proxy.frame(in: .global) }
        return proxy.frame(in: .named(coordinateSpaceName))
    }
}
