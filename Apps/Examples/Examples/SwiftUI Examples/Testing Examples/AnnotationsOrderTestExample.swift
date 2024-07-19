import MapboxMaps
import SwiftUI

@available(iOS 14.0, *)
struct AnnotationsOrderTestExample: View {
    @State var bluePolygon = true
    @State var greenPolygon = true
    @State var redPolygon = true
    @State var yellowLayer = true
    @State var purpleLayer = true
    @State var circles = true
    @State var tapMessage: String?
    @State var longPressMessage: String?
    @State var mapStyle = MapStyle.standard
    @State private var taps: [Tap] = []
    @State var layerBeforeMiddleSlot: String?

    var body: some View {
        Map(initialViewport: .camera(center: .init(latitude: 27.2, longitude: -26.9), zoom: 1.53, bearing: 0, pitch: 0)) {
            if purpleLayer {
                TestLayer(id: "purple-layer", radius: 2.5, color: .purple, coordinate: .init(latitude: 17, longitude: 12))
            }
            if yellowLayer {
                TestLayer(id: "yellow-layer", radius: 2, color: .yellow, coordinate: .init(latitude: -5, longitude: 30))
            }

            TestContent(redPolygon: redPolygon)

            TapsContent(taps: taps)
            AnnotationsContent(
                bluePolygon: bluePolygon,
                greenPolygon: greenPolygon,
                circles: circles
            )
            TestLayer(id: "black-layer", radius: 2, color: .black.darker, coordinate: .init(latitude: -10, longitude: 0))
        }
        .mapStyle(mapStyle)
        .onLayerTapGesture("purple-layer") { _, context in
            tapMessage = gestureMessage("Purple layer", context: context)
            return true // handled, do not propagate to layers below or map
        }
        .onLayerLongPressGesture("purple-layer") { _, context in
            longPressMessage = gestureMessage("Purple layer", context: context)
            return true // handled, do not propagate to layers below or map
        }
        .onLayerTapGesture("black-layer") { _, context in
            tapMessage = gestureMessage("Black layer", context: context)
            return true
        }
        .onLayerTapGesture("yellow-layer") { _, context in
            tapMessage = gestureMessage("Yellow layer", context: context)
            return true
        }
        .onMapTapGesture { context in
            tapMessage = gestureMessage("Map", context: context)
            taps.append(Tap(coordinate: context.coordinate))
        }
        .onMapLongPressGesture { context in
            longPressMessage = gestureMessage("Map", context: context)
        }
        .ignoresSafeArea()
        .safeOverlay(alignment: .trailing) {
            MapStyleSelectorButton(mapStyle: $mapStyle)
        }
        .safeOverlay(alignment: .bottom) {
            VStack(alignment: .center) {
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
                        ColorButton(color: .red, isOn: $redPolygon)
                        ColorButton(color: .blue, isOn: $bluePolygon)
                        ColorButton(color: .systemGreen, isOn: $greenPolygon)
                        ColorButton(color1: .orange, color2: .blue, isOn: $circles)
                        ColorButton(color: .purple, isOn: $purpleLayer)
                        ColorButton(color: .yellow, isOn: $yellowLayer)
                    }
                    .toggleStyleButton()
                }
                .floating()
            }
            .padding(.bottom, 30)
        }
    }
}

@available(iOS 14.0, *)
struct AnnotationsContent: MapContent {
    let bluePolygon: Bool
    let greenPolygon: Bool
    let circles: Bool

    @MapContentBuilder
    var body: some MapContent {
        if bluePolygon {
            PolygonContent(polygon: .blue, color: .systemBlue)
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
                    .onTapGesture { _ in
                        if isEven {
                            return true
                        }
                        return false // not handled, propagate to layers below the map
                    }
                    .onLongPressGesture { _ in
                        if isEven {
                            return true
                        }
                        return false // not handled, propagate to layers below the map
                    }
            }
        }

        if greenPolygon {
            PolygonContent(polygon: .green, color: .systemGreen)
        }
    }
}

@available(iOS 14.0, *)
struct TestContent: MapContent {
    let redPolygon: Bool

