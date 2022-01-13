#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

@UIApplicationMain
public class AppDelegate: UIResponder, UIApplicationDelegate {
    public var window: UIWindow?
}
