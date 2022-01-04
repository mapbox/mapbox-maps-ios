internal protocol DelegatingLocationConsumerDelegate: AnyObject {
    func delegatingLocationConsumer(_ consumer: DelegatingLocationConsumer, didReceiveLocation location: Location)
}

internal final class DelegatingLocationConsumer: NSObject, LocationConsumer {

    internal weak var delegate: DelegatingLocationConsumerDelegate?

    internal init(locationProducer: LocationProducerProtocol) {
        super.init()
        locationProducer.add(self)
    }

    internal func locationUpdate(newLocation: Location) {
        delegate?.delegatingLocationConsumer(self, didReceiveLocation: newLocation)
    }
}
