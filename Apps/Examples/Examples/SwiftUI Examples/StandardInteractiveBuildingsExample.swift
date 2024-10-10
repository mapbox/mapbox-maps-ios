import SwiftUI
@_spi(Experimental) import MapboxMaps

@available(iOS 14, *)
struct StandardInteractiveBuildingsExample: View {
    @State var selectedBuildings = [StandardBuildingsFeature]()
    @State var lightPreset = StandardLightPreset.day
    @State var theme = StandardTheme.default
    @State var buildingSelectColor = StyleColor("hsl(214, 94%, 59%)") // default color

    var body: some View {
        let cameraCenter = CLLocationCoordinate2D(latitude: 60.1718, longitude: 24.9453)
        Map(initialViewport: .camera(center: cameraCenter, zoom: 16.35, bearing: 49.92, pitch: 40)) {
            /// Each selected building is colored using the `selected` state.
            ForEvery(selectedBuildings, id: \.id) { building in
                FeatureState(building, .init(select: true))
            }

            /// When the user taps the building, it is added to the list of selected buildings.
            TapInteraction(.standardBuildings) { building, _ in
                self.selectedBuildings.append(building)
                return true
            }

            /// Tapping anywhere away from a 3D building will deselect previously selected buildings.
            TapInteraction { _ in
                selectedBuildings.removeAll()
                return true
            }
        }
        /// DON'T USE Standard Experimental style in production, it will break over time.
        /// Currently this feature is in preview.
        .mapStyle(.standardExperimental(theme: theme, lightPreset: lightPreset, buildingSelectColor: buildingSelectColor))
        .ignoresSafeArea()
        /// Debug panel
        .safeOverlay(alignment: .bottom) {
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
