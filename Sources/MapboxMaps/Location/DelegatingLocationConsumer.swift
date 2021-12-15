internal protocol DelegatingLocationConsumerDelegate: AnyObject {
    func delegatingLocationConsumer(_ consumer: DelegatingLocationConsumer, didReceiveLocation location: Location)
}

internal final class DelegatingLocationConsumer: NSObject, LocationConsumer {

    internal weak var delegate: DelegatingLocationConsumerDelegate?

    internal var isConsuming = false {
        didSet {
            if isConsuming {
                locationProducer.add(self)
            } else {
                locationProducer.remove(self)
            }
        }
    }

    private let locationProducer: LocationProducerProtocol

    internal init(locationProducer: LocationProducerProtocol) {
        self.locationProducer = locationProducer
        super.init()
    }

    internal func locationUpdate(newLocation: Location) {
        delegate?.delegatingLocationConsumer(self, didReceiveLocation: newLocation)
    }
}
