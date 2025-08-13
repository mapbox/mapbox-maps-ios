import SwiftUI
@_spi(Experimental) import MapboxMaps

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
        Map(initialViewport: .camera(center: cameraCenter, zoom: 16.35, bearing: 49.92, pitch: 40)) {
            /// 1.) Add tap interactions targeting featuresets in the Mapbox Standard style

            /// When a POI feature in the Standard POI featureset is tapped, set that feature as selected.
            TapInteraction(.standardPoi) { poi, _ in
                selectedPoi = poi
                return true /// Returning true stops propagation to features below or the map itself.
            }

            /// When a building in the Standard Buildings featureset is tapped, set that building as selected.
            TapInteraction(.standardBuildings) { building, _ in
                selectedBuildings.append(building)
                return true
            }

            /// When a place label in the Standard Place Labels featureset is tapped, set that place label as selected
            TapInteraction(.standardPlaceLabels) { placeLabel, _ in
                selectedPlace = placeLabel
                return true
            }

            /// When a landmark icon in the Standard Landmark Icons featureset is tapped, print its name
            TapInteraction(.standardLandmarkIcons) { landmarkIcon, _ in
                print(landmarkIcon.name?.description ?? "No name")
                return true
            }

            /// When the map is long-pressed, reset all selections
            LongPressInteraction { _ in
                selectedBuildings = []
                selectedPoi = nil
                selectedPlace = nil
                return true
            }

            /// 2.) Define behavior for POI, Building, and Place Label features when a user selects them

            /// Select POIs have the standard pin icon replaced by a more detailed icon. Additionally, information
            /// about the POI is displayed in a box in the lower left corner
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

            /// The selected label is colored and information about the place is displaed in the lower left corner
            if let selectedPlace {
                FeatureState(selectedPlace, .init(select: true))
            }
        }

        .mapStyle(.standard(theme: theme, lightPreset: lightPreset, colorBuildingSelect: buildingSelectColor, showLandmarkIcons: true))
        .ignoresSafeArea()
        /// Debug panel
        .overlay(alignment: .bottom) {
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
