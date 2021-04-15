import Foundation

extension MapboxCoreMaps.OfflineManager {
   /**
    * @brief Loads a new style package or updates the existing one.
    *
    * If a style package with the given id already exists, it gets updated with
    * the values provided to the given load options. The missing resources get
    * loaded and the expired resources get updated.
    *
    * If there no values provided to the given load options, the existing style package
    * gets refreshed: the missing resources get loaded and the expired resources get updated.
    *
    * A failed load request can be reattempted with another loadStylePack() call.
    *
    * If the style cannot be fetched for any reason, the load request is terminated.
    * If the style is fetched but loading some of the style package resources fails,
    * the load request proceeds trying to load the remaining style package resources.
    *
    * @param styleURL The URL of the style package's associated style
    * @param loadOptions The style package load options.
    * @param onProgress Invoked multiple times to report progess of the loading operation.
    * @param onFinished Invoked only once upon success, failure, or cancelation of the loading operation.
    * @return Returns a Cancelable object to cancel the load request
    */
    // TODO: docs    
    @discardableResult
    public func loadStylePack(for styleURI: StyleURI,
                              loadOptions: StylePackLoadOptions,
                              progress: StylePackLoadProgressCallback? = nil,
                              completion: @escaping (Result<StylePack, StylePackError>) -> Void)
    -> Cancelable {
        if let progress = progress {
            return __loadStylePack(forStyleURL: styleURI.rawValue.path,
                         loadOptions: loadOptions,
                         onProgress: progress,
                         onFinished: coreAPIClosureAdapter(for: completion, type: StylePack.self))
        }
        // An overloaded version that does not report progess of the loading operation.
        else {
            return __loadStylePack(forStyleURL: styleURI.rawValue.path,
                             loadOptions: loadOptions,
                             onFinished: coreAPIClosureAdapter(for: completion, type: StylePack.self))
        }
    }

   /**
    * @brief Returns a list of the existing style packages.
    *
    * Note: The user-provided callbacks will be executed on a worker thread;
    * it is the responsibility of the user to dispatch to a user-controlled thread.
    *
    * @param callback The result callback.
    */
    // TODO: docs
    public func allStylePacks(completion: @escaping (Result<[StylePack], StylePackError>) -> Void) {
        __getAllStylePacks(forCallback: coreAPIClosureAdapter(for: completion, type: NSArray.self))
    }

   /**
    * @brief Returns a style package by its id.
    *
    * Note: The user-provided callbacks will be executed on a worker thread;
    * it is the responsibility of the user to dispatch to a user-controlled thread.
    *
    * @param styleURL The URL of the style package's associated style
    * @param callback The result callback.
    */
    // TODO: docs
    public func stylePack(for styleURI: StyleURI, completion: @escaping (Result<StylePack, StylePackError>) -> Void) {
        __getStylePack(forStyleURL: styleURI.rawValue.path,
                       callback: coreAPIClosureAdapter(for: completion, type: StylePack.self))
    }

   /**
    * @brief Returns a style package's associated metadata
    *
    * The style package's associated metadata that a user previously set.
    *
    * @param styleURL The URL of the style package's associated style
    * @param callback The result callback.
    */
    // TODO: docs
    public func stylePackMetadata(for styleURI: StyleURI,
                                  completion: @escaping (Result<AnyObject, StylePackError>) -> Void) {
        __getStylePackMetadata(forStyleURL: styleURI.rawValue.path,
                               callback: coreAPIClosureAdapter(for: completion, type: AnyObject.self))
    }

    /**
    * @brief Removes a style package.
    *
    * Removes a style package from the existing packages list. The actual resources
    * eviction might be deferred. All pending loading operations for the style package
    * with the given id will fail with Canceled error.
    *
    * @param styleURL The URL of the style package's associated style
    */
    // TODO: docs
    public func removeStylePack(for styleURI: StyleURI) {
        removeStylePack(forStyleURL: styleURI.rawValue.path)
    }
}
