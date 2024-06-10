import SwiftUI
@_spi(Experimental) import MapboxMaps

@available(iOS 14.0, *)
struct DynamicStylingExample: View {
    enum CityCollection: CaseIterable {
        case northern
        case southern
    }

    enum PinIcon: CaseIterable {
        case blue
        case red
        var image: UIImage {
            switch self {
            case .blue: Self.bluePin
            case .red: Self.redPin
            }
        }
        private static let bluePin = UIImage(named: "intermediate-pin")!
        private static let redPin = UIImage(named: "dest-pin")!
    }

    @State var connectionKind = ConnectionComponent.Kind.line
    @State var settingsHeight = 0.0
    @State var styleTransitions = false
    @State var cities = CityCollection.northern
    @State var pinFeatures: FeaturesRef?
    @State var connectionFeatures: FeaturesRef?
    @State var route: FeaturesRef?
    @State var mapStyle = MapStyle.standard
    @State var connectionColor = UIColor.blue
    @State var customLights = false
    @State var customAtmosphere = false
    @State var pinIcon: PinIcon = .blue
    @State var viewport: Viewport = .exampleOverview

    var body: some View {
        Map(viewport: $viewport) {
            if customAtmosphere {
                Atmosphere()
                    .range(start: 0, end: 12)
                    .horizonBlend(0.1)
                    .starIntensity(0.2)
                    .color(StyleColor(red: 240, green: 196, blue: 152, alpha: 1)!)
                    .highColor(StyleColor(red: 221, green: 209, blue: 197, alpha: 1)!)
                    .spaceColor(StyleColor(red: 153, green: 180, blue: 197, alpha: 1)!)
            }

            if customLights {
                DirectionalLight(id: "directional-light")
                    .intensity(0.5)
                    .direction(azimuthal: 210, polar: 30)
                    .directionTransition(.zero)
                    .castShadows(true)
                    .shadowIntensity(1)
                AmbientLight(id: "ambient-light")
                    .color(.lightGray)
                    .intensity(0.5)
            }

            if let connectionFeatures {
                ConnectionComponent(data: connectionFeatures, kind: connectionKind, color: connectionColor)
            }

            if let pinFeatures {
                LazyGeoJSON(id: "points", features: pinFeatures)
                StyleImage(id: "pin-icon", image: pinIcon.image)
                SymbolLayer(id: "pin", source: "points")
                    .iconImage("pin-icon")
                if styleTransitions {
                    TransitionOptions(duration: 5)
                }
            }

            if let route {
                RouteLine(id: "LA-SF", featureRef: route)
            }

            ModelsComponent()
        }
        .mapStyle(mapStyle)
        .additionalSafeAreaInsets(.bottom, settingsHeight)
        .onLayerTapGesture("connection-fill") { _, _ in
            connectionColor = .random
            return true
        }
        .debugOptions(.camera)
        .ignoresSafeArea()
        .safeOverlay(alignment: .bottom) {
            settingsBody
                .onChangeOfSize { settingsHeight = $0.height }
        }
        .safeOverlay(alignment: .trailing) {
            MapStyleSelectorButton(mapStyle: $mapStyle)
        }
        .onChange(of: cities) { _ in updateFeatures() }
        .onAppear {
            updateFeatures()
            loadRoute()
            connectionColor = .random
        }
        .toolbar {
            ToolbarItem {
                Menu {
                    Button("Overview") { viewport = .exampleOverview }
                    Button("Models") { viewport = .modelsOverview }
                    Button("Route") { viewport = .routeOverview }
                } label: {
                    Text("Jump to...")
                }
            }
        }
    }

    @ViewBuilder
    private var settingsBody: some View {
        VStack(alignment: .leading) {
            RadioButtonSettingView(title: "Cities", value: $cities)
            HStack {
                RadioButtonSettingView(title: "Connection", value: $connectionKind)

                Button(action: { connectionColor = .random }) {
                    ZStack {
                        Circle().fill(Color(connectionColor))
                        Circle().strokeBorder(Color(connectionColor.darker), lineWidth: 2)
                    }
                }
                .frame(width: 30, height: 30)
            }
            RadioButtonSettingView(title: "Pin Icon", value: $pinIcon)

            Toggle("Custom Atmosphere", isOn: $customAtmosphere)
            Toggle("Custom Lights", isOn: $customLights)
            Toggle("Transition styles slowly", isOn: $styleTransitions)
        }
        .padding(10)
        .floating(RoundedRectangle(cornerRadius: 10))
        .limitPaneWidth()
    }

    private func updateFeatures() {
        self.pinFeatures = cities.pinFeatures
        self.connectionFeatures = cities.connectionFeatures
    }

    private func loadRoute() {
        Task {
            let route = Bundle.main.url(forResource: "route", withExtension: "geojson")
                .flatMap { url in try? Data(contentsOf: url) }
                .flatMap { data in try? JSONDecoder().decode(Feature.self, from: data) }
                .map { feature in FeaturesRef([feature]) }
            Task { @MainActor in
                self.route = route
            }
        }
    }
}

@available(iOS 13.0, *)
struct ConnectionComponent: MapStyleContent {
    enum Kind: String, CaseIterable {
        case line
        case polygon
        case none
    }

    var data: FeaturesRef
    var kind: Kind
    var color: UIColor

