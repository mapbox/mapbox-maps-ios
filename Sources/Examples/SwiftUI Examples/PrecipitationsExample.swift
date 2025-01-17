import SwiftUI
@_spi(Experimental) import MapboxMaps

struct PrecipitationExample: View {
    @State var viewport: Viewport = .camera(center: CLLocationCoordinate2D(latitude: 37.33464837343596, longitude: -122.00896178062911), zoom: 18, pitch: 80)

    @State var snowState: PrecipitationState = .none
    @State var rainState: PrecipitationState = .none

    enum PrecipitationState: CaseIterable {
        case none, light, medium, heavy

        var intensity: Double {
            switch self {
            case .none: return 0
            case .light: return 0.2
            case .medium: return 0.6
            case .heavy: return 1.0
            }
        }

        var opacity: Double {
            switch self {
            case .none: return 0
            case .light: return 0.3
            case .medium: return 0.5
            case .heavy: return 0.8
            }
        }

        var snowIcon: String {
            switch self {
            case .none: return "snowflake"
            case .light: return "cloud.hail"
            case .medium: return "cloud.hail.fill"
            case .heavy: return "cloud.snow.fill"
            }
        }

        var rainIcon: String {
            switch self {
            case .none: return "drop"
            case .light: return "cloud.drizzle"
            case .medium: return "cloud.drizzle.fill"
            case .heavy: return "cloud.rain.fill"
            }
        }

        mutating func toggle() {
            let allCases = PrecipitationState.allCases
            let currentIndex = allCases.firstIndex(of: self)!
            let nextIndex = (currentIndex + 1) % allCases.count
            self = allCases[nextIndex]
        }
    }

    var body: some View {
        Map(viewport: $viewport) {
            Puck2D(bearing: .heading)
            if snowState != .none {
                Snow()
                    .intensity(snowState.intensity)
                    .opacity(snowState.opacity)
                    .vignette(0.5)
            }
            if rainState != .none {
                Rain()
                    .intensity(rainState.intensity)
                    .opacity(rainState.opacity)
                    .vignette(0.2)
                    .color(.blue.withAlphaComponent(0.4))
            }
        }
        .mapStyle(.standard)
        .ignoresSafeArea()
        .overlay(alignment: .trailing) {
            VStack {
                Button {
                    snowState.toggle()
                } label: {
                    Image(systemName: snowState.snowIcon)
                }
                .buttonStyle(MapFloatingButtonStyle())
                Button {
                    rainState.toggle()
                } label: {
                    Image(systemName: rainState.rainIcon)
                }
                .buttonStyle(MapFloatingButtonStyle())
            }
        }
    }
}

struct PrecipitationExample_Preview: PreviewProvider {
    static var previews: some View {
        PrecipitationExample()
    }
}
