import XCTest
import MapboxMaps

class DeallocationObserver {
    var observe: () -> Void
    deinit {
        let observation = observe
        DispatchQueue.main.async {
            observation()
        }
    }
    init(_ observe: @escaping () -> Void) {
        self.observe = observe
    }
}
