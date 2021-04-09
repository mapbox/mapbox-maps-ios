import Foundation

extension CGSize {
    internal var mbmSize: Size {
        return Size(width: Float(width), height: Float(height))
    }
}
