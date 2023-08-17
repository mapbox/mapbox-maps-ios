import UIKit
@testable import MapboxMaps

final class MockGestureManager: GestureManagerProtocol {
    @Stubbed var options = GestureOptions()

    var singleTapGestureRecognizerMock = MockGestureRecognizer()
    var singleTapGestureRecognizer: UIGestureRecognizer {
        singleTapGestureRecognizerMock
    }
}
