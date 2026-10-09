import Foundation
internal import MapboxCommon_Private

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
    /// If a style package with the given id already exists, calling this method
    /// again with the same `styleURI` refreshes it. You can pass explicit
    /// `StylePackLoadOptions`, including the same options used for the original
    /// download. The style pack is updated with any option values you provide:
    /// missing resources are loaded and expired resources are updated.
    ///
    /// You can refresh with either your original `StylePackLoadOptions` or an
    /// empty instance (for example `StylePackLoadOptions(glyphsRasterizationMode: nil)`).
    /// Both load missing resources and update expired ones. The `loadOptions`
    /// argument is still required.
    ///
    /// Set `StylePackLoadOptions.acceptExpired` to `false` (the default) so
    /// outdated resources are refreshed. If `acceptExpired` is `true`, existing
    /// outdated resources are not refreshed.
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
                              progress: (@Sendable (StylePackLoadProgress) -> Void)? = nil,
                              completion: @escaping @Sendable (Result<StylePack, Error>) -> Void) -> Cancelable {
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
    public func allStylePacks(completion: @escaping @Sendable (Result<[StylePack], Error>) -> Void) {
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
    public func stylePack(for styleURI: StyleURI, completion: @escaping @Sendable (Result<StylePack, Error>) -> Void) {
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
                                  completion: @escaping @Sendable (Result<AnyObject, Error>) -> Void) {
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
    public func removeStylePack(for styleURI: StyleURI, completion: (@Sendable (Result<StylePack, Error>) -> Void)? = nil) {
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
