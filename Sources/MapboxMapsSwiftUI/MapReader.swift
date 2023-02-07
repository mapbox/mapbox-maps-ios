import SwiftUI

/// Provides access to underlying Mapbox map via proxy.
/// This is for access to full-featured Mapbox API from SwiftUI.
///
///     var body: some View {
///         MapboxViewReader { proxy in
///             MapboxView().onTapGesture {
///                 updateStyle(proxy.style)
///             }
///         }
///     }
@_spi(Experimental)
@available(iOS 13.0, *)
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

@available(iOS 13.0, *)
internal struct MapViewProviderKey: EnvironmentKey {
    static var defaultValue: MapViewProvider?
}

@available(iOS 13.0, *)
extension EnvironmentValues {
    var mapViewProvider: MapViewProvider? {
        get { self[MapViewProviderKey.self] }
        set { self[MapViewProviderKey.self] = newValue }
    }
}

final class MapViewProvider {
    weak var mapView: MapView?
}
