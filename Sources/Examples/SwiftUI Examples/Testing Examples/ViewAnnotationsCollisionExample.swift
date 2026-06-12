@_spi(Experimental) import MapboxMaps
import SwiftUI

struct ViewAnnotationsCollisionExample: View {
    static let pin = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
    static let avoidAnnotation = CLLocationCoordinate2D(latitude: 37.7841, longitude: -122.3982)

    @State private var tapCoordinate: CLLocationCoordinate2D?
    @State private var isBig = false
    @State private var emptyStyle = false
    @State private var showCollisionBoxes = false
    @State private var enableSymbolCollision = true
    @State private var allowOverlap = true
    @State private var poiPins = [StandardPoiFeature]()
    @State private var anchor: ViewAnnotationAnchorConfig?
    @State private var avoiderVAenableSymbolCollision = false
    @State private var panelHeight = 0.0

    var body: some View {
        Map(
            initialViewport: .camera(center: CLLocationCoordinate2D(latitude: 37.7723, longitude: -122.408), zoom: 12.5)
        ) {
            if emptyStyle {
                BackgroundLayer(id: "bg")
                    .backgroundColor(.white)
            }

            LayersToAvoid()
            MapViewAnnotation(annotatedFeature: .layerFeature(layerId: LayersToAvoid.alternativeRouteLayerId)) {
                let hides = Text("hides symbols")
                    .strikethrough(!avoiderVAenableSymbolCollision)
                let avoidsPin = Text("avoids pin")
                    .strikethrough(avoiderVAenableSymbolCollision)
                Text(
                    "This VA \(avoidsPin)\n\(hides)\n(tap to change)"
                )
                .foregroundStyle(avoiderVAenableSymbolCollision ? .white : .black)
                .font(.safeMonospaced)
                .padding(5)
                .callout(anchor: anchor?.anchor ?? .center, color: avoiderVAenableSymbolCollision ? .green : .white)
                .onTapGesture {
                    avoiderVAenableSymbolCollision.toggle()
                }
            }
            .variableAnchors(.all)/// To avoid layers the annotation need variable anchors
            .onAnchorChanged { anchor = $0 }
            .enableSymbolLayerCollision(avoiderVAenableSymbolCollision)

            MapViewAnnotation(coordinate: Self.pin) {
                PinView(text: "View Annotation", size: isBig ? 70.0 : 35.0)
                    .onTapGesture {
                        isBig.toggle()
                    }
            }
            .enableSymbolLayerCollision(enableSymbolCollision)
            .allowOverlap(allowOverlap)

            ForEvery(poiPins, id: \.name) { poi in
                FeatureState(poi, .init(hide: true))
                MapViewAnnotation(coordinate: poi.coordinate) {
                    PinView(text: poi.name ?? "")
                }
                .enableSymbolLayerCollision(enableSymbolCollision)
                .allowOverlap(allowOverlap)
            }

            TapInteraction(.standardPoi) { poi, _ in
                poiPins.append(poi)
                return true
            }

            TapInteraction { _ in
                poiPins = []
                return true
            }
        }
        .mapStyle(emptyStyle ? .empty : .standard)
        .debugOptions([.camera, .padding])
        .additionalSafeAreaInsets(.bottom, panelHeight)

        /// Experimental API - all annotatios besides those that have `enableSymbolLayerCollision = true` will avoid certain layers when placed.
        .viewAnnotationAvoidLayers([LayersToAvoid.routeLayerId, LayersToAvoid.alternativeRouteLayerId, LayersToAvoid.sybolsLayerId])
        .ignoresSafeArea()
        /// Debug panel
        .overlay(alignment: .bottom) {
            VStack(alignment: .leading) {
                let hide = Text("hide")
                    .strikethrough(!enableSymbolCollision)
                Text(
                    "The View Annotations \(hide) the map symbols below automatically.\nTap on POI features to add more annotations."
                )
                MiniToggle("Collision debug", isOn: $showCollisionBoxes)
                if showCollisionBoxes {
                    MiniToggle("Empty style", isOn: $emptyStyle)
                }
                MiniToggle("Enable ViewAnnotation-Symbols collision", isOn: $enableSymbolCollision)
                MiniToggle("Allow Overlap (view annotations)", isOn: $allowOverlap)
            }
            .floating()
            .font(.safeMonospaced)
            .onChangeOfSize { size in
                panelHeight = size.height
            }
        }
    }
}

private struct LayersToAvoid: MapContent {
    static let sybolsLayerId = "symbols"
    static let routeLayerId = "route"
    static let alternativeRouteLayerId = "route-alternative"
    static let layerPin = CLLocationCoordinate2D(latitude: 37.78, longitude: -122.40)

    var body: some MapContent {
        SymbolLayer(id: Self.sybolsLayerId, source: "symbols")
            .iconImage("marker")
            .textField("Layer Pin")
            .textOffset(x: 0, y: 1.2)
            .textColor(.black)
            .textHaloColor(.white)
            .textHaloWidth(1)
        GeoJSONSource(id: "symbols")
            .data(.geometry(.point(Point(Self.layerPin))))
        StyleImage(id: "marker", image: UIImage(named: "dest-pin")!)

        makeRoute(id: Self.alternativeRouteLayerId, coords: [
            CLLocationCoordinate2D(latitude: 37.7740, longitude: -122.4065),
            CLLocationCoordinate2D(latitude: 37.7751, longitude: -122.4061),
            CLLocationCoordinate2D(latitude: 37.7791, longitude: -122.3998),
            CLLocationCoordinate2D(latitude: 37.7762, longitude: -122.3939),
            CLLocationCoordinate2D(latitude: 37.7808, longitude: -122.3885),
            CLLocationCoordinate2D(latitude: 37.7867, longitude: -122.3879),
        ], alternative: true)

        makeRoute(id: Self.routeLayerId, coords: [
            CLLocationCoordinate2D(latitude: 37.7740, longitude: -122.4065),
            CLLocationCoordinate2D(latitude: 37.7751, longitude: -122.4061),
            CLLocationCoordinate2D(latitude: 37.7791, longitude: -122.3998),
            CLLocationCoordinate2D(latitude: 37.7791, longitude: -122.3998),
            CLLocationCoordinate2D(latitude: 37.7871, longitude: -122.3896),
        ])
    }

    @MapContentBuilder
    func makeRoute(id: String, coords: [CLLocationCoordinate2D], alternative: Bool = false) -> some MapContent {
        GeoJSONSource(id: id)
            .data(.feature(Feature(geometry: .lineString(LineString(coords)))))
        LineLayer(id: id, source: id)
            .lineCap(.round)
            .lineJoin(.round)
            .lineWidth(10.0)
            .lineBorderWidth(2)
            .lineColor(alternative ? "#999999" : "#57A9FB")
            .lineBorderColor(alternative ? "#666666" : "#327AC2")
            .slot(.middle)
    }
}

private struct MiniToggle: View {
    init(_ title: String, isOn: Binding<Bool>) {
        self.title = title
        self._isOn = isOn
    }
    var title: String
    @Binding var isOn: Bool
    var body: some View {
        HStack(spacing: 0) {
            Text(title)
            Spacer()
            Toggle(isOn: $isOn) { EmptyView() }
                .scaleEffect(0.7)
                .fixedSize()
                .padding(.bottom, -5)
        }
    }
}
