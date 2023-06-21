import Foundation
@testable import MapboxMaps

final class MockInterfaceOrientationProvider: InterfaceOrientationProvider {
    @Stubbed var interfaceOrientation: UIInterfaceOrientation = .unknown
    @TestSignal var onInterfaceOrientationChange: Signal<UIInterfaceOrientation>
}
