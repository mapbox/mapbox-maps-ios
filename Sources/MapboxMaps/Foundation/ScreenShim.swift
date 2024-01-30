import UIKit

enum ScreenShim {
    static var nativeScale: CGFloat {
#if swift(>=5.9) && os(visionOS)
        return UITraitCollection.current.displayScale
#else
        return UIScreen.main.nativeScale
#endif
    }

    static var scale: CGFloat {
#if swift(>=5.9) && os(visionOS)
        return UITraitCollection.current.displayScale
#else
        return UIScreen.main.scale
#endif
    }
}
