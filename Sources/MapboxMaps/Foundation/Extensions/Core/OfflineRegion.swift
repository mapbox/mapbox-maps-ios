/// :nodoc:
@available(*, deprecated)
extension OfflineRegion {
    /// :nodoc:
    public func invalidate(completion: @escaping (Result<Void, Error>) -> Void) {
        self.invalidate(forCallback: coreAPIClosureAdapter(for: { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }, concreteErrorType: MapError.self))
    }

    /// :nodoc:
    public func purge(completion: @escaping (Result<Void, Error>) -> Void) {
        self.purge(forCallback: coreAPIClosureAdapter(for: { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }, concreteErrorType: MapError.self))
    }

    /// :nodoc:
    public func setMetadata(_ metadata: Data, completion: @escaping (Result<Void, Error>) -> Void) {
        self.setMetadataForMetadata(metadata, callback: coreAPIClosureAdapter(for: { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }, concreteErrorType: MapError.self))
    }

    /// :nodoc:
    public func getStatus(completion: @escaping (Result<OfflineRegionStatus, Error>) -> Void) {
        getStatusForCallback(
            coreAPIClosureAdapter(for: completion, type: OfflineRegionStatus.self, concreteErrorType: MapError.self)
        )
    }
}
