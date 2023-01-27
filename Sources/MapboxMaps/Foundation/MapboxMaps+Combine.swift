import Foundation
#if canImport(Combine)
import Combine

/// :nodoc:
public protocol MapEventsPublisher {

    /// Creates a ``Publisher`` to listen to every occurences of given map event.
    /// - Parameter event: The event to listen to.
    @available(iOS 13.0, *)
    func publisher<Payload: Decodable>(for event: MapEvents.Event<Payload>) -> AnyPublisher<MapEvent<Payload>, Never>
}

extension MapboxObservableProtocol {

    @available(iOS 13.0, *)
    func publisher<Payload: Decodable>(for event: MapEvents.Event<Payload>) -> AnyPublisher<MapEvent<Payload>, Never> {
        var cancelableToken: Cancelable?
        return Deferred {
            let publisher = PassthroughSubject<MapEvent<Payload>, Never>()
            cancelableToken = self.onEvery(event: event, handler: publisher.send(_:))
            return publisher
                .handleEvents(
                    receiveCancel: { cancelableToken?.cancel() }
                )
        }
        .eraseToAnyPublisher()
    }
}
#endif
