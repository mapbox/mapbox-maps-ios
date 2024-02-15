import Foundation

@_documentation(visibility: internal)
extension StyleManager {
    /// :nodoc:
    @available(*, deprecated, renamed: "styleURI")
    public var uri: StyleURI? {
        get { styleURI }
        set { styleURI = newValue }
    }

    /// :nodoc:
    @available(*, deprecated, renamed: "styleJSON")
    public var JSON: String {
        get { styleJSON }
        set { styleJSON = newValue }
    }

    /// :nodoc:
    @available(*, deprecated, renamed: "styleTransition")
    public var transition: TransitionOptions {
        get { styleTransition }
        set { styleTransition = newValue }
    }

    /// :nodoc:
    @available(*, deprecated, renamed: "isStyleLoaded")
    public var isLoaded: Bool { isStyleLoaded }

    /// :nodoc:
    @available(*, deprecated, renamed: "styleDefaultCamera")
    public var defaultCamera: CameraOptions { styleDefaultCamera }
}
