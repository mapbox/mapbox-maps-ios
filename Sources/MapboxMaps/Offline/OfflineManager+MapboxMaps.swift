import Foundation
@_implementationOnly import MapboxCommon_Private

extension OfflineManager {

    /// Loads a new style package or updates the existing one.
    ///
    /// - Parameters:
    ///   - styleURI: The URI of the style package's associated style
    ///   - loadOptions: The style package load options.
    ///   - progress: Invoked multiple times to report progress of the loading
    ///         operation.
    ///   - completion: Invoked only once upon success, failure, or cancelation
    ///         of the loading operation. Any `Result` error could be of type
    ///         `StylePackError`.
    /// - Returns: Returns a Cancelable object to cancel the load request
    ///
    /// If a style package with the given id already exists, it is updated with
    /// the values provided to the given load options. The missing resources get
    /// loaded and the expired resources get updated.
    ///
    /// If there no values provided to the given load options, the existing
    /// style package gets refreshed: the missing resources get loaded and the
    /// expired resources get updated.
    ///
    /// A failed load request can be reattempted with another `loadStylePack()` call.
    ///
    /// If the style cannot be fetched for any reason, the load request is terminated.
    /// If the style is fetched but loading some of the style package resources
    /// fails, the load request proceeds trying to load the remaining style package
    /// resources.
    ///
    /// - Important:
    ///     By default, users may download up to 750 tile packs for offline
    ///     use across all regions. If the limit is hit, any loadRegion call
    ///     will fail until excess regions are deleted. This limit is subject
    ///     to change. Please contact Mapbox if you require a higher limit.
    ///     Additional charges may apply.
    @discardableResult
    public func loadStylePack(for styleURI: StyleURI,
                              loadOptions: StylePackLoadOptions,
                              progress: StylePackLoadProgressCallback? = nil,
                              completion: @escaping (Result<StylePack, Error>) -> Void) -> Cancelable {
        if let progress = progress {
            return __loadStylePack(forStyleURI: styleURI.rawValue,
                                   loadOptions: loadOptions,
                                   onProgress: progress,
                                   onFinished: offlineManagerClosureAdapter(for: completion, type: StylePack.self))
        }
        // An overloaded version that does not report progess of the loading operation.
        else {
            return __loadStylePack(forStyleURI: styleURI.rawValue,
                                   loadOptions: loadOptions,
                                   onFinished: offlineManagerClosureAdapter(for: completion, type: StylePack.self))
        }
    }

    /// Fetch an array of the existing style packages.
    ///
    /// - Parameter completion: The result callback. Any `Result` error should
    ///         be of type `StylePackError`.
    ///
    /// - Note:
    ///     The user-provided callbacks will be executed on a worker thread; it
    ///     is the responsibility of the user to dispatch to a user-controlled
    ///     thread.
    public func allStylePacks(completion: @escaping (Result<[StylePack], Error>) -> Void) {
        __getAllStylePacks(forCallback: offlineManagerClosureAdapter(for: completion, type: NSArray.self))
    }

    /// Returns a style package by its id.
    ///
    /// - Parameters:
    ///   - styleURI: The URI of the style package's associated style
    ///   - completion: The result callback. Any `Result` error could be of type
    ///         `StylePackError`.
    ///
    /// - Note:
    ///     The user-provided callbacks will be executed on a worker thread; it
    ///     is the responsibility of the user to dispatch to a user-controlled
    ///     thread.
    public func stylePack(for styleURI: StyleURI, completion: @escaping (Result<StylePack, Error>) -> Void) {
        __getStylePack(forStyleURI: styleURI.rawValue,
                       callback: offlineManagerClosureAdapter(for: completion, type: StylePack.self))
    }

    /// Returns a style package's associated metadata.
    ///
    /// - Parameters:
    ///   - styleURI: The URI of the style package's associated style
    ///   - completion: The result callback. Any `Result` error could be of type
    ///         `StylePackError`.
    ///
    /// The style package's associated metadata that a user previously set.
    public func stylePackMetadata(for styleURI: StyleURI,
                                  completion: @escaping (Result<AnyObject, Error>) -> Void) {
        __getStylePackMetadata(forStyleURI: styleURI.rawValue,
                               callback: offlineManagerClosureAdapter(for: completion, type: AnyObject.self))
    }

    /// Removes a style package.
    ///
    /// - Parameter styleURI: The URI of the style package's associated style
    /// - Parameter completion: The result callback. Any `Result` error could be of type ``StylePackError-swift.enum``.
    ///
    /// Removes a style package from the existing packages list. The actual
    /// resources eviction might be deferred. All pending loading operations for
    /// the style package with the given id will fail with Canceled error.
    public func removeStylePack(for styleURI: StyleURI, completion: ((Result<StylePack, Error>) -> Void)? = nil) {
        if let completion {
            __removeStylePack(forStyleURI: styleURI.rawValue, callback: offlineManagerClosureAdapter(for: completion, type: StylePack.self))
        } else {
            removeStylePack(forStyleURI: styleURI.rawValue)
        }
    }
}

private func offlineManagerClosureAdapter<T, ObjCType>(
    for closure: @escaping (Result<T, Error>) -> Void,
    type: ObjCType.Type) -> ((Expected<ObjCType, StylePackError.CoreErrorType>?) -> Void) where ObjCType: AnyObject {
    return coreAPIClosureAdapter(for: closure, type: type, concreteErrorType: StylePackError.self)
}
