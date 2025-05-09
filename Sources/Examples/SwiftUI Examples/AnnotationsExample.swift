import MapboxMaps
import SwiftUI

struct AnnotationsExample: View {
    struct Tap: Identifiable {
        var coordinate: CLLocationCoordinate2D
        var id = UUID().uuidString
    }

    struct Flight {
        struct Airport { // swiftlint:disable:this nesting
            var name: String
            var coordinate: CLLocationCoordinate2D
        }
        var name: String
        var color: UIColor
        var airports: [Airport]
    }

    static let flights = [
        Flight(name: "1", color: .systemRed, airports: [
            .init(name: "JFK", coordinate: .newYork),
            .init(name: "DCA", coordinate: .dc),
            .init(name: "LHR", coordinate: .london)
        ]),
        Flight(name: "2", color: .systemGreen, airports: [
            .init(name: "HEL", coordinate: .helsinki),
            .init(name: "BER", coordinate: .berlin),
            .init(name: "HND", coordinate: .tokyo)
        ])
    ]

    @State private var taps = [Tap]()
    @State private var alert: String?
    @State private var viewport = Viewport.camera(center: .init(latitude: 27.2, longitude: -26.9), zoom: 1.53, bearing: 0, pitch: 0)
    var body: some View {
        MapReader { _ in
            Map(viewport: $viewport) {
                ForEvery(Self.flights, id: \.name) { flight in
                    CircleAnnotationGroup(flight.airports, id: \.name) { airport in
                        CircleAnnotation(centerCoordinate: airport.coordinate, isDraggable: true)
                            .circleColor(StyleColor(flight.color))
                            .onTapGesture { alert = "Airport: \(airport.name)" }
                    }
                    .circleRadius(10)
                    .circleStrokeWidth(1)
                    .circleStrokeColor(.black)

                    PolylineAnnotation(lineCoordinates: flight.airports.map(\.coordinate))
                        .lineColor(.init(flight.color))
                        .lineWidth(3)
                        .onTapGesture {
                            alert = "Flight: \(flight.name)"
                        }
                }

                PolygonAnnotation(polygon: Polygon([
                    [
                        CLLocationCoordinate2D(latitude: 45.13745, longitude: -67.13734),
                        CLLocationCoordinate2D(latitude: 44.8097, longitude: -66.96466),
                        CLLocationCoordinate2D(latitude: 44.3252, longitude: -68.03252),
                        CLLocationCoordinate2D(latitude: 43.98, longitude: -69.06),
                        CLLocationCoordinate2D(latitude: 43.68405, longitude: -70.11617),
                        CLLocationCoordinate2D(latitude: 43.09008, longitude: -70.64573),
                        CLLocationCoordinate2D(latitude: 43.08003, longitude: -70.75102),
                        CLLocationCoordinate2D(latitude: 43.21973, longitude: -70.79761),
                        CLLocationCoordinate2D(latitude: 43.36789, longitude: -70.98176),
                        CLLocationCoordinate2D(latitude: 43.46633, longitude: -70.94416),
                        CLLocationCoordinate2D(latitude: 45.30524, longitude: -71.08482),
                        CLLocationCoordinate2D(latitude: 45.46022, longitude: -70.66002),
                        CLLocationCoordinate2D(latitude: 45.91479, longitude: -70.30495),
                        CLLocationCoordinate2D(latitude: 46.69317, longitude: -70.00014),
                        CLLocationCoordinate2D(latitude: 47.44777, longitude: -69.23708),
                        CLLocationCoordinate2D(latitude: 47.18479, longitude: -68.90478),
                        CLLocationCoordinate2D(latitude: 47.35462, longitude: -68.2343),
                        CLLocationCoordinate2D(latitude: 47.06624, longitude: -67.79035),
                        CLLocationCoordinate2D(latitude: 45.70258, longitude: -67.79141),
                        CLLocationCoordinate2D(latitude: 45.13745, longitude: -67.13734)
                    ]
                ]))
                .fillColor(StyleColor(.systemBlue))
                .fillOpacity(0.5)
                .fillOutlineColor(StyleColor(.black))
                .onTapGesture {
                    alert = "Maine"
                }

                PointAnnotationGroup(taps) { tap in
                    PointAnnotation(coordinate: tap.coordinate)
                        .image(named: "intermediate-pin")
                        .iconAnchor(.bottom)
                        .iconOffset(x: 0, y: 12)
                        .onTapGesture {
                            taps.removeAll(where: { $0.id == tap.id })
                        }
                }
                .clusterOptions(clusterOptions)
                .onClusterTapGesture { context in
                    withViewportAnimation(.easeIn(duration: 1)) {
                        viewport = .camera(center: context.coordinate, zoom: context.expansionZoom)
                    }
                }
                .slot(.middle)

                TapInteraction { context in
                    taps.append(Tap(coordinate: context.coordinate))
                    return false
                }
            }
            .ignoresSafeArea()
            .overlay(alignment: .bottom) {
                Text("Tap on map to add annotations")
                    .floating()
                    .padding(.bottom, 30)
            }
            .simpleAlert(message: $alert, title: "Tapped")
        }
    }

    var clusterOptions: ClusterOptions {
        let circleRadiusExpression = Exp(.step) {
            Exp(.get) {"point_count"}
            25
            5
            40
        }

        let circleColorExpression = Exp(.step) {
            Exp(.get) {"point_count"}
            UIColor.yellow
            5
            UIColor.green
            10
            UIColor.red
        }

        // Create expression to get the total count of annotations in a cluster
        let sumExpression = Exp {
            Exp(.sum) {
                Exp(.accumulated)
                Exp(.get) { "sum" }
            }
            1
        }

        // Create a cluster property to add to each cluster
        let clusterProperties: [String: Exp] = [
            "sum": sumExpression
        ]

        let textFieldExpression = Exp(.switchCase) {
            Exp(.has) { "point_count" }
            Exp(.concat) {
                Exp(.string) { "Count:\n" }
                Exp(.get) {"sum"}
            }
            Exp(.string) { "" }
        }

        return ClusterOptions(
            circleRadius: .expression(circleRadiusExpression),
            circleColor: .expression(circleColorExpression),
            textColor: .constant(StyleColor(.black)),
            textField: .expression(textFieldExpression),
            clusterRadius: 30,
            clusterProperties: clusterProperties
        )
    }
}
