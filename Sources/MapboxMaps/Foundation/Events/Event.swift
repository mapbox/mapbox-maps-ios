import Foundation

public typealias Event = MapboxCoreMaps.Event

extension Event {
    fileprivate func typedPayload<Payload>() throws -> Payload where Payload: Decodable {
        let data = try JSONSerialization.data(withJSONObject: data)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(.rfc1123)
        return try decoder.decode(Payload.self, from: data)
    }
}

/// A container for information broadcast about an event.
public class TypedEvent<Payload: Decodable> {
    /// Type of the event.
    public var name: String { event.type }

    /// The payload associated with the event.
    public lazy var payload: Payload! = try? event.typedPayload()

    internal let event: Event

    internal init(event: Event) {
        self.event = event
    }
}
