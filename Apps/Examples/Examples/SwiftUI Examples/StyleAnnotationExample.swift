import SwiftUI
@_spi(Experimental) import MapboxMapsSwiftUI

struct AnnotationsStyle: StyleComponent {
    var body: some StyleComponent {
        GeoJSONSource(
            data: .url(Bundle.main.url(forResource: "Fire_Hydrants", withExtension: "geojson")!)
        ).id("hydrants")

        SymbolLayer(
            id: "hydrants-points",
            source: "hydrants",
            iconImage: .constant(.name("fire-station-icon")),
            iconRotate: .expression(Exp(.mod) {
                Exp(.get) { "FLOW" }
                360
            }),
            iconColor: .constant(StyleColor(.black)))

        ImageComponent(
            id:"fire-station-icon",
            uiImage: UIImage(named: "fire-station-11")!.withRenderingMode(.alwaysTemplate),
            sdf: true
        )
    }
}

@available(iOS 14.0, *)
struct StyleAnnotationsExample : View {
    @State private var camera = CameraState(center: .dc, zoom: 10)

    var body: some View {
        Map(camera: $camera)
            .styleURI(.light)
            .style(AnnotationsStyle())
            .ignoresSafeArea()
    }
}

@available(iOS 14.0, *)
struct StyleAnnotationsExample_Preview: PreviewProvider {
    static var previews: some View {
        StyleAnnotationsExample()
    }
}
