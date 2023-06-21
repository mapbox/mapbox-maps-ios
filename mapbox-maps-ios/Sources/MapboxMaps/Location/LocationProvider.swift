import Foundation

public protocol LocationProvider: AnyObject {
    var latestLocation: Location? { get }

    func add(consumer: LocationConsumer)
    func remove(consumer: LocationConsumer)
}
