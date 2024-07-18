import Foundation
import SwiftUI
@_spi(Experimental) import MapboxMaps

@available(iOS 14.0, *)
struct ClipLayerExample: View {
    @State private var settings = ClipLayerSettings()

    let center = CLLocationCoordinate2D(latitude: 40.7130, longitude: -74.0027)

    var body: some View {
        Map(initialViewport: .camera(center: center, zoom: 16.5, bearing: 60.0, pitch: 30.0)) {
            GeoJSONSource(id: "source-id")
                .data(.geometry(rectangle))

            FillLayer(id: "fill-layer-id", source: "source-id")
                .fillOpacity(0.8)
                .fillColor(.blue)
                .slot(.bottom)

            /// There is a known issue that `clipLayerTypes` is not updated in runtime
            ClipLayer(id: "clip-layer-id", source: "source-id")
                .clipLayerTypes(settings.clipLayerTypes)
        }
        .ignoresSafeArea()
        .safeOverlay(alignment: .bottom) {
            VStack(alignment: .center) {
                Toggle("Clip Models", isOn: $settings.clipModels)
                Toggle("Clip Symbols", isOn: $settings.clipSymbols)
            }
            .floating(RoundedRectangle(cornerRadius: 10))
        }
    }
}

private struct ClipLayerSettings {
    var clipModels = true
    var clipSymbols = true

    var clipLayerTypes: [ClipLayerTypes] {
        var clipLayerTypes = [ClipLayerTypes]()

        if clipModels { clipLayerTypes.append(.model) }
        if clipSymbols { clipLayerTypes.append(.symbol) }

        return clipLayerTypes
    }
}

private let rectangle = Geometry(Polygon([
    [CLLocationCoordinate2D(latitude: 40.71275107696869, longitude: -74.00438542864366),
    CLLocationCoordinate2D(latitude: 40.712458268827675, longitude: -74.00465916994656),
    CLLocationCoordinate2D(latitude: 40.71212099900339, longitude: -74.00417333128154),
    CLLocationCoordinate2D(latitude: 40.71238635014873, longitude: -74.00314623457163),
    CLLocationCoordinate2D(latitude: 40.71296692136764, longitude: -74.00088173461268),
    CLLocationCoordinate2D(latitude: 40.713220461793924, longitude: -74.00081475001514),
    CLLocationCoordinate2D(latitude: 40.71419501190087, longitude: -74.0024425998592),
    CLLocationCoordinate2D(latitude: 40.71374214594772, longitude: -74.00341033210208),
    CLLocationCoordinate2D(latitude: 40.71275107696869, longitude: -74.00438542864366)]
]))
