import XCTest
@testable import MapboxMaps
import Foundation

final class MockAttributionDataSource: AttributionDataSource {

    let attributionsStub = Stub<Void, [Attribution]>(defaultReturnValue: [])
    func attributions() -> [Attribution] {
        attributionsStub.call()
    }
}
