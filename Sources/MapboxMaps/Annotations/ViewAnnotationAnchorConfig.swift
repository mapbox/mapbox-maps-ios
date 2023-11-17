import MapboxCoreMaps

extension ViewAnnotationAnchorConfig {
    /// Creates an annotation anchor config.
    ///
    /// - Parameters:
    ///   - anchor: Anchor direction.
    ///   - offsetX: Horizontal offset. Positive value moves view annotation to the right while negative moves it to the left.
    ///   - offsetY: Vertical offset. Positive value moves view annotation to the top while negative moves it to the bottom.
    public convenience init(anchor: ViewAnnotationAnchor, offsetX: CGFloat = 0, offsetY: CGFloat = 0) {
        self.init(__anchor: anchor, offsetX: offsetX, offsetY: offsetY)
    }
}

extension Array where Element == ViewAnnotationAnchorConfig {
    /// Creates an annotation configs list that allows anchor to be presented in all directions.
    public static let all = [ViewAnnotationAnchor.topLeft, .top, .topRight, .left, .right, .bottomLeft, .bottom, .bottomRight].map {
        ViewAnnotationAnchorConfig(anchor: $0)
    }

    /// Creates an anchor config that allow only center position for anchor, meaning there will be no anchor.
    /// This is the default option for view annotations created with `ViewAnnotation`.
    public static let `center` = [ViewAnnotationAnchorConfig(anchor: .center)]
}
