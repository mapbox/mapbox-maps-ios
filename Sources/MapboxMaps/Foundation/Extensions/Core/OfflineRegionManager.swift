@_implementationOnly import MapboxCoreMaps_Private

@available(*, deprecated)
extension OfflineRegionManager {

    // :nodoc:
    public convenience init(resourceOptions: ResourceOptions) {
        self.init(resourceOptions: MapboxCoreMaps.ResourceOptions(resourceOptions))
    }

    // :nodoc:
    public func offlineRegions(completion: @escaping (Result<[OfflineRegion], Error>) -> Void) {
        getOfflineRegions(forCallback: coreAPIClosureAdapter(for: completion,
                                                             type: NSArray.self,
                                                             concreteErrorType: MapError.self))
    }

    // :nodoc:
    public func createOfflineRegion(for geometryDefinition: OfflineRegionGeometryDefinition,
                                    completion: @escaping (Result<OfflineRegion, Error>) -> Void) {
        createOfflineRegion(for: geometryDefinition, callback: coreAPIClosureAdapter(for: completion,
                                                                                     type: OfflineRegion.self,
                                                                                     concreteErrorType: MapError.self))
    }

    // :nodoc:
    public func createOfflineRegion(for tilePyramidDefinition: OfflineRegionTilePyramidDefinition,
                                    completion: @escaping (Result<OfflineRegion, Error>) -> Void) {
        createOfflineRegion(for: tilePyramidDefinition, callback: coreAPIClosureAdapter(for: completion,
                                                                                        type: OfflineRegion.self,
                                                                                        concreteErrorType: MapError.self))
    }

    // :nodoc:
    public func mergeOfflineDatabase(for filePath: String,
                                     completion: @escaping (Result<OfflineRegion, Error>) -> Void) {
        mergeOfflineDatabase(forFilePath: filePath, callback: coreAPIClosureAdapter(for: completion,
                                                                                    type: OfflineRegion.self,
                                                                                    concreteErrorType: MapError.self))
    }

    // :nodoc:
    public func invalidateOfflineRegion(_ offlineRegion: OfflineRegion, completion: @escaping (Error?) -> Void) {
        offlineRegion.invalidate(forCallback: coreAPIClosureAdapter(for: completion, concreteErrorType: MapError.self))
    }

    // :nodoc:
    public func purgeOfflineRegion(_ offlineRegion: OfflineRegion, completion: @escaping (Error?) -> Void) {
        offlineRegion.purge(forCallback: coreAPIClosureAdapter(for: completion, concreteErrorType: MapError.self))
    }
}
