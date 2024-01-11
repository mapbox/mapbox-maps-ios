import SwiftUI
@_spi(Experimental) import MapboxMaps

@available(iOS 14.0, *)
struct DynamicStylingExample: View {
    @State var useTerrain = true

    var body: some View {
        Map(initialViewport: .camera(center: .init(latitude: -33.48853, longitude: -70.81232), zoom: 11, bearing: 54.87, pitch: 67))
            .mapStyle(.standard {
                if useTerrain {
                    StyleProjection(name: .globe)
                    RasterDemSource(id: "mapbox-dem")
                        .url("mapbox://mapbox.mapbox-terrain-dem-v1")
                        .tileSize(514)
                        .maxzoom(14.0)
                    Terrain(sourceId: "mapbox-dem")
                        .exaggeration(.constant(5))
                } else {
                    StyleProjection(name: .mercator)
                }
            })
            .onMapTapGesture { _ in
                useTerrain.toggle()
            }
            .ignoresSafeArea()
    }
}

@available(iOS 14.0, *)
struct StyleDSLExample_Previews: PreviewProvider {
    static var previews: some View {
        DynamicStylingExample()
    }
}
