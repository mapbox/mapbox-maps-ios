import Foundation
import UIKit
@testable import MapboxMaps

final class MockUIDevice: UIDeviceProtocol {
    @Stubbed var orientation: UIDeviceOrientation = .unknown

    let beginGeneratingDeviceOrientationNotificationsStub = Stub<Void, Void>()
    func beginGeneratingDeviceOrientationNotifications() {
        beginGeneratingDeviceOrientationNotificationsStub.call()
    }

    let endGeneratingDeviceOrientationNotificationsStub = Stub<Void, Void>()
    func endGeneratingDeviceOrientationNotifications() {
        endGeneratingDeviceOrientationNotificationsStub.call()
    }
}
