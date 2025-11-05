import SwiftUI
import MapboxMaps

/// The example demonstrates how to override the default location provider using SwiftUI and Combine.
struct LocationOverrideExample: View {
    private class LocationProvider {
        @Published var location = Location(coordinate: .zero)
        @Published var heading = Heading(direction: 0, accuracy: 0)

        lazy var model = {
            LocationDataModel(
                location: $location.map {[$0]}.eraseToAnyPublisher(),
                heading: $heading.eraseToAnyPublisher())
        }()
    }

    @State private var provider = LocationProvider()

    var body: some View {
        Map {
            /// The location indicator puck position and heading is controlled by the location provider.
            Puck2D(bearing: .heading)

            /// Handle tap on the map.
            TapInteraction { context in
                /// As a demonstration, override location with the last tap coordinate.
                let direction = provider.location.coordinate.direction(to: context.coordinate)
                provider.location = Location(coordinate: context.coordinate)
                provider.heading = Heading(direction: direction, accuracy: 0)

                return false
            }
        }
        .locationDataModel(provider.model)
        .ignoresSafeArea()
        .overlay(alignment: .bottom) {
            Text("Tap on map to move the puck")
                .floating()
                .padding(.bottom, 30)
        }
    }
}
