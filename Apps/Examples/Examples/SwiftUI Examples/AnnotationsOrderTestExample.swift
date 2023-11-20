@_spi(Experimental) import MapboxMaps
import SwiftUI

@available(iOS 14.0, *)
struct AnnotationsOrderTestExample: View {
    @State var bluePolygon = true
    @State var greenPolygon = true
    @State var circles = true
    @State var tapMessage: String?
    @State var longPressMessage: String?

    var body: some View {
        MapReader { proxy in
            Map(initialViewport: .camera(center: .init(latitude: 27.2, longitude: -26.9), zoom: 1.53, bearing: 0, pitch: 0)) {
                mapContent
            }
            .onLayerTapGesture("purple-layer") { feature, context in
                tapMessage = gestureMessage("Purple layer", context: context)
                return true // handled, do not propagate to layers below or map
            }
            .onLayerLongPressGesture("purple-layer") { feature, context in
                longPressMessage = gestureMessage("Purple layer", context: context)
                return true // handled, do not propagate to layers below or map
            }
            .onMapTapGesture { context in
                tapMessage = gestureMessage("Map", context: context)
            }
            .onMapLongPressGesture { context in
                longPressMessage = gestureMessage("Map", context: context)
            }
            .onStyleLoaded { _ in
                proxy.map.map { initStyleLayer($0) }
            }
            .ignoresSafeArea()
            .safeOverlay(alignment: .bottom) {
                VStack(alignment: .leading) {
                    Group {
                        if tapMessage != nil || longPressMessage != nil {
                            VStack(alignment: .leading) {
                                if let tapMessage {
                                    Text("Tap: \(tapMessage)")
                                }
                                if let longPressMessage {
                                    Text("LongPress: \(longPressMessage)")
                                }
                            }
                        } else {
                            Text("Tap on any object.\nThe blue circles don't handle taps.")
                        }
                        HStack {
                            Toggle("Blue polygon", isOn: $bluePolygon)
                            Toggle("Circles", isOn: $circles)
                            Toggle("Green polygon", isOn: $greenPolygon)
                        }
                        .toggleStyleButton()
                    }
                    .floating()
                }
                .padding(.bottom, 30)
            }
        }
    }

    @MapContentBuilder
    var mapContent: MapContent {
        if bluePolygon {
            let poly = Polygon([
                [
                    CLLocationCoordinate2D(latitude: 20, longitude: -20),
                    CLLocationCoordinate2D(latitude: 40, longitude: -20),
                    CLLocationCoordinate2D(latitude: 40, longitude: 0),
                    CLLocationCoordinate2D(latitude: 20, longitude: 0),
                ]
            ])
            polygonAnnotation(for: poly, color: .systemBlue) { context in
                tapMessage = gestureMessage("Blue polygon", context: context)
                return true
            } onLongPressGesture: { context in
                longPressMessage = gestureMessage("Blue polygon", context: context)
                return true
            }
        }

        if circles {
            let circles = 80
            CircleAnnotationGroup(0..<circles, id: \.self) { i in
                let coordinate = CLLocationCoordinate2D(
                    latitude: 35,
                    longitude: -180.0 + Double(i) * 360.0 / Double(circles)
                )
                let isEven = i % 2 == 0
                return CircleAnnotation(centerCoordinate: coordinate)
                    .circleRadius(16)
                    .circleColor(StyleColor(isEven ? .systemOrange : .systemBlue))
                    .circleStrokeColor(StyleColor(.black))
                    .circleStrokeWidth(1)
                    .onTapGesture { context in
                        if isEven {
                            tapMessage = gestureMessage("Circle", context: context)
                            return true
                        }
                        return false // not handled, propagate to layers below the map
                    }
                    .onLongPressGesture { context in
                        if isEven {
                            longPressMessage = gestureMessage("Circle", context: context)
                            return true
                        }
                        return false // not handled, propagate to layers below the map
                    }
            }
        }

        if greenPolygon {
            let polygon2 = Polygon([
                [
                    CLLocationCoordinate2D(latitude: 30, longitude: -10),
                    CLLocationCoordinate2D(latitude: 50, longitude: -10),
                    CLLocationCoordinate2D(latitude: 50, longitude: 10),
                    CLLocationCoordinate2D(latitude: 30, longitude: 10),
                ]
            ])
            polygonAnnotation(for: polygon2, color: .systemGreen) { context in
                tapMessage = gestureMessage("Green polygon", context: context)
                return true
            } onLongPressGesture: { context in
                longPressMessage = gestureMessage("Green polygon", context: context)
                return true
            }
        }
    }

    @MapContentBuilder
    func polygonAnnotation(
        for polygon: Polygon,
        color: UIColor,
        onTapGesture: @escaping (MapContentGestureContext) -> Bool,
        onLongPressGesture: @escaping (MapContentGestureContext) -> Bool
    ) -> MapContent {
        PolygonAnnotation(polygon: polygon)
            .fillColor(StyleColor(color))
            .fillOpacity(0.5)
            .fillOutlineColor(StyleColor(.black))
            .onTapGesture(handler: onTapGesture)
            .onLongPressGesture(handler: onLongPressGesture)

        if let coordinates = polygon.coordinates.last, let firstCoord = coordinates.first {
            let lineCoordinates = coordinates + [firstCoord]
            PolylineAnnotation(lineCoordinates: lineCoordinates)
                .lineWidth(1.2)
                .lineColor(StyleColor(color.darker))
        }
    }

    private func initStyleLayer(_ map: MapboxMap) {
        var layer = FillLayer(id: "purple-layer", source: "pl")
        layer.fillColor = .constant(StyleColor(.purple))
        layer.fillOpacity = .constant(0.3)
        layer.slot = .middle

        var source = GeoJSONSource(id: "pl")
        let circlePolygon = Polygon(center: .init(latitude: 17, longitude: 12), radius: 3000000, vertices: 60)
        source.data = .geometry(.polygon(circlePolygon))

        try? map.addSource(source)
        try? map.addLayer(layer)
    }
}

private func gestureMessage(_ label: String, context: MapContentGestureContext) -> String {
    let coordinate =  String(format: "%.2f, %.2f", context.coordinate.latitude, context.coordinate.longitude)
    return "\(label) (\(coordinate))"
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
