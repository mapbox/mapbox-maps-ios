import UIKit
import CoreLocation

// Protocol to allow for approximate equality
protocol ApproximatelyEquatable: Equatable {
    
    /// Returns true if a value is approximately equal to another value
    /// - Parameters:
    ///   - other: value to compare to
    ///   - margin: the marginal difference allowed for a value to be approximately equal to another
    func isApproximatelyEqual(to other: Self, within margin: Self) -> Bool
    
    /// Returns true if a value is NOT approximately equal to another value
    /// - Parameters:
    ///   - other: value to compare to
    ///   - margin: the marginal difference allowed for a value to be approximately equal to another
    func isNotApproximatelyEqual(to other: Self, within margin: Self) -> Bool
}


extension CGFloat: ApproximatelyEquatable {
    func isApproximatelyEqual(to other: CGFloat, within margin: CGFloat = 1e-7) -> Bool {
        (self == other) || abs(self - other) < margin
    }
    
    func isNotApproximatelyEqual(to other: CGFloat, within margin: CGFloat = 1e-7) -> Bool {
        !isApproximatelyEqual(to: other, within: margin)
    }
}

extension Double: ApproximatelyEquatable {
    func isApproximatelyEqual(to other: Double, within margin: Double = 1e-7) -> Bool {
        (self == other) || abs(self - other) < margin
    }
    
    func isNotApproximatelyEqual(to other: Double, within margin: Double = 1e-7) -> Bool {
        !isApproximatelyEqual(to: other, within: margin)
    }
}

extension UIEdgeInsets: ApproximatelyEquatable {
    func isApproximatelyEqual(to other: UIEdgeInsets, within margin: UIEdgeInsets = UIEdgeInsets(top: 1e-5, left: 1e-5, bottom: 1e-5, right: 1e-5)) -> Bool {
        return self.top.isApproximatelyEqual(to: other.top, within: margin.top)
            && self.bottom.isApproximatelyEqual(to: other.bottom, within: margin.bottom)
            && self.left.isApproximatelyEqual(to: other.left, within: margin.left)
            && self.right.isApproximatelyEqual(to: other.right, within: margin.right)
    }
    
    func isNotApproximatelyEqual(to other: UIEdgeInsets, within margin: UIEdgeInsets = UIEdgeInsets(top: 1e-5, left: 1e-5, bottom: 1e-5, right: 1e-5)) -> Bool {
        !isApproximatelyEqual(to: other, within: margin)
    }
}

extension CLLocationCoordinate2D: ApproximatelyEquatable {
    func isApproximatelyEqual(to other: CLLocationCoordinate2D, within margin: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 1e-10, longitude: 1e-10)) -> Bool {
        
        if self == other {
            return true // short-circuit if equal
        }
        
        let latitudeDiff = abs(self.latitude - other.latitude)
        let longitudeDiff = abs(self.longitude - other.longitude)
        
        return (latitudeDiff < margin.latitude) && (longitudeDiff < margin.longitude)
        
    }
    
    func isNotApproximatelyEqual(to other: CLLocationCoordinate2D, within margin: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 1e-10, longitude: 1e-10)) -> Bool {
        !isApproximatelyEqual(to: other, within: margin)
    }
}
