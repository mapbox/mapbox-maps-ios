import Foundation

import SwiftUI
@_spi(Experimental) import MapboxMapsSwiftUI

@available(iOS 14.0, *)
struct AnnotationsExample: View {
    struct City {
        var name: String
        var location: CLLocationCoordinate2D
    }

    @State var camera = CameraState(center: .zero, zoom: 1)

    var cities = [
        City(name: "Helsinki", location: .helsinki),
        City(name: "New York", location: .newYork),
        City(name: "London", location: .london),
        City(name: "Berlin", location: .berlin)
    ]

    var body: some View {
        Map(camera: $camera)
            .annotations(cities.map {
                var annotation = PointAnnotation(
                    id: $0.name,
                    coordinate: $0.location
                )
                annotation.image = .init(
                    image: UIImage(named: "marker")!, name: "marker")
                return annotation
            })
            .edgesIgnoringSafeArea(.all)
            .cameraDebugOverlay(alignment: .topTrailing, camera: $camera)
    }
}

@available(iOS 14.0, *)
struct AnnotationsExample_Previews: PreviewProvider {
    static var previews: some View {
        AnnotationsExample()
    }
}
