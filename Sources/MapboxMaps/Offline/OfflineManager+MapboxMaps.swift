import Foundation

extension MapboxCoreMaps.OfflineManager {
    /// Loads a new style package or updates the existing one.
    ///
    /// - Parameters:
    ///   - styleURI: The URI of the style package's associated style
    ///   - loadOptions: The style package load options.
    ///   - progress: Invoked multiple times to report progress of the loading
    ///         operation.
    ///   - completion: Invoked only once upon success, failure, or cancelation
    ///         of the loading operation.
    /// - Returns: Returns a Cancelable object to cancel the load request
    ///
    /// If a style package with the given id already exists, its updated with
    /// the values provided to the given load options. The missing resources get
    /// loaded and the expired resources get updated.
    ///
    /// If there no values provided to the given load options, the existing
    /// style package gets refreshed: the missing resources get loaded and the
    /// expired resources get updated.
    ///
    /// A failed load request can be reattempted with another loadStylePack() call.
    ///
    /// If the style cannot be fetched for any reason, the load request is terminated.
    /// If the style is fetched but loading some of the style package resources
    /// fails, the load request proceeds trying to load the remaining style package
    /// resources.
    @discardableResult
    public func loadStylePack(for styleURI: StyleURI,
                              loadOptions: StylePackLoadOptions,
                              progress: StylePackLoadProgressCallback? = nil,
                              completion: @escaping (Result<StylePack, StylePackError>) -> Void)
    -> Cancelable {
        if let progress = progress {
            return __loadStylePack(forStyleURI: styleURI.rawValue.absoluteString,
                         loadOptions: loadOptions,
                         onProgress: progress,
                         onFinished: coreAPIClosureAdapter(for: completion, type: StylePack.self))
        }
        // An overloaded version that does not report progess of the loading operation.
        else {
            return __loadStylePack(forStyleURI: styleURI.rawValue.absoluteString,
                             loadOptions: loadOptions,
                             onFinished: coreAPIClosureAdapter(for: completion, type: StylePack.self))
        }
    }

    /// Fetch an array of the existing style packages.
    ///
    /// - Parameter completion: The result callback.
    ///
    /// - Note:
    ///     The user-provided callbacks will be executed on a worker thread; it
    ///     is the responsibility of the user to dispatch to a user-controlled
    ///     thread.
    public func allStylePacks(completion: @escaping (Result<[StylePack], StylePackError>) -> Void) {
        __getAllStylePacks(forCallback: coreAPIClosureAdapter(for: completion, type: NSArray.self))
    }

    /// Returns a style package by its id.
    ///
    /// - Parameters:
    ///   - styleURI: The URI of the style package's associated style
    ///   - completion: The result callback.
    ///
    /// - Note:
    ///     The user-provided callbacks will be executed on a worker thread; it
    ///     is the responsibility of the user to dispatch to a user-controlled
    ///     thread.
    public func stylePack(for styleURI: StyleURI, completion: @escaping (Result<StylePack, StylePackError>) -> Void) {
        __getStylePack(forStyleURI: styleURI.rawValue.path,
                       callback: coreAPIClosureAdapter(for: completion, type: StylePack.self))
    }

    /// Returns a style package's associated metadata.
    ///
    /// - Parameters:
    ///   - styleURI: The URI of the style package's associated style
    ///   - completion: The result callback.
    ///
    /// The style package's associated metadata that a user previously set.
    public func stylePackMetadata(for styleURI: StyleURI,
                                  completion: @escaping (Result<AnyObject, StylePackError>) -> Void) {
        __getStylePackMetadata(forStyleURI: styleURI.rawValue.absoluteString,
                               callback: coreAPIClosureAdapter(for: completion, type: AnyObject.self))
    }

    /// Removes a style package.
    ///
    /// - Parameter styleURI: The URI of the style package's associated style
    ///
    /// Removes a style package from the existing packages list. The actual
    /// resources eviction might be deferred. All pending loading operations for
    /// the style package with the given id will fail with Canceled error.
    public func removeStylePack(for styleURI: StyleURI) {
        removeStylePack(forStyleURI: styleURI.rawValue.absoluteString)
    }
}
