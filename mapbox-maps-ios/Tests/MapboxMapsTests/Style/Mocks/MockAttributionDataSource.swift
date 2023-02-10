import XCTest
@testable import MapboxMaps
import Foundation

final class MockAttributionDataSource: AttributionDataSource {
    let loadAttributionsStub = Stub<(([Attribution]) -> Void), Void>()
    func loadAttributions(completion: @escaping ([MapboxMaps.Attribution]) -> Void) {
        loadAttributionsStub.call(with: completion)
        completion([])
    }
}
