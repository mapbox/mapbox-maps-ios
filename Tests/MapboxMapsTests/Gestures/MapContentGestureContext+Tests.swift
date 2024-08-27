@testable import MapboxMaps

extension InteractionContext {
    static let zero = InteractionContext(point: .init(x: 0, y: 0), coordinate: .init(latitude: 0, longitude: 0))
}
