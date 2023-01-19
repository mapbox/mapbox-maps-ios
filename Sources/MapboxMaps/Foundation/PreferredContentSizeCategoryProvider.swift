import Foundation
import UIKit

/// A protocol to get the preferred font sizing.
///
/// Use this protocol when the map view is used in non-application target(e.g. application extension target).
public protocol PreferredContentSizeCategoryProvider {
    
    /// The font sizing option preferred by the user.
    var preferredContentSizeCategory: UIContentSizeCategory { get }
}

@available(iOSApplicationExtension, unavailable)
internal final class UIApplicationPreferredContentSizeCategoryProvider: PreferredContentSizeCategoryProvider {
    private let application: UIApplicationProtocol
    
    init(application: UIApplicationProtocol = UIApplication.shared) {
        self.application = application
    }
    
    var preferredContentSizeCategory: UIContentSizeCategory {
        application.preferredContentSizeCategory
    }
}

internal final class DefaultPreferredContentSizeCategoryProvider: PreferredContentSizeCategoryProvider {
    var preferredContentSizeCategory: UIContentSizeCategory { .unspecified }
}
