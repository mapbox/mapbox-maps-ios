import UIKit

extension UIWindow {
    /// A window in the host app's scene. A bare `UIWindow()` gets no scene in a scene-based app.
    static func makeForTests(frame: CGRect = .zero) -> UIWindow {
        guard let scene = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first else {
            return UIWindow(frame: frame)
        }
        let window = UIWindow(windowScene: scene)
        window.frame = frame
        return window
    }
}
