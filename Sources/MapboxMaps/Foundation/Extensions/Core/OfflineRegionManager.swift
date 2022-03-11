@_implementationOnly import MapboxCoreMaps_Private

/// :nodoc:
@available(*, deprecated)
extension OfflineRegionManager {
    public convenience init(resourceOptions: ResourceOptions) {
        self.init(resourceOptions: MapboxCoreMaps.ResourceOptions(resourceOptions))
    }

    public func offlineRegions(completion: @escaping (Result<[OfflineRegion], Error>) -> Void) {
        getOfflineRegions(forCallback: coreAPIClosureAdapter(for: completion,
                                                             type: NSArray.self,
                                                             concreteErrorType: MapError.self))
    }

    public func createOfflineRegion(for geometryDefinition: OfflineRegionGeometryDefinition,
                                    completion: @escaping (Result<OfflineRegion, Error>) -> Void) {
        createOfflineRegion(for: geometryDefinition, callback: coreAPIClosureAdapter(for: completion,
                                                                                     type: OfflineRegion.self,
                                                                                     concreteErrorType: MapError.self))
    }

    public func createOfflineRegion(for tilePyramidDefinition: OfflineRegionTilePyramidDefinition,
                                    completion: @escaping (Result<OfflineRegion, Error>) -> Void) {
        createOfflineRegion(for: tilePyramidDefinition, callback: coreAPIClosureAdapter(for: completion,
                                                                                        type: OfflineRegion.self,
                                                                                        concreteErrorType: MapError.self))
    }

    /// Merges data from the database at `filePath` into the main offline database.
    ///
    /// - Warning: This method passes only the first merged offline region to its completion block.
    /// In case there are no merged offline regions the completion block is called with an error.
    ///
    /// - Parameters:
    ///   - filePath: The path to the database to be merged
    ///   - completion: The block to execute with the results. This block is executed on the database thread.
    ///   The block has no return value and takes a `Result` case parameter that indicates the result of merging the offline database.
    @available(iOS, deprecated, message: "use mergeOfflineDatabase(forPath:completion) instead")
    public func mergeOfflineDatabase(for filePath: String,
                                     completion: @escaping (_ result: Result<OfflineRegion, Error>) -> Void) {
        mergeOfflineDatabase(forFilePath: filePath, callback: coreAPIClosureAdapter(for: completion,
                                                                                    type: NSArray.self,
                                                                                    concreteErrorType: MapError.self,
                                                                                       converter: { result in
            // returning the first region here for backwards compatibility
            (result as? [OfflineRegion])?.first
        }))
    }

    /// Merges data from the database at `filePath` into the main offline database.
    ///
    /// - Parameters:
    ///   - filePath: The path to the database to be merged
    ///   - completion: The block to execute with the results. This block is executed on the database thread.
    ///   The block has no return value and takes a `Result` case parameter that indicates the result of merging the offline database.
    public func mergeOfflineDatabase(forPath filePath: String,
                                     completion: @escaping (Result<[OfflineRegion], Error>) -> Void) {
        mergeOfflineDatabase(forFilePath: filePath, callback: coreAPIClosureAdapter(for: completion,
                                                                                    type: NSArray.self,
                                                                                    concreteErrorType: MapError.self))
    }

}
