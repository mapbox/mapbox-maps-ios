@testable import MapboxMaps

final class MockLocationProducerDelegate: LocationProducerDelegate {
    struct DidFailWithErrorParams {
        var locationProducer: LocationProducerProtocol
        var error: Error
    }
    let didFailWithErrorStub = Stub<DidFailWithErrorParams, Void>()
    func locationProducer(_ locationProducer: LocationProducerProtocol,
                          didFailWithError error: Error) {
        didFailWithErrorStub.call(with: .init(
            locationProducer: locationProducer,
            error: error))
    }

    struct DidChangeAccuracyAuthorizationParams {
        var locationProducer: LocationProducerProtocol
        var accuracyAuthorization: CLAccuracyAuthorization
    }
    let didChangeAccuracyAuthorizationStub = Stub<DidChangeAccuracyAuthorizationParams, Void>()
    func locationProducer(_ locationProducer: LocationProducerProtocol,
                          didChangeAccuracyAuthorization accuracyAuthorization: CLAccuracyAuthorization) {
        didChangeAccuracyAuthorizationStub.call(with: .init(
            locationProducer: locationProducer,
            accuracyAuthorization: accuracyAuthorization))
    }
}
