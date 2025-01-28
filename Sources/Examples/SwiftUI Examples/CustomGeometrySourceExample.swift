import SwiftUI
import MapboxMaps

struct CustomGeometrySourceExample: View {
    @StateObject private var model = Model()

    var body: some View {
        MapReader { proxy in
            Map {
                if let options = model.options {
                    CustomGeometrySource(id: .customGeometrySource, options: options)
                    LineLayer(id: "grid_layer", source: .customGeometrySource)
                        .lineColor(.red)
                }
            }
            .ignoresSafeArea()
            .overlay(alignment: .bottom) {
                sliderPanel
            }
            .onAppear {
                model.options = model.makeCustomGeometrySourceOptions(for: proxy.map!)
            }
            .onChange(of: model.gridSpacing) { _ in
                try? proxy.map!.invalidateCustomGeometrySourceRegion(forSourceId: .customGeometrySource, bounds: .world)
            }
        }
    }

    @ViewBuilder
    var sliderPanel: some View {
        VStack {
            Text("Grid Spacing: \(model.gridSpacing, specifier: "%.2f")")
            Slider(value: $model.gridSpacing, in: 0.01...10) {
                Text("Grid Spacing")
            } minimumValueLabel: {
                Image(systemName: "grid")
                    .font(.system(size: 12))
            } maximumValueLabel: {
                Image(systemName: "grid")
                    .font(.system(size: 24))
            }
        }
        .padding(10)
        .floating(RoundedRectangle(cornerRadius: 10))
        .limitPaneWidth()
    }
}

private extension String {
    static let customGeometrySource = "custom-raster-source"
}

private class Model: ObservableObject {
    @Published var gridSpacing: Double = 7
    @Published var options: CustomGeometrySourceOptions?

    func makeCustomGeometrySourceOptions(for mapboxMap: MapboxMap) -> CustomGeometrySourceOptions {
        return CustomGeometrySourceOptions(
           fetchTileFunction: { [weak self] tileId in
               guard let self else { return }

               let neighborTile = CanonicalTileID(z: tileId.z, x: tileId.x + 1, y: tileId.y + 1)
               let bounds = CoordinateBounds(
                   southwest: CLLocationCoordinate2D(latitude: neighborTile.latitude, longitude: tileId.longitude),
                   northeast: CLLocationCoordinate2D(latitude: tileId.latitude, longitude: neighborTile.longitude)
               )

               let latFrom = ceil(bounds.northeast.latitude / gridSpacing) * gridSpacing
               let latTo = floor(bounds.southwest.latitude / gridSpacing) * gridSpacing
               let latLines = stride(from: latFrom, through: latTo, by: -gridSpacing).map { lat in
                   LineString([
                       CLLocationCoordinate2D(latitude: lat, longitude: bounds.southwest.longitude),
                       CLLocationCoordinate2D(latitude: lat, longitude: bounds.northeast.longitude)
                   ])
               }

               let lonFrom = floor(bounds.southwest.longitude / gridSpacing) * gridSpacing
               let lonTo = ceil(bounds.northeast.longitude / gridSpacing) * gridSpacing
               let lonLines = stride(from: lonFrom, through: lonTo, by: gridSpacing).map { lng in
                   LineString([
                       CLLocationCoordinate2D(latitude: bounds.southwest.latitude, longitude: lng),
                       CLLocationCoordinate2D(latitude: bounds.northeast.latitude, longitude: lng)
                   ])
               }
               try! mapboxMap.setCustomGeometrySourceTileData(
                   forSourceId: .customGeometrySource,
                   tileId: tileId,
                   features: (latLines + lonLines).map(Feature.init)
               )
           },
           cancelTileFunction: { _ in },
           tileOptions: TileOptions()
       )
    }
}

extension CanonicalTileID {
    var latitude: CLLocationDegrees {
        let n = Double.pi - 2.0 * Double.pi * Double(y) / pow(2.0, Double(z))
        return (180.0 / .pi) * atan(0.5 * (exp(n) - exp(-n)))
    }

    var longitude: CLLocationDegrees {
        return Double(x) / pow(2.0, Double(z)) * 360.0 - 180.0
    }
}
