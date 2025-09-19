import SwiftUI
import MapboxMaps

class SearchContext: ObservableObject {
    @Published var query: String = ""
    @Published var debouncedQuery: String = ""

    init() {
        $query.debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .assign(to: &$debouncedQuery)
    }
}

typealias MapboxId = String

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedCategories: [POICategory] = []
    @State private var selectedFeature: FeaturesetFeature?
    @State private var searchTask: Task<Void, Error>?
    @StateObject private var searchContext = SearchContext()
    @StateObject private var favoritesManager = FavoritesManager()
    @StateObject private var visitManager = VisitManager()
    @State var viewport: Viewport = .camera(center: .london, zoom: 16, bearing: 12, pitch: 0)
    @State var proxy: MapProxy?
    @State var searchResults: [MapboxId]?
    @State private var isHotelsMode = false
    @State private var mapViewSize: CGSize = .zero
    @State var selectedBuilding: StandardBuildingsFeature?

    func filterString(for layer: String) -> Any {
        let categoryFilter = if selectedCategories.isEmpty {
            ["==", ["get", "category"], isHotelsMode ? "lodging" : "food_and_drink"]
        } else {
            ["in", ["get", "sub_category"], selectedCategories.map(\.id)]
        }

        let scoreFilter: Any = switch layer {
        case "poi top":
            [
                ">",
                ["get", "reality_score"],
                ["step", ["zoom"], 0.995, 14, 0.997, 17, 0.992],
            ]
        case "poi middle":
            if isHotelsMode {
                [
                    "any",
                    [">=", ["zoom"], 17],
                    [
                        ">",
                        [
                            "get",
                            "reality_score"
                        ],
                        [
                            "step",
                            ["zoom"],
                            0.9,
                            15,
                            0.89,
                            16,
                            0.88
                        ]
                    ]
                ]
            } else {
                if searchResults != nil || !selectedCategories.isEmpty {
                    true // show all
                } else {
                    [
                        "any",
                        [">=", ["zoom"], 18],
                        [
                            "all",
                            [
                                "<=",
                                ["get", "reality_score"],
                                ["step", ["zoom"], 0.999, 14, 0.997, 15, 0.995, 16, 0.99],
                            ],
                            [
                                ">",
                                ["get", "reality_score"],
                                ["step", ["zoom"], 0.8, 14, 0.9, 16, 0.91],
                            ],
                        ],
                    ]
                }
            }
        case "poi favorites":
            ["in", ["get", "mapbox_id"], favoritesManager.allFavoriteIds.isEmpty ? ["false"] : favoritesManager.allFavoriteIds]
        default: true
        }

        let categoryAndScoreFilter: [Any] = ["all", categoryFilter, scoreFilter]

        guard let searchResults else {
            return categoryAndScoreFilter
        }

        return ["all", ["in", ["get", "mapbox_id"], searchResults], categoryAndScoreFilter]
    }

    func performSearch(camera: CameraState) {
        searchTask?.cancel()

        let query = searchContext.debouncedQuery
        guard !query.isEmpty else {
            searchResults = nil
            return
        }

        searchTask = Task {
            do {
                try Task.checkCancellation()

                let searchResults = try await NetworkService.fetchSearchResults(query, location: camera.center, categories: selectedCategories)

                try Task.checkCancellation()

                let featureIds = searchResults.features.compactMap { (feature: Feature) -> String? in
                    guard case JSONValue.string(let mapboxId)?? = feature.properties?["mapbox_id"] else {
                        return nil
                    }
                    return mapboxId
                }

                self.searchResults = featureIds
            } catch is CancellationError {
                // Task was cancelled, ignore
                return
            } catch {
                print("Search failed: \(error)")
                self.searchResults = []
            }
        }
    }

    @ViewBuilder
    var searchView: some View {
        HStack {
            Image("search")
                .renderingMode(.template)
                .resizable()
                .frame(width: 26, height: 26)
                .foregroundColor(.secondary)
                .padding(.leading, 16)

            TextField("Search", text: $searchContext.query)
                .textFieldStyle(.plain)
                .font(.title2)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 8)
        .frame(minHeight: 55)
        .safeGlassEffectOrWhiteRoundedRect()
        .padding(.horizontal)
    }

    @ViewBuilder
    var mapView: Map {
        Map(viewport: $viewport) {
            VectorSource(id: "source")
                .url("mapbox://mapbox.mapbox-poi-v2")

            if let selectedBuilding {
                FeatureState(selectedBuilding, .init(select: true))
            }

            let visitedExpression = Exp(.inExpression) {
                Exp(.get) { "mapbox_id" }
                visitManager.allVisitedIds.isEmpty ? ["false"] : visitManager.allVisitedIds
            }
            let iconPrimaryColor = Exp(.switchCase) {
                visitedExpression
                "#9CAFED"
                "rgb(15, 56, 191)"
            }
            let textColor = Exp(.switchCase) {
                visitedExpression
                "#5373DF"
                "rgb(15, 56, 191)"
            }
            let hotelsTextColor = Exp(.switchCase) {
                visitedExpression
                "white"
                "white"
            }
            let hotelPrice = Exp(.concat) {
                Exp(.toString) {
                    Exp(.round) {
                        Exp(.random) {
                            1
                            5
                            Exp(.get) { "mapbox_id" }
                        }
                    }
                }
                Exp(.toString) {
                    Exp(.at) {
                        Exp(.round) {
                            Exp(.random) {
                                0
                                PinPoweredMapConstants.priceEndings.count - 1
                                Exp(.get) { "mapbox_id" }
                            }
                        }
                        PinPoweredMapConstants.priceEndings
                    }
                }
                " \(Locale.current.currencySymbol ?? "$")"
            }
            let hotelIcon = Exp(.image) {
                Exp(.concat) {
                    "price_"
                    Exp(.switchCase) {
                        Exp(.inExpression) {
                            Exp(.get) { "mapbox_id" }
                            favoritesManager.allFavoriteIds.isEmpty ? ["false"] : favoritesManager.allFavoriteIds
                        }
                        "fav_"
                        ""
                    }
                    "4"
                }
                ["params": ["color-1": iconPrimaryColor]]
            }

            SymbolLayer(id: "poi bottom", source: "source")
                .sourceLayer("poi")
                .textColor(.white)
                .textOffset(x: 0.3, y: 0.1)
                .textSize(15)
                .textFont(["Inter Bold", "Arial Unicode MS Regular"])
                .textField(
                    isHotelsMode ?
                    Exp(.switchCase) {
                        Exp(.inExpression) {
                            Exp(.get) { "mapbox_id" }
                            favoritesManager.allFavoriteIds.isEmpty ? ["false"] : favoritesManager.allFavoriteIds
                        }
                        hotelPrice
                        ""
                    }
                    : Exp(.literal) { "" }
                )
                .iconImage("marker")
            SymbolLayer(id: "poi middle", source: "source")
                .sourceLayer("poi")
                .textSize(13)
                .textFont([isHotelsMode ? "Inter Bold" : "Raleway SemiBold", "Arial Unicode MS Regular"])
                .textJustify(.left)
                .textAnchor(isHotelsMode ? .center : .left)
                .textOffset(x: isHotelsMode ? 0 : 1.1, y: isHotelsMode ? 0.1 : 0)
                .iconSize(isHotelsMode ? 1 : 0.6)
                .textField(isHotelsMode ? hotelPrice : Exp(.get) { "name" })
                .iconEmissiveStrength(0.9)
                .textColor(isHotelsMode ? hotelsTextColor : textColor)
                .textEmissiveStrength(0.8)
                .textHaloColor(StyleColor(rawValue: "rgb(255, 255, 255)"))
                .textHaloWidth(isHotelsMode ? 0 : 1)
                .iconImage(
                    isHotelsMode ?
                    hotelIcon
                    : Exp(.image) {
                        Exp(.concat) {
                            Exp(.get) { "icon" }
                            "_big"
                        }
                        ["params": ["color-1": iconPrimaryColor]]
                    }
                )

            if !isHotelsMode {
                SymbolLayer(id: "poi top", source: "source")
                    .sourceLayer("poi")
                    .textOptional(true)
                    .textSize(15)
                    .textFont(["Raleway SemiBold", "Arial Unicode MS Regular"])
                    .textJustify(.left)
                    .textOffset(x: 2.5, y: 0)
                    .textAnchor(.left)
                    .textField(
                        Exp(.concat) {
                            Exp(.get) { "name" }
                            "\n"
                            Exp(.get) { "sub_category" }
                        }
                    )
                    .iconEmissiveStrength(0.9)
                    .textColor(textColor)
                    .textEmissiveStrength(0.8)
                    .textHaloColor(StyleColor(rawValue: "rgb(255, 255, 255)"))
                    .textHaloWidth(1.5)
                    .iconImage(
                        Exp(.image) {
                            Exp(.concat) {
                                Exp(.get) { "icon" }
                                "_rating_"
                                Exp(.toString) {
                                    Exp(.numberFormat) {
                                        Exp(.at) {
                                            Exp(.mod) {
                                                Exp(.toNumber) { Exp(.id) }
                                                PinPoweredMapConstants.ratings.count
                                            }
                                            PinPoweredMapConstants.ratings
                                        }
                                        [ "min-fraction-digits": 1, "max-fraction-digits": 1, "locale": "en" ]
                                    }
                                }
                            }
                            ["params": ["color-1": iconPrimaryColor, "color-2": iconPrimaryColor]]
                        }
                    )
                TapInteraction(.layer("poi top"), action: selectFeature)
            }

            SymbolLayer(id: "poi favorites", source: "source")
                .sourceLayer("poi")
                .iconAllowOverlap(true)
                .textAllowOverlap(true)
                .textOptional(!isHotelsMode)
                .textSize(isHotelsMode ? 13 : 15)
                .textFont([isHotelsMode ? "Inter Bold" : "Raleway SemiBold", "Arial Unicode MS Regular"])
                .textJustify(.left)
                .textOffset(x: isHotelsMode ? 0.3 : 1.7, y: isHotelsMode ? 0.2 : 0.0)
                .textAnchor(isHotelsMode ? .center : .left)
                .textField(
                    isHotelsMode ? hotelPrice
                    : Exp(.concat) {
                        Exp(.get) { "name" }
                        "\n"
                        Exp(.get) { "sub_category" }
                    }
                )
                .iconEmissiveStrength(0.9)
                .textColor(isHotelsMode ? hotelsTextColor : textColor)
                .textEmissiveStrength(0.8)
                .textHaloColor(StyleColor(rawValue: "rgb(255, 255, 255)"))
                .textHaloWidth(isHotelsMode ? 0 : 1.5)
                .iconImage(
                    isHotelsMode ?
                    hotelIcon
                    : Exp(.image) {
                        Exp(.get) { "icon" }
                        ["params": ["color-1": iconPrimaryColor]]
                    }
                )
            TapInteraction(.layer("poi favorites"), action: selectFeature)

            TapInteraction(.layer("poi bottom"), action: selectFeature)
            TapInteraction(.layer("poi middle"), action: selectFeature)
        }
        .mapStyle(MapStyle(uri: StyleURI.pinPoweredMapStyle, configuration: ["lightPreset": colorScheme == .dark ? "night" : "day"]))
        .ornamentOptions(
            OrnamentOptions(
                scaleBar: .init(visibility: .hidden),
                compass: .init(visibility: .hidden),
                logo: .init(margins: CGPoint(x: 24, y: 0)),
                attributionButton: .init(margins: CGPoint(x: 14, y: -2))
            )
        )
    }

    private func selectFeature(_ feature: FeaturesetFeature, context: InteractionContext) -> Bool {
        guard case JSONValue.string(let mapboxId)?? = feature.properties["mapbox_id"] else {
            print("Failed to extract mapbox_id from feature")
            return false
        }
        withViewportAnimation {
            viewport = .camera(center: context.coordinate).padding(EdgeInsets(top: 0, leading: 0, bottom: mapViewSize.height * 0.4, trailing: 0))
        }
        let filter = Exp(.lte) {
            Exp(.distance) {
                GeoJSONObject.geometry(feature.geometry)
            }
            3
        }
        proxy?.map?.queryRenderedFeatures(featureset: .standardBuildings(importId: "basemap"), filter: filter) { result in
            selectedBuilding = try? result.get().first
        }
        visitManager.visitFeature(mapboxId)
        selectedFeature = feature
        return true
    }

    var body: some View {
        ZStack {
            MapReader { proxy in
                mapView
                    .onMapIdle(action: { _ in
                        if searchResults != nil {
                            performSearch(camera: proxy.map!.cameraState)
                        }
                    })
                    .onStyleLoaded(action: { _ in
                        self.proxy = proxy
                        for layerName in ["poi top", "poi middle", "poi bottom", "poi favorites"] {
                            let filterString = filterString(for: layerName)
                            try! proxy.map?.setLayerProperty(for: layerName, property: "filter", value: filterString)
                        }
                    })
                    .onChange(of: searchContext.debouncedQuery) { _ in
                        performSearch(camera: proxy.map!.cameraState)
                    }
                    .onChange(of: selectedCategories) { _ in
                        for layerName in ["poi top", "poi middle", "poi bottom", "poi favorites"] {
                            let filterString = filterString(for: layerName)
                            try? proxy.map?.setLayerProperty(for: layerName, property: "filter", value: filterString)
                        }
                    }
                    .onChange(of: searchResults) { _ in
                        for layerName in ["poi top", "poi middle", "poi bottom", "poi favorites"] {
                            let filterString = filterString(for: layerName)
                            try? proxy.map?.setLayerProperty(for: layerName, property: "filter", value: filterString)
                        }
                    }
                    .onChange(of: isHotelsMode) { newValue in
                        selectedBuilding = nil
                        if newValue {
                            searchContext.query = ""
                            selectedCategories = []
                        }
                        for layerName in ["poi top", "poi middle", "poi bottom", "poi favorites"] {
                            let filterString = filterString(for: layerName)
                            try? proxy.map?.setLayerProperty(for: layerName, property: "filter", value: filterString)
                        }
                    }
                    .onChange(of: favoritesManager.favoriteIds) { _ in
                        try? proxy.map?.setLayerProperty(for: "poi favorites", property: "filter", value: filterString(for: "poi favorites"))
                    }
                    .background {
                        GeometryReader { geometry in
                            Color.clear
                                .task(id: geometry.size.height) {
                                    mapViewSize = geometry.size
                                }
                        }
                    }
                    .ignoresSafeArea()
            }

            if !isHotelsMode {
                VStack {
                    Spacer()

                    VStack(spacing: 12) {
                        FilterView(selectedCategories: $selectedCategories)
                        searchView
                    }
                }
                .padding(.bottom, 32)
                .zIndex(8)
                .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .opacity))
            }
        }
        .sheet(item: $selectedFeature, content: { feature in
            ZStack {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedFeature = nil
                    }

                FeatureDetailsView(feature: feature, favoritesManager: favoritesManager, onDismiss: { selectedFeature = nil })
            }
            .presentationDetents([.fraction(0.4), .medium])
            .presentationDragIndicator(.visible)
            .interactiveDismissDisabled(false)
        })
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                SegmentedToggleView(isToggleOn: $isHotelsMode)
            }
        }
    }
}

extension View {
    fileprivate func safeGlassEffectOrWhiteRoundedRect() -> some View {
#if compiler(>=6.2)
        if #available(iOS 26.0, *) {
            return self.glassEffect()
        }
#endif

        return self
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(radius: 1.4, y: 0.7)
    }
}
