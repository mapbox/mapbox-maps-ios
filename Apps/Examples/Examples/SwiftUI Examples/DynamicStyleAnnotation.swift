import SwiftUI
@_spi(Experimental) import MapboxMapsSwiftUI

@available(iOS 14.0, *)
struct DynamicAnnotationStyle: StyleComponent {
    var taps: FeatureCollection

    var body: some StyleComponent {
        GeoJSONSource(
            data: .featureCollection(taps)
        ).id("tap-source")

        SymbolLayer(
            id: "tap-position",
            source: "tap-source",
            iconAllowOverlap: .constant(true),
            iconAnchor: .constant(.bottom),
            iconImage: .constant(.name("red-marker-icon")))

        ImageComponent(
            id: "red-marker-icon",
            uiImage: UIImage(named: "red_marker")!
        )
    }
}

@available(iOS 14.0, *)
struct DynamicAnnotaionsExample : View {
    @State var taps = FeatureCollection(features: [])
    @State private var camera = CameraState(center: .london, zoom: 12)

    var body: some View {
        Map(camera: $camera)
            .styleURI(.satellite)
            .style(DynamicAnnotationStyle(taps: taps))
            .onMapTapGesture(perform: { _, coordinate in
                taps.features.append(Feature(geometry: .point(Point(coordinate))))
            })
            .ignoresSafeArea()
    }
}

@available(iOS 14.0, *)
struct DynamicAnnotaionsExample_Preview: PreviewProvider {
    static var previews: some View {
        DynamicAnnotaionsExample()
    }
}
