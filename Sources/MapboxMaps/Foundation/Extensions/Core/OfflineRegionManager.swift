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

    public func mergeOfflineDatabase(for filePath: String,
                                     completion: @escaping (Result<OfflineRegion, Error>) -> Void) {
        mergeOfflineDatabase(forFilePath: filePath, callback: coreAPIClosureAdapter(for: completion,
                                                                                    type: OfflineRegion.self,
                                                                                    concreteErrorType: MapError.self))
    }
}
