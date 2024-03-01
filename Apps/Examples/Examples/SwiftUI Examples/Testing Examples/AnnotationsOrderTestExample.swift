@_spi(Experimental) import MapboxMaps
import SwiftUI

@available(iOS 14.0, *)
struct AnnotationsOrderTestExample: View {
    @State var bluePolygon = true
    @State var greenPolygon = true
    @State var yellowLayer = true
    @State var purpleLayer = true
    @State var circles = true
    @State var tapMessage: String?
    @State var longPressMessage: String?

    var body: some View {
            Map(initialViewport: .camera(center: .init(latitude: 27.2, longitude: -26.9), zoom: 1.53, bearing: 0, pitch: 0)) {
                mapContent
            }
            .mapStyle(.standard) {
                if yellowLayer {
                    TestLayer(id: "yellow-layer", radius: 2, color: .yellow, coordinate: .init(latitude: -5, longitude: 30))
                }
                if purpleLayer {
                    TestLayer(id: "purple-layer", radius: 2.5, color: .purple, coordinate: .init(latitude: 17, longitude: 12))
                }
                TestLayer(id: "black-layer", radius: 2, color: .black.darker, coordinate: .init(latitude: -10, longitude: 0))

            }
            .onLayerTapGesture("purple-layer") { feature, context in
                tapMessage = gestureMessage("Purple layer", context: context)
                return true // handled, do not propagate to layers below or map
            }
            .onLayerLongPressGesture("purple-layer") { feature, context in
                longPressMessage = gestureMessage("Purple layer", context: context)
                return true // handled, do not propagate to layers below or map
            }
            .onLayerTapGesture("black-layer") { feature, context in
                tapMessage = gestureMessage("Black layer", context: context)
                return true
            }
            .onLayerTapGesture("yellow-layer") { feature, context in
                tapMessage = gestureMessage("Yellow layer", context: context)
                return true
            }
            .onMapTapGesture { context in
                tapMessage = gestureMessage("Map", context: context)
            }
            .onMapLongPressGesture { context in
                longPressMessage = gestureMessage("Map", context: context)
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
                            Toggle("Purple layer", isOn: $purpleLayer)
                            Toggle("Yellow layer", isOn: $yellowLayer)
                        }
                        .toggleStyleButton()
                    }
                    .floating()
                }
                .padding(.bottom, 30)
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
            polygonAnnotation(id: "blue-poly", for: poly, color: .systemBlue) { context in
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
            polygonAnnotation(id: "green-poly", for: polygon2, color: .systemGreen) { context in
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
        id: String,
        for polygon: Polygon,
        color: UIColor,
        onTapGesture: @escaping (MapContentGestureContext) -> Bool,
        onLongPressGesture: @escaping (MapContentGestureContext) -> Bool
    ) -> MapContent {
        PolygonAnnotationGroup {
            PolygonAnnotation(polygon: polygon)
                .fillColor(StyleColor(color))
                .fillOpacity(0.5)
                .fillOutlineColor(StyleColor(.black))
                .onTapGesture(handler: onTapGesture)
                .onLongPressGesture(handler: onLongPressGesture)
        }.layerId(id)

        if let coordinates = polygon.coordinates.last, let firstCoord = coordinates.first {
            let lineCoordinates = coordinates + [firstCoord]
            PolylineAnnotation(lineCoordinates: lineCoordinates)
                .lineWidth(1.2)
                .lineColor(StyleColor(color.darker))
        }
    }
}

@available(iOS 13.0, *)
private struct TestLayer: MapStyleContent {
    var id: String
    var radius: LocationDistance
    var color: UIColor
    var coordinate: CLLocationCoordinate2D

    var body: some MapStyleContent {
        let sourceId = "\(id)-source"
        FillLayer(id: id, source: sourceId)
            .fillColor(color)
            .fillOpacity(0.4)
        LineLayer(id: "\(id)-border", source: sourceId)
            .lineColor(color.darker)
            .lineOpacity(0.4)
            .lineWidth(2)
        GeoJSONSource(id: sourceId)
            .data(.geometry(.polygon(Polygon(center: coordinate, radius: radius * 1000000, vertices: 60))))
    }
}

private func gestureMessage(_ label: String, context: MapContentGestureContext) -> String {
    let coordinate =  String(format: "%.2f, %.2f", context.coordinate.latitude, context.coordinate.longitude)
    return "\(label) (\(coordinate))"
}
