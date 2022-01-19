@_implementationOnly import MapboxCoreMaps_Private

@available(*, deprecated)
extension OfflineRegion {
    // :nodoc:
    func invalidate(completion: @escaping (Result<Void, Error>) -> Void) {
        self.invalidate(forCallback: coreAPIClosureAdapter(for: { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }, concreteErrorType: MapError.self))
    }

    // :nodoc:
    func purge(completion: @escaping (Result<Void, Error>) -> Void) {
        self.purge(forCallback: coreAPIClosureAdapter(for: { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }, concreteErrorType: MapError.self))
    }
}
