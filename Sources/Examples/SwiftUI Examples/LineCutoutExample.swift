import SwiftUI
@_spi(Experimental) import MapboxMaps

struct LineCutoutExample: View {
    @State private var cutoutOpacity: Double = 0.5
    @State private var fadeWidth: Double = 0.5
    @State private var controlsHeight: CGFloat = 0

    var body: some View {
        Map(
            initialViewport: .camera(
                center: CLLocationCoordinate2D(latitude: 48.17664, longitude: 11.55670),
                zoom: 15.48,
                bearing: 48.6,
                pitch: 76.5
            )
        ) {
            makeRouteSource()

            LineLayer(id: "route-line", source: "route-source")
                .lineCap(.round)
                .lineJoin(.round)
                .lineWidth(8)
                .lineColor(.blue)
                .lineEmissiveStrength(1.0)
                .slot(.middle)

            LineLayer(id: "cutout-line", source: "route-source")
                .lineWidth(40)
                .lineColor(.clear)
                .lineCutoutFadeWidth(fadeWidth)
                .lineCutoutOpacity(cutoutOpacity)
                .slot(.middle)
        }
        .mapStyle(.standard)
        .additionalSafeAreaInsets(.bottom, controlsHeight)
        .ignoresSafeArea()
        .overlay(alignment: .bottom) {
            controlsView
                .onChangeOfSize { controlsHeight = $0.height }
        }
    }

    private var controlsView: some View {
        Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 8) {
            GridRow {
                Text("Cutout opacity")
                Slider(value: $cutoutOpacity, in: 0...1, step: 0.01)
                Text(String(format: "%.2f", cutoutOpacity))
                    .font(.system(size: 12))
                    .monospacedDigit()
                    .frame(width: 28, alignment: .trailing)
            }
            GridRow {
                Text("Fade width")
                Slider(value: $fadeWidth, in: 0...1, step: 0.01)
                Text(String(format: "%.2f", fadeWidth))
                    .font(.system(size: 12))
                    .monospacedDigit()
                    .frame(width: 28, alignment: .trailing)
            }
        }
        .padding()
        .safeGlassEffect()
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }

    private func makeRouteSource() -> GeoJSONSource {
        var source = GeoJSONSource(id: "route-source")
        source.data = .feature(Feature(geometry: LineString(routeCoordinates)))
        source.lineMetrics = true
        return source
    }
}

// Route from BMW Headquarters through Olympiapark to Olympiastadion, Munich
private let routeCoordinates: [CLLocationCoordinate2D] = [
    CLLocationCoordinate2D(latitude: 48.17691, longitude: 11.56024),
    CLLocationCoordinate2D(latitude: 48.17660, longitude: 11.55910),
    CLLocationCoordinate2D(latitude: 48.17620, longitude: 11.55376),
    CLLocationCoordinate2D(latitude: 48.17355, longitude: 11.55153),
    CLLocationCoordinate2D(latitude: 48.17493, longitude: 11.55004)
]
