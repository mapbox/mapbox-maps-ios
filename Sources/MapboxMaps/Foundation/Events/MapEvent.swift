import Foundation

/// A generic Event type.
public typealias Event = MapboxCoreMaps.Event

/// A container for information broadcast about an event.
public class MapEvent<Payload: Decodable> {
    /// Type of the event.
    public var name: String { event.type }

    /// The payload associated with the event.
    public lazy var payload: Payload! = try? event.typedPayload()

    internal let event: Event

    internal init(event: Event) {
        self.event = event
    }
}

extension Event {
    fileprivate func typedPayload<Payload: Decodable>() throws -> Payload {
        do {
            let data = try JSONSerialization.data(withJSONObject: data)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(.rfc1123)
            decoder.keyDecodingStrategy = .convertFromKebabCase
            return try decoder.decode(Payload.self, from: data)
        } catch {
            Log.error(forMessage: "Cannot decode \(Payload.self) for \(self.data), error \(error)")
            throw error
        }
    }
}