    var body: some MapContent {
        PolygonAnnotationGroup {
            PolygonAnnotation(polygon: .cyan)
                .fillColor(StyleColor(.cyan))
                .fillOpacity(0.5)
                .fillOutlineColor(StyleColor(.black))

            if redPolygon {
                PolygonAnnotation(polygon: .red)
                    .fillColor(StyleColor(.red))
                    .fillOpacity(0.5)
                    .fillOutlineColor(StyleColor(.black))
            }
        }
    }
}

@available(iOS 14.0, *)
struct PolygonContent: MapContent {
    let polygon: Polygon
    let color: UIColor

    var body: some MapContent {
        PolygonAnnotationGroup {
            PolygonAnnotation(polygon: polygon)
                .fillColor(StyleColor(color))
                .fillOpacity(0.5)
                .fillOutlineColor(StyleColor(.black))
        }

        if let coordinates = polygon.coordinates.last, let firstCoord = coordinates.first {
            let lineCoordinates = coordinates + [firstCoord]
            PolylineAnnotationGroup {
                PolylineAnnotation(lineCoordinates: lineCoordinates)
                    .lineWidth(1.2)
                    .lineColor(StyleColor(color.darker))
            }
        }
    }
}

@available(iOS 13.0, *)
private struct Tap: Equatable, Identifiable {
    var id = UUID()
    var coordinate: CLLocationCoordinate2D
}

@available(iOS 14.0, *)
private struct TapsContent: MapContent {
    var taps: [Tap]

    var body: some MapContent {
        ForEvery(taps) { tap in
            PolygonAnnotation(polygon: Polygon(center: tap.coordinate, radius: 800000, vertices: 60))
                .fillColor(StyleColor(.white))
                .fillOpacity(0.7)
                .fillOutlineColor(StyleColor(.white))

            TestLayer(id: tap.id.uuidString, radius: 0.4, color: .black, coordinate: tap.coordinate)

            MapViewAnnotation(coordinate: tap.coordinate) {
                Circle()
                    .fill(.black)
            }
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

@available(iOS 14.0, *)
private struct ColorButton: View {
    let color1: UIColor
    let color2: UIColor
    let isOn: Binding<Bool>

    init(color: UIColor, isOn: Binding<Bool>) {
        self.color1 = color
        self.color2 = color
        self.isOn = isOn
    }

    init(color1: UIColor, color2: UIColor, isOn: Binding<Bool>) {
        self.color1 = color1
        self.color2 = color2
        self.isOn = isOn
    }

    var body: some View {
        Button(action: { isOn.wrappedValue.toggle() }) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(color1), Color(color2)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                Circle().strokeBorder(Color(color1.darker), lineWidth: 2)
            }
        }
        .opacity(isOn.wrappedValue ? 1.0 : 0.2)
        .frame(width: 50, height: 50)
    }
}

private extension Polygon {
    static let cyan = Polygon([
        [
            CLLocationCoordinate2D(latitude: 42, longitude: -15),
            CLLocationCoordinate2D(latitude: 55, longitude: -15),
            CLLocationCoordinate2D(latitude: 55, longitude: 5),
            CLLocationCoordinate2D(latitude: 42, longitude: 5),
        ]
    ])

    static let red = Polygon([
        [
            CLLocationCoordinate2D(latitude: 45, longitude: -20),
            CLLocationCoordinate2D(latitude: 65, longitude: -20),
            CLLocationCoordinate2D(latitude: 65, longitude: 0),
            CLLocationCoordinate2D(latitude: 45, longitude: 0),
        ]
    ])

    static let green = Polygon([
        [
            CLLocationCoordinate2D(latitude: 30, longitude: -10),
            CLLocationCoordinate2D(latitude: 50, longitude: -10),
            CLLocationCoordinate2D(latitude: 50, longitude: 10),
            CLLocationCoordinate2D(latitude: 30, longitude: 10),
        ]
    ])

    static let blue = Polygon([
        [
            CLLocationCoordinate2D(latitude: 20, longitude: -20),
            CLLocationCoordinate2D(latitude: 40, longitude: -20),
            CLLocationCoordinate2D(latitude: 40, longitude: 0),
            CLLocationCoordinate2D(latitude: 20, longitude: 0),
        ]
    ])
}
