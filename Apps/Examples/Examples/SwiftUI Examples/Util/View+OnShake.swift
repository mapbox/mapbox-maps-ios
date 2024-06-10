import SwiftUI
import UIKit

extension UIWindow {
     open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: deviceDidShake, object: nil)
        }
     }
}

@available(iOS 13.0, *)
struct DeviceShakeViewModifier: ViewModifier {
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: deviceDidShake)) { _ in
                action()
            }
    }
}

@available(iOS 13.0, *)
extension View {
    func onShake(perform action: @escaping () -> Void) -> some View {
        modifier(DeviceShakeViewModifier(action: action))
    }
}

private let deviceDidShake = Notification.Name(rawValue: "deviceDidShake")
