import XCTest
@testable import MapboxMaps
import Foundation

final class MockAttributionDataSource: AttributionDataSource {
    var attributions: [MapboxMaps.Attribution] = []
    func getAttributions() -> [MapboxMaps.Attribution] {
        attributions
    }
}
