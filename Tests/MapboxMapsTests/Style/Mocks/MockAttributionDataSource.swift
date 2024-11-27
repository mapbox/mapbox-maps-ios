import XCTest
@testable import MapboxMaps
import Foundation

final class MockAttributionDataSource: AttributionDataSource {
    var attributions: [MapboxMaps.Attribution] = []
    let loadAttributionsStub = Stub<(([Attribution]) -> Void), Void>()
    func loadAttributions(completion: @escaping ([MapboxMaps.Attribution]) -> Void) {
        completion(attributions)
    }
}
