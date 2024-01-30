import UIKit

extension UIApplication {
    var keyWindowForTests: UIWindow? {
#if swift(>=5.9) && os(visionOS)
        return connectedScenes
                .compactMap({$0 as? UIWindowScene})
                .first?.windows
                .filter(\.isKeyWindow).first
#else
        return keyWindow
#endif
    }
}
