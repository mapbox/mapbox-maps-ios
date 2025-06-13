import SwiftUI
import Turf
@_spi(Experimental) import MapboxMaps

/// Native implementation for the [Add an elevated line to a map](https://docs.mapbox.com/mapbox-gl-js/example/elevated-line/)
/// example from GL-JS 3.8
struct ElevatedLineMapView: View {
    private let elevationPropertyKey = "elevation"
    private let lineSourceID = "geojson"
    private let lineLayerID = "elevated-line"

    var body: some View {
        Map(initialViewport: .camera(
            center: CLLocationCoordinate2D(latitude: 45.8418, longitude: 6.7782),
            zoom: 11,
            bearing: -150,
            pitch: 62
        )) {
            StyleProjection(name: .mercator)

            createGeoJSONSource()

            LineLayer(id: lineLayerID, source: lineSourceID)
                .lineJoin(.round)
                .lineWidth(8)
                .lineColor(.blue)
                .lineEmissiveStrength(1.0)
                .lineElevationReference(.sea)
                .lineZOffset(
                    Exp(.atInterpolated) {
                        Exp(.product) {
                            Exp(.lineProgress)
                            Exp(.subtract, Exp(.length, Exp(.get, elevationPropertyKey)), 1)
                        }
                        Exp(.get, elevationPropertyKey)
                    }
                )
        }
        .mapStyle(.standard)
        .ignoresSafeArea(.all)
    }

    private func createGeoJSONSource() -> GeoJSONSource {
        var source = GeoJSONSource(id: lineSourceID)
            .data(createGeoJSON())
        source.lineMetrics = true
        return source
    }

    private func createGeoJSON() -> GeoJSONSourceData {
        let feature = Feature(geometry: Geometry(LineString(coordinates)))
            .properties([
                elevationPropertyKey: .array(elevations.map {JSONValue(Double($0))})
            ])

        return .feature(feature)
    }

    private let coordinates: [CLLocationCoordinate2D] = [
        CLLocationCoordinate2D(latitude: 45.833563, longitude: 6.862885),
        CLLocationCoordinate2D(latitude: 45.846851, longitude: 6.863605),
        CLLocationCoordinate2D(latitude: 45.862445, longitude: 6.859783),
        CLLocationCoordinate2D(latitude: 45.876361, longitude: 6.848727),
        CLLocationCoordinate2D(latitude: 45.892361, longitude: 6.827155),
        CLLocationCoordinate2D(latitude: 45.905032, longitude: 6.802194),
        CLLocationCoordinate2D(latitude: 45.909602, longitude: 6.780023),
        CLLocationCoordinate2D(latitude: 45.906074, longitude: 6.753605),
        CLLocationCoordinate2D(latitude: 45.899120, longitude: 6.728807),
        CLLocationCoordinate2D(latitude: 45.883872, longitude: 6.700449),
        CLLocationCoordinate2D(latitude: 45.863866, longitude: 6.683772),
        CLLocationCoordinate2D(latitude: 45.841619, longitude: 6.684058),
        CLLocationCoordinate2D(latitude: 45.825417, longitude: 6.691115),
        CLLocationCoordinate2D(latitude: 45.813349, longitude: 6.704446),
        CLLocationCoordinate2D(latitude: 45.807886, longitude: 6.720959),
        CLLocationCoordinate2D(latitude: 45.809517, longitude: 6.748477),
        CLLocationCoordinate2D(latitude: 45.817254, longitude: 6.775554),
        CLLocationCoordinate2D(latitude: 45.828871, longitude: 6.791236),
        CLLocationCoordinate2D(latitude: 45.838797, longitude: 6.801289),
        CLLocationCoordinate2D(latitude: 45.849788, longitude: 6.806307),
        CLLocationCoordinate2D(latitude: 45.866159, longitude: 6.803161),
        CLLocationCoordinate2D(latitude: 45.880461, longitude: 6.794599),
        CLLocationCoordinate2D(latitude: 45.890231, longitude: 6.769846),
        CLLocationCoordinate2D(latitude: 45.889576, longitude: 6.744712),
        CLLocationCoordinate2D(latitude: 45.881677, longitude: 6.722788),
        CLLocationCoordinate2D(latitude: 45.868556, longitude: 6.708097),
        CLLocationCoordinate2D(latitude: 45.851973, longitude: 6.699435),
        CLLocationCoordinate2D(latitude: 45.832980, longitude: 6.707324),
        CLLocationCoordinate2D(latitude: 45.822384, longitude: 6.723743),
        CLLocationCoordinate2D(latitude: 45.818626, longitude: 6.739347),
        CLLocationCoordinate2D(latitude: 45.822069, longitude: 6.756019),
        CLLocationCoordinate2D(latitude: 45.832436, longitude: 6.773963),
        CLLocationCoordinate2D(latitude: 45.848229, longitude: 6.785920),
        CLLocationCoordinate2D(latitude: 45.860521, longitude: 6.786155),
        CLLocationCoordinate2D(latitude: 45.870586, longitude: 6.774430),
        CLLocationCoordinate2D(latitude: 45.875670, longitude: 6.749012),
        CLLocationCoordinate2D(latitude: 45.868501, longitude: 6.731251),
        CLLocationCoordinate2D(latitude: 45.853689, longitude: 6.716033),
        CLLocationCoordinate2D(latitude: 45.846970, longitude: 6.714748),
        CLLocationCoordinate2D(latitude: 45.838934, longitude: 6.714635),
        CLLocationCoordinate2D(latitude: 45.832829, longitude: 6.717850),
        CLLocationCoordinate2D(latitude: 45.828151, longitude: 6.724010),
        CLLocationCoordinate2D(latitude: 45.827333, longitude: 6.730551),
        CLLocationCoordinate2D(latitude: 45.829900, longitude: 6.733951),
        CLLocationCoordinate2D(latitude: 45.834154, longitude: 6.735957),
        CLLocationCoordinate2D(latitude: 45.839871, longitude: 6.735286),
        CLLocationCoordinate2D(latitude: 45.843933, longitude: 6.734471),
        CLLocationCoordinate2D(latitude: 45.847233, longitude: 6.730893),
        CLLocationCoordinate2D(latitude: 45.847899, longitude: 6.728550),
        CLLocationCoordinate2D(latitude: 45.847822, longitude: 6.726590),
        CLLocationCoordinate2D(latitude: 45.846455, longitude: 6.724876),
        CLLocationCoordinate2D(latitude: 45.843900, longitude: 6.725096),
        CLLocationCoordinate2D(latitude: 45.841201, longitude: 6.726635),
        CLLocationCoordinate2D(latitude: 45.837041, longitude: 6.728074),
        CLLocationCoordinate2D(latitude: 45.834292, longitude: 6.727822),
    ]

    private let elevations = [
        4600, 4600, 4600, 4599, 4598, 4596, 4593, 4590, 4584, 4578, 4569,
        4559, 4547, 4533, 4516, 4497, 4475, 4450, 4422, 4390, 4355, 4316,
        4275, 4227, 4177, 4124, 4068, 4009, 3946, 3880, 3776, 3693, 3599,
        3502, 3398, 3290, 3171, 3052, 2922, 2786, 2642, 2490, 2332, 2170,
        1994, 1810, 1612, 1432, 1216, 1000
    ]
}
