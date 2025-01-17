import SwiftUI

/// Provides access to the underlying ``MapView`` map via proxy.
///
/// Wrap ``Map-swift.struct`` into a map reader to get access to the underlying map implementation.
///
/// ```swift
/// var body: some View {
///     MapReader { proxy in
///         Map()
///             .onAppear {
///                 configureUnderlyingMap(proxy.map)
///             }
///     }
/// }
/// ```
public struct MapReader<Content: View>: View {
    public typealias ContentProvider = (MapProxy) -> Content
    @State private var mapViewProvider = MapViewProvider()
    public var content: ContentProvider

    public init(content: @escaping ContentProvider) {
        self.content = content
    }

    public var body: some View {
        content(MapProxy(provider: mapViewProvider))
            .environment(\.mapViewProvider, mapViewProvider)
    }
}

internal struct MapViewProviderKey: EnvironmentKey {
    static var defaultValue: MapViewProvider?
}

extension EnvironmentValues {
    var mapViewProvider: MapViewProvider? {
        get { self[MapViewProviderKey.self] }
        set { self[MapViewProviderKey.self] = newValue }
    }
}

final class MapViewProvider {
    weak var mapView: MapView?
}
