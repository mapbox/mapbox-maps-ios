import MapboxMaps
import SwiftUI

struct InteractionsPlayground: View {
    @State private var text: String?
    @State private var tap: Tap?
    @State private var mapTap: Tap?
    @State private var disableTerrain: Bool = false

    @State private var routes = [
        Route(line: LineString(route1), isActive: true),
        Route(line: LineString(route2), isActive: false)
    ]

    var body: some View {
        ZStack {
            let cameraCenter = CLLocationCoordinate2D(latitude: 60.1718, longitude: 24.9453)
            Map(initialViewport: .camera(center: cameraCenter, zoom: 16.35, bearing: 49.92, pitch: 40)) {

                let polygon = Polygon(center: .helsinki, radius: 200, vertices: 30)
                PolygonAnnotationGroup {
                    PolygonAnnotation(polygon: polygon)
                        .fillColor(.green)
                        .fillOpacity(0.2)
                        .onTapGesture { _ in
                            text = "Polygon tap"
                            return true
                        }
                }
                .layerId("polygon")
                .slot(.bottom)

                PolylineAnnotationGroup(routes) { route in
                    PolylineAnnotation(lineString: route.line)
                        .lineColor(route.isActive ? "#57A9FB" : "gray")
                        .lineBorderColor(route.isActive ? "#327AC2" : "black")
                        .lineSortKey(route.isActive ? 1 : 0)
                        .onTapGesture { ctx in
                            text = "Tap route"
                            tap = Tap(pos: ctx.point, radius: 22)

                            let id = route.id
                            routes = routes.map { route in
                                var r = route
                                r.isActive = route.id == id
                                return r
                            }
                            return true
                        }
                }
                .tapRadius(22)
                .lineWidth(10)
                .lineBorderWidth(2)
                .lineCap(.round)
                .slot(.middle)

                TapInteraction(.standardPoi, radius: 0) { feature, ctx in
                    text = "Tap poi \(feature.name ?? "-"), r: 0"
                    tap = Tap(pos: ctx.point)
                    return true
                }

                TapInteraction(.standardPoi, radius: 8) { feature, ctx in
                    text = "Tap poi \(feature.name ?? "-"), r: 8"
                    tap = Tap(pos: ctx.point, radius: 8)
                    return true
                }

                TapInteraction(.standardPlaceLabels, radius: 10) { feature, ctx in
                    text = "Tap place \(feature.name ?? "-"), r: 10"
                    tap = Tap(pos: ctx.point, radius: 10)
                    return true
                }

                if disableTerrain {
                    Terrain(sourceId: "fake")
                }
                TapInteraction { ctx in
                    mapTap = Tap(pos: ctx.point)
                    text = nil
                    tap = nil
                    return true
                }
            }
            .debugOptions(.collision)

            GeometryReader { _ in
                if let mapTap {
                    TapView(tap: mapTap, color: .blue)
                        .id(mapTap.id)
                }
                if let tap {
                    TapView(tap: tap, color: .red)
                        .id(tap.id)
                }
            }
        }
        .ignoresSafeArea()
        .overlay(alignment: .bottom) {
            VStack {
                if let text {
                    Text(text)
                        .floating()
                }
                HStack {
                    Text("Disable Terrain")
                    Toggle("dis", isOn: $disableTerrain)
                }.floating()
            }
        }

    }
}

private struct Route: Identifiable {
    var id = UUID()
    var line: LineString
    var isActive: Bool
}

private let route1 = [
    CLLocationCoordinate2D(latitude: 60.17047709327494, longitude: 24.94189274671095),
    CLLocationCoordinate2D(latitude: 60.17057890370404, longitude: 24.944958457828335),
    CLLocationCoordinate2D(latitude: 60.17190499730512, longitude: 24.945178540794018),
    CLLocationCoordinate2D(latitude: 60.172111309514946, longitude: 24.9469168488161)
]

private let route2 = [
    CLLocationCoordinate2D(latitude: 60.17048155574875, longitude: 24.941910494113273),
    CLLocationCoordinate2D(latitude: 60.170578004847926, longitude: 24.9449704567908),
    CLLocationCoordinate2D(latitude: 60.17134054556911, longitude: 24.94735783361179),
    CLLocationCoordinate2D(latitude: 60.17159974510375, longitude: 24.947563850901645)
]

private struct Tap {
    var id = UUID()
    var pos: CGPoint
    var radius: Double?
}

private struct TapView: View {
    var tap: Tap
    var color: Color
    @State var opacity = 1.0
    var body: some View {
        let r = tap.radius ?? 3
        ZStack {
            if tap.radius != nil {
                Rectangle()
                    .stroke(color, lineWidth: 2) // Set border color and width
            }

            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
        }
        .frame(width: r * 2, height: r * 2)
        .offset(x: tap.pos.x - r, y: tap.pos.y - r)
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeInOut(duration: 2)) {
                opacity = 0
            }
        }
    }
}
