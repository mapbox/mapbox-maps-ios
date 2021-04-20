import MapboxCoreMaps

extension Size {
    internal convenience init(_ cgSize: CGSize) {
        self.init(width: Float(cgSize.width), height: Float(cgSize.height))
    }
}

extension CGSize {
    internal init(_ size: Size) {
        self.init(width: CGFloat(size.width), height: CGFloat(size.height))
    }
}
