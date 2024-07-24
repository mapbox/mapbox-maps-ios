import SwiftUI
import MapboxMaps

/// The example demonstrates how to override the default location provider using SwiftUI and Combine.
@available(iOS 14.0, *)
struct LocationOverrideExample: View {
    private class LocationProvider {
        @Published var location = Location(coordinate: .zero)
        @Published var heading = Heading(direction: 0, accuracy: 0)
    }

    @State private var provider = LocationProvider()

    var body: some View {
        MapReader { proxy in
            Map {
                /// The location indicator puck position and heading is controlled by the location provider.
                Puck2D(bearing: .heading)
            }
            .onMapTapGesture { context in
                /// As a demonstration, override location with the last tap coordinate.
                let direction = provider.location.coordinate.direction(to: context.coordinate)
                provider.location = Location(coordinate: context.coordinate)
                provider.heading = Heading(direction: direction, accuracy: 0)
            }
            .onAppear {
                /// Override the location and Heading provider with Combine publishers.
                proxy.location?.override(
                    locationProvider: provider.$location.map {[$0]}.eraseToSignal(),
                    headingProvider: provider.$heading.eraseToSignal())
            }
        }
        .ignoresSafeArea()
        .safeOverlay(alignment: .bottom) {
            Text("Tap on map to move the puck")
                .floating()
                .padding(.bottom, 30)
        }
    }
}