    var body: some MapStyleContent {
        if kind != .none {
            LazyGeoJSON(id: "connection", features: data)
        }

        let transition = StyleTransition(duration: 0.1, delay: 0)

        switch kind {
        case .line:
            LineLayer(id: "connection-line", source: "connection")
                .lineColor(color)
                .lineWidth(10)
                .lineJoin(.round)
                .lineOpacity(0.8)
                .lineBorderColor(color.darker)
                .lineBorderWidth(2)
                .lineColorTransition(transition)
        case .polygon:
            FillLayer(id: "connection-fill", source: "connection")
                .fillColor(color)
                .fillOpacity(0.8)
                .fillColorTransition(transition)
            LineLayer(id: "connection-fill-stroke", source: "connection")
                .lineColor(color.darker)
                .lineWidth(2)
                .lineCap(.round)
                .lineColorTransition(transition)
        case .none:
            EmptyMapStyleContent()
        }
    }
}

/// Implements the route line component
@available(iOS 13.0, *)
struct RouteLine: MapStyleContent {
    var id: String
    var featureRef: FeaturesRef

    var body: some MapStyleContent {
        let sourceId = "route-\(id)"

        LazyGeoJSON(id: sourceId, features: featureRef)

        LineLayer(id: "\(sourceId)-layer", source: sourceId)
            .lineCap(.round)
            .lineJoin(.round)
            .lineWidth(10)
            .lineBorderWidth(2)
            .lineColor("#57A9FB")
            .lineBorderColor("#327AC2")
            .lineEmissiveStrength(1)
            .slot("middle")

        LineLayer(id: "\(sourceId)-layer-casing", source: sourceId)
            .lineCap(.round)
            .lineJoin(.round)
            .lineWidth(10)
            .lineBorderWidth(2)
            .lineColor("#57A9FB")
            .lineBorderColor("#327AC2")
            .lineEmissiveStrength(1)
            .slot("middle")
    }
}

/// Implements a GeoJSON source that is updated when the reference to features is changed.
@available(iOS 13.0, *)
struct LazyGeoJSON: MapStyleContent {
    let id: String
    let features: FeaturesRef

    var body: some MapStyleContent {
        // The body gets called and the GeoJSON source data is updated only when the `features` reference is changed.
        GeoJSONSource(id: id)
            .data(.featureCollection(FeatureCollection(features: features.features)))
    }
}

/// A reference wrapper over the array of features.
class FeaturesRef {
    let features: [Feature]
    init(_ features: [Feature]) { self.features = features }
}

@available(iOS 13.0, *)
struct ModelsComponent: MapStyleContent {
    var body: some MapStyleContent {
        /// Add models
        Model(
            id: "duck",
            uri: URL(string: "https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/Duck/glTF-Embedded/Duck.gltf")!
        )
        Model(
            id: "car",
            uri: Bundle.main.url(forResource: "sportcar", withExtension: "glb")!
        )

        /// Add a GeoJSONSource
        GeoJSONSource(id: "models-geojson")
            .data(.featureCollection(ducksFeatures))

        /// Add a Model visualization layer which displays the two models stored in the GeoJSONSource according to the set properties
        ModelLayer(id: "models", source: "models-geojson")
            .modelId(Exp(.get) { "model" })
            .modelType(.common3d)
            .modelScale(x: 40, y: 40, z: 40)
            .modelTranslation(x: 0, y: 0, z: 0)
            .modelRotation(x: 0, y: 0, z: 90)
            .modelOpacity(0.7)
    }

    var ducksFeatures: FeatureCollection {
        let mapboxHelsinki = Point(CLLocationCoordinate2D(latitude: 60.17195694011002, longitude: 24.945389069265598))
        let duckCoordinates = Point(CLLocationCoordinate2D(latitude: mapboxHelsinki.coordinates.latitude + 0.002, longitude: mapboxHelsinki.coordinates.longitude - 0.002))
        var duckFeature = Feature(geometry: duckCoordinates)
        duckFeature.properties = ["model": .string("duck")]
        var carFeature = Feature(geometry: mapboxHelsinki)
        carFeature.properties = ["model": .string("car")]
        return FeatureCollection(features: [duckFeature, carFeature])
    }
}

@available(iOS 14.0, *)
extension DynamicStylingExample.CityCollection {
    var pinFeatures: FeaturesRef {
        switch self {
        case .northern:
            FeaturesRef([
                Feature(geometry: .point(Point(.london))),
                Feature(geometry: .point(Point(.berlin))),
                Feature(geometry: .point(Point(.helsinki))),
            ])
        case .southern:
            FeaturesRef([
                Feature(geometry: .point(Point(.kyiv))),
                Feature(geometry: .point(Point(.tunis))),
                Feature(geometry: .point(Point(.barcelona))),
            ])
        }
    }

    var connectionFeatures: FeaturesRef {
        switch self {
        case .northern:
            FeaturesRef([Feature(geometry: .polygon(Polygon(outerRing: Ring(coordinates: [.london, .berlin, .helsinki]))))])
        case .southern:
            FeaturesRef([Feature(geometry: .polygon(Polygon(outerRing: Ring(coordinates: [.kyiv, .tunis, .barcelona]))))])
        }
    }
}

@available(iOS 13.0, *)
private struct RadioButtonSettingView<Value>: View
where Value: CaseIterable, Value: Hashable, Value.AllCases: RandomAccessCollection {
    var title: String
    var value: Binding<Value>

    var body: some View {
        HStack {
            Text(title)
            Picker(title, selection: value) {
                ForEach(Value.allCases, id: \.self) { t in
                    Text(String(describing: t).capitalized).tag(t)
                }
            }.pickerStyle(.segmented)
        }
    }
}

@available(iOS 13.0, *)
private extension Viewport {
    static var exampleOverview: Viewport = .camera(center: .init(latitude: 46.80, longitude: 11.18), zoom: 3, pitch: 45)
    static var modelsOverview: Viewport = .camera(center: .init(latitude: 60.172, longitude: 24.94), zoom: 13.32, pitch: 45)
    static var routeOverview: Viewport = .camera(center: .init(latitude: 36.9, longitude: -120.4), zoom: 4.75, pitch: 0)
}
