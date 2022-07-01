import UIKit
import MapboxMaps

extension UIViewController {
    public class var rootController: UIViewController? {
        // https://stackoverflow.com/a/58031897/887401
        UIApplication
        .shared
        .connectedScenes
        .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
        .first(where: \.isKeyWindow)?
        .rootViewController
    }

    func findMapView() -> MapView? {
        loadViewIfNeeded()
        return view.subviews.lazy
            .compactMap { $0 as? MapView }
            .first
    }
}
