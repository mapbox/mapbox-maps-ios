@_spi(Experimental) import MapboxMaps
import SwiftUI

@available(iOS 14.0, *)
struct AnnotationsStabilityTestExample: View {
    @State var bluePolygon = true
    @State var greenPolygon = true
    @State var circles = true

    var body: some View {
        Map(initialViewport: .camera(center: .init(latitude: 27.2, longitude: -26.9), zoom: 1.53, bearing: 0, pitch: 0)) {

            if bluePolygon {
                let poly = Polygon([
                    [
                        CLLocationCoordinate2D(latitude: 20, longitude: -20),
                        CLLocationCoordinate2D(latitude: 40, longitude: -20),
                        CLLocationCoordinate2D(latitude: 40, longitude: 0),
                        CLLocationCoordinate2D(latitude: 20, longitude: 0),
                    ]
                ])
                polygonAnnotation(for: poly, color: .systemBlue)
            }

            if circles {
                let circles = 80
                CircleAnnotationGroup(0..<circles, id: \.self) { i in
                    let coordinate = CLLocationCoordinate2D(
                        latitude: 35,
                        longitude: -180.0 + Double(i) * 360.0 / Double(circles)
                    )
                    return CircleAnnotation(centerCoordinate: coordinate)
                        .circleRadius(10)
                        .circleColor(StyleColor(.systemOrange))
                        .circleStrokeColor(StyleColor(.black))
                        .circleStrokeWidth(1)

                }
            }

            if greenPolygon {
                let polygon2 = Polygon([
                    [
                        CLLocationCoordinate2D(latitude:30, longitude: -10),
                        CLLocationCoordinate2D(latitude:50, longitude: -10),
                        CLLocationCoordinate2D(latitude:50, longitude: 10),
                        CLLocationCoordinate2D(latitude:30, longitude: 10),
                    ]
                ])
                polygonAnnotation(for: polygon2, color: .systemGreen)
            }

        }
        .ignoresSafeArea()
        .safeOverlay(alignment: .bottom) {
            VStack(alignment: .leading) {
                Text("Order:")
                Toggle("Blue polygon", isOn: $bluePolygon)
                Toggle("Circles", isOn: $circles)
                Toggle("Green polygon", isOn: $greenPolygon)
            }
            .floating()
            .padding(.bottom, 30)
        }
    }

    @MapContentBuilder
    func polygonAnnotation(for polygon: Polygon, color: UIColor) -> MapContent {
        PolygonAnnotation(polygon: polygon)
            .fillColor(StyleColor(color))
            .fillOpacity(0.5)
            .fillOutlineColor(StyleColor(.black))

        if let coordinates = polygon.coordinates.last, let firstCoord = coordinates.first {
            let lineCoordinates = coordinates + [firstCoord]
            PolylineAnnotation(lineCoordinates: lineCoordinates)
                .lineWidth(1.2)
                .lineColor(StyleColor(color.darker))
        }
    }
}

private extension UIColor {
    var darker: UIColor {
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0

        guard getRed(&r, green: &g, blue: &b, alpha: &a) else { return self }

        let v = 0.3

        return UIColor(red: max(r - v, 0.0),
                       green: max(g - v, 0.0),
                       blue: max(b - v, 0.0),
                       alpha: a)


    }
}
