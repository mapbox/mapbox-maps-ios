import Foundation
@testable import MapboxMaps
import UIKit

final class MockInterfaceOrientationProvider: InterfaceOrientationProvider {
    var onInterfaceOrientationChange: Signal<UIInterfaceOrientation> { $interfaceOrientation }

    @TestPublished
    var interfaceOrientation: UIInterfaceOrientation = .unknown
}
