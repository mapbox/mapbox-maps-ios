@testable import MapboxMaps

final class MockGestureManager: GestureManagerProtocol {
    @Stubbed var options = GestureOptions()
    var singleTapGestureRecognizer: UIGestureRecognizer {
        singleTapGestureRecognizerMock
    }
    var singleTapGestureRecognizerMock = MockGestureRecognizer()
}
