@testable import MapboxMaps

struct LocationChangeHandlerParams: Equatable {
    var fromLocation: CGPoint
    var toLocation: CGPoint
}

typealias MockLocationChangeHandler = Stub<LocationChangeHandlerParams, Void>

extension MockLocationChangeHandler {
    func call(withFromLocation fromLocation: CGPoint, toLocation: CGPoint) {
        call(with: .init(fromLocation: fromLocation, toLocation: toLocation))
    }
}
