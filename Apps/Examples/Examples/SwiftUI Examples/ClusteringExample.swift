import SwiftUI
@_spi(Experimental) import MapboxMapsSwiftUI

@available(iOS 14.0, *)
struct ClusteringExample : View {
    struct Detail: Identifiable {
        var id = UUID()
        var title: String
        var message: String
    }

    @State private var camera = CameraState(center: .dc, zoom: 10)
    @State var details: Detail?

    var body: some View {
        Map(camera: $camera)
            .styleURI(.dark)
            .onMapLoaded { map in
                // This example uses direct modification of Style. It's not SwiftUI-way, yet possible.
                try! setupClusteringLayer(map.style)
            }
            .onMapTapGesture(queryOptions: queryOptions) { _, _, result in
                details = try? Detail.init(features: result.get())
            }
            .ignoresSafeArea()
            .alert(item: $details) {
                Alert(title: Text($0.title), message: Text($0.message))
            }
    }

    var queryOptions: RenderedQueryOptions {
        RenderedQueryOptions(layerIds: ["clustered-circle-layer", "unclustered-point-layer"], filter: nil)
    }
}

@available(iOS 14.0, *)
extension ClusteringExample.Detail {
    init?(features: [QueriedFeature]) {
        guard let properties = features.first?.feature.properties else {
            return nil
        }
        if case let .string(assetnum) = properties["ASSETNUM"],
           case let .string(loc) = properties["LOCATIONDETAIL"] {
            title = "Hydrant \(assetnum)"
            message = "\(loc)"
        } else if case let .number(pointCount) = properties["point_count"],
                  case let .number(clusterId) = properties["cluster_id"] {
            title = "Cluster ID \(Int(clusterId))"
            message = "There are \(Int(pointCount)) points in this cluster"
        } else {
            return nil
        }
    }
}

@available(iOS 14.0, *)
private func setupClusteringLayer(_ style: Style) throws {
    // The image named `fire-station-11` is included in the app's Assets.xcassets bundle.
    // In order to recolor an image, you need to add a template image to the map's style.
    // The image's rendering mode can be set programmatically or in the asset catalogue.
    let image = UIImage(named: "fire-station-11")!.withRenderingMode(.alwaysTemplate)

    // Add the image tp the map's style. Set `sdf` to `true`. This allows the icon images to be recolored.
    // For more information about `SDF`, or Signed Distance Fields, see
    // https://docs.mapbox.com/help/troubleshooting/using-recolorable-images-in-mapbox-maps/#what-are-signed-distance-fields-sdf
    try! style.addImage(image, id: "fire-station-icon", sdf: true)

    // Fire_Hydrants.geojson contains information about fire hydrants in the District of Columbia.
    // It was downloaded on 6/10/21 from https://opendata.dc.gov/datasets/DCGIS::fire-hydrants/about
    let url = Bundle.main.url(forResource: "Fire_Hydrants", withExtension: "geojson")!

    // Create a GeoJSONSource using the previously specified URL.
    var source = GeoJSONSource()
    source.data = .url(url)

    // Enable clustering for this source.
    source.cluster = true
    source.clusterRadius = 75
    let sourceID = "fire-hydrant-source"

    var clusteredLayer = createClusteredLayer()
    clusteredLayer.source = sourceID

    var unclusteredLayer = createUnclusteredLayer()
    unclusteredLayer.source = sourceID

    // `clusterCountLayer` is a `SymbolLayer` that represents the point count within individual clusters.
    var clusterCountLayer = createNumberLayer()
    clusterCountLayer.source = sourceID

    // Add the source and two layers to the map.
    try style.addSource(source, id: sourceID)
    try style.addLayer(clusteredLayer)
    try style.addLayer(unclusteredLayer, layerPosition: .below(clusteredLayer.id))
    try style.addLayer(clusterCountLayer)
}

@available(iOS 14.0, *)
private func createClusteredLayer() -> CircleLayer {
    // Create a symbol layer to represent the clustered points.
    var clusteredLayer = CircleLayer(id: "clustered-circle-layer")

    // Filter out unclustered features by checking for `point_count`. This
    // is added to clusters when the cluster is created. If your source
    // data includes a `point_count` property, consider checking
    // for `cluster_id`.
    clusteredLayer.filter = Exp(.has) { "point_count" }

    // Set the color of the icons based on the number of points within
    // a given cluster. The first value is a default value.
    clusteredLayer.circleColor = .expression(Exp(.step) {
        Exp(.get) { "point_count" }
        UIColor.systemGreen
        50
        UIColor.systemBlue
        100
        UIColor.systemRed
    })

    clusteredLayer.circleRadius = .constant(25)

    return clusteredLayer
}

@available(iOS 14.0, *)
private func createUnclusteredLayer() -> SymbolLayer {
    // Create a symbol layer to represent the points that aren't clustered.
    var unclusteredLayer = SymbolLayer(id: "unclustered-point-layer")

    // Filter out clusters by checking for `point_count`.
    unclusteredLayer.filter = Exp(.not) {
        Exp(.has) { "point_count" }
    }
    unclusteredLayer.iconImage = .constant(.name("fire-station-icon"))
    unclusteredLayer.iconColor = .constant(StyleColor(.white))

    // Rotate the icon image based on the recorded water flow.
    // The `mod` operator allows you to use the remainder after dividing
    // the specified values.
    unclusteredLayer.iconRotate = .expression(Exp(.mod) {
        Exp(.get) { "FLOW" }
        360
    })

    return unclusteredLayer
}

@available(iOS 14.0, *)
private func createNumberLayer() -> SymbolLayer {
    var numberLayer = SymbolLayer(id: "cluster-count-layer")

    // check whether the point feature is clustered
    numberLayer.filter = Exp(.has) { "point_count" }

    // Display the value for 'point_count' in the text field
    numberLayer.textField = .expression(Exp(.get) { "point_count" })
    numberLayer.textSize = .constant(12)
    return numberLayer
}

@available(iOS 14.0, *)
struct ClusteringExample_Preview: PreviewProvider {
    static var previews: some View {
        ClusteringExample()
    }
}


