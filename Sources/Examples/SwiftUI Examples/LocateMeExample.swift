import SwiftUI
@_spi(Experimental) import MapboxMaps
import CoreLocation

/// The example demonstrates Puck and Viewport configuration that allow to follow user location.
struct LocateMeExample: View {
    @State var viewport: Viewport = .followPuck(zoom: 13, bearing: .constant(0))

    var body: some View {
        MapReader { proxy in
            Map(viewport: $viewport) {
                Puck2D(bearing: .heading)
                    .showsAccuracyRing(true)
            }
            .mapStyle(.standard)
            .ignoresSafeArea()
            .overlay(alignment: .trailing) {
                LocateMeButton(viewport: $viewport)
            }
        }
    }
}


/// The example demonstrates Puck and Viewport configuration that allow to follow user location.
/// In this example the CoreLocationProvider is use instead of default `AppleLocationProvider`.
struct LocateMeCoreLocationProviderExample: View {
    @State var locaionModel = LocationDataModel.createCore()
    @State var viewport: Viewport = .followPuck(zoom: 13, bearing: .constant(0))

    var body: some View {
        MapReader { proxy in
            Map(viewport: $viewport) {
                Puck2D(bearing: .heading)
                    .showsAccuracyRing(true)

            }
            .mapStyle(.standard)
            .locationDataModel(locaionModel)
            .ignoresSafeArea()
            .overlay(alignment: .trailing) {
                LocateMeButton(viewport: $viewport)
            }
            .onAppear {
                /// The core location provider doesn't automatically initiate the location authorization request.
                /// Instead, the application is responsible for that.
                let locationManager = CLLocationManager()
                if locationManager.authorizationStatus == .notDetermined {
                    locationManager.requestWhenInUseAuthorization()
                }
            }

        }
    }
}


struct LocateMeButton: View {
    @Binding var viewport: Viewport

    var body: some View {
        Button {
            withViewportAnimation(.default(maxDuration: 1)) {
                if isFocusingUser {
                    viewport = .followPuck(zoom: 16.5, bearing: .heading, pitch: 60)
                } else if isFollowingUser {
                    viewport = .idle
                } else {
                    viewport = .followPuck(zoom: 13, bearing: .constant(0))
                }
            }
        } label: {
            Image(systemName: imageName)
                .transition(.scale.animation(.easeOut))
        }
        .safeContentTransition()
        .buttonStyle(MapFloatingButtonStyle())
    }

    private var isFocusingUser: Bool {
        return viewport.followPuck?.bearing == .constant(0)
    }

    private var isFollowingUser: Bool {
        return viewport.followPuck?.bearing == .heading
    }

    private var imageName: String {
        if isFocusingUser {
           return  "location.fill"
        } else if isFollowingUser {
           return "location.north.line.fill"
        }
        return "location"

    }
}

private extension View {
    func safeContentTransition() -> some View {
        if #available(iOS 17, *) {
            return self.contentTransition(.symbolEffect(.replace))
        }
        return self
    }
}

struct LocateMeExample_Preview: PreviewProvider {
    static var previews: some View {
        LocateMeExample()
    }
}
