import Foundation
@_spi(Package) import MapboxMaps

struct MapEventObserver {
    let eventName: String
    let action: (Event) -> Void

    init<Payload: Decodable>(event: MapEvents.Event<Payload>, action: @escaping (MapEvent<Payload>) -> Void) {
        self.eventName = event.name
        self.action = { coreEvent in
            guard coreEvent.type == event.name else { return }
            action(MapEvent(event: coreEvent))
        }
    }

    init(event: MapEvents.Event<NoPayload>, action: @escaping () -> Void) {
        self.init(event: event) { _ in
            action()
        }
    }
}
