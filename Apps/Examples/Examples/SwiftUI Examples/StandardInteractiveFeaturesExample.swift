import SwiftUI
@_spi(Experimental) import MapboxMaps

@available(iOS 14, *)
struct StandardInteractiveFeaturesExample: View {
    @State var selectedPoi: StandardPoiFeature?
    @State var selectedBuildings = [StandardBuildingsFeature]()
    @State var selectedPlace: StandardPlaceLabelsFeature?
    @State var lightPreset = StandardLightPreset.day
    @State var theme = StandardTheme.default
    @State var buildingSelectColor = StyleColor("hsl(214, 94%, 59%)") // default color

    private struct PropView: View {
        var key: String
        var prop: String?
        var body: some View {
            if let prop {
                Text("\(key): \(prop)")
            }
        }
    }

    var body: some View {
        let cameraCenter = CLLocationCoordinate2D(latitude: 60.1718, longitude: 24.9453)
        MapReader { proxy in
            Map(initialViewport: .camera(center: cameraCenter, zoom: 16.35, bearing: 49.92, pitch: 40)) {
                if let selectedPoi {
                    /// When there is a currently selected poi: (1) display the PinView as a ViewAnnotation.
                    MapViewAnnotation(coordinate: selectedPoi.coordinate) {
                        PinView(text: selectedPoi.name ?? "", type: selectedPoi.class)
                            .id(selectedPoi.id)
                    }
                    .allowZElevate(true)
                    .variableAnchors([
                        ViewAnnotationAnchorConfig(anchor: .top, offsetX: 0, offsetY: 50)
                    ])

                    /// And (2): Hide the selected POI via feature state.
                    FeatureState(selectedPoi, .init(hide: true))
                }

                /// Each selected building is colored using the `selected` state.
                ForEvery(selectedBuildings, id: \.id) { building in
                    FeatureState(building, .init(select: true))
                }

                if let selectedPlace {
                    FeatureState(selectedPlace, .init(select: true))
                }

                /// When the POI featureset is tapped, set that feature as selected.
                TapInteraction(.standardPoi) { poi, _ in
                    selectedPoi = poi

                    /// Query all buildings in the viewport that are below the selected POI coordinate (distance between poi and building footprint <= 0).
                    proxy.map?.queryRenderedFeatures(
                        featureset: .standardBuildings,
                        filter: Exp(.lte) {
                            Exp(.distance) { poi.geometry.geoJSONObject }
                            0
                        }) { result in
                            switch result {
                            case .success(let features):
                                // TODO: MAPSIOS-1596 Fix crash in ForEvery for buildings with the same id.
                                self.selectedBuildings = features
                            case .failure(let failure):
                                print("error: \(failure)")
                            }
                    }
                    return true
                }

                TapInteraction(.standardPlaceLabels) { placeLabel, _ in
                    selectedPlace = placeLabel
                    return true
                }

                /// When the map is tapped, besides the feature, reset the selection.
                TapInteraction { _ in
                    selectedBuildings = []
                    selectedPoi = nil
                    selectedPlace = nil

                    return true
                }
            }
            /// DON'T USE Standard Experimental style in production, it will break over time.
            /// Currently this feature is in preview.
            .mapStyle(.standardExperimental(theme: theme, lightPreset: lightPreset, buildingSelectColor: buildingSelectColor))
        }
        .ignoresSafeArea()
        /// Debug panel
        .safeOverlay(alignment: .bottom) {
            VStack(alignment: .leading) {
                if let selectedPoi {
                    VStack(alignment: .leading) {
                        PropView(key: "name", prop: selectedPoi.name)
                        PropView(key: "group", prop: selectedPoi.group)
                        PropView(key: "class", prop: selectedPoi.class)
                        PropView(key: "maki", prop: selectedPoi.maki)
                        PropView(key: "transitMode", prop: selectedPoi.transitMode)
                        PropView(key: "transitStopType", prop: selectedPoi.transitStopType)
                        PropView(key: "transitNetwork", prop: selectedPoi.transitNetwork)
                        PropView(key: "airportRef", prop: selectedPoi.airportRef)
                    }
                    .floating()
                    .font(.safeMonospaced)
                }
                if let selectedPlace {
                    VStack(alignment: .leading) {
                        PropView(key: "name", prop: selectedPlace.name)
                        PropView(key: "class", prop: selectedPlace.class)
                    }
                    .floating()
                    .font(.safeMonospaced)
                }
                VStack {
                    HStack {
                        Text("Building Select")
                        Picker("Building Select", selection: $buildingSelectColor) {
                            Text("Default").tag(StyleColor("hsl(214, 94%, 59%)"))
                            Text("Yellow").tag(StyleColor("yellow"))
                            Text("Red").tag(StyleColor(.red))
                        }.pickerStyle(.segmented)
                    }
                    HStack {
                        Text("Light")
                        Picker("Light", selection: $lightPreset) {
                            Text("Dawn").tag(StandardLightPreset.dawn)
                            Text("Day").tag(StandardLightPreset.day)
                            Text("Dusk").tag(StandardLightPreset.dusk)
                            Text("Night").tag(StandardLightPreset.night)
                        }.pickerStyle(.segmented)
                    }
                    HStack {
                        Text("Theme")
                        Picker("Theme", selection: $theme) {
                            Text("Default").tag(StandardTheme.default)
                            Text("Faded").tag(StandardTheme.faded)
                            Text("Monochrome").tag(StandardTheme.monochrome)
                        }.pickerStyle(.segmented)
                    }
                }
                .floating()
            }
        }
    }
}
