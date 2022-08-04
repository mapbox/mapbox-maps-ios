import Foundation
@testable import MapboxMaps

final class MockTimeProvider: TimeProvider {
    let currentStub = Stub<Void, TimeInterval>(defaultReturnValue: 0)
    var current: TimeInterval { currentStub.call() }
}
