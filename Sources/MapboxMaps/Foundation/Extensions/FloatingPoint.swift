import Foundation

extension FloatingPoint {
    internal func wrapped(to range: Range<Self>) -> Self {
        let d = range.upperBound - range.lowerBound
        return fmod((fmod((self - range.lowerBound), d) + d), d) + range.lowerBound
    }
}
