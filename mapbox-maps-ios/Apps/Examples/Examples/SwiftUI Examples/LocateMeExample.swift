import SwiftUI
@_spi(Experimental) import MapboxMaps

@available(iOS 14.0, *)
struct LocateMeExample: View {
    @State var viewport: Viewport = .followPuck(zoom: 13, bearing: .constant(0))

    var body: some View {
        Map(viewport: $viewport) {
            PuckAnnotation2D(bearing: .heading)
        }
            .styleURI(.standard)
            .ignoresSafeArea()
            .safeOverlay(alignment: .trailing) {
                VStack(alignment: .leading) {
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
                    .buttonStyle(MapFloatingButtonStyle())
                }
            }
    }

    var isFocusingUser: Bool {
        return viewport.followPuck?.bearing == .constant(0)
    }

    var isFollowingUser: Bool {
        return viewport.followPuck?.bearing == .heading
    }

    var imageName: String {
        if isFocusingUser {
           return  "location.fill"
        } else if isFollowingUser {
           return "location.north.line.fill"
        }
        return "location"

    }
}

@available(iOS 14.0, *)
struct LocateMeExample_Preview: PreviewProvider {
    static var previews: some View {
        LocateMeExample()
    }
}
