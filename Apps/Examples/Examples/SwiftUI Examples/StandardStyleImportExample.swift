import SwiftUI
import MapboxMaps

@available(iOS 14.0, *)
struct StandardStyleImportExample: View {
    @State private var lightPreset: StandardLightPreset? = .night
    @State private var theme: StandardTheme? = .default
    @State private var showLabels = true
    @State private var priceAlertMessage: String?
    @State private var panelHeight: CGFloat = 0
    @State private var showRealEstate = false
    @State private var show3DObjects = true

    var body: some View {
        Map(initialViewport: .camera(center: .init(latitude: 40.72, longitude: -73.99), zoom: 11, pitch: 45)) {
            StyleImport(style: .standard(
                theme: theme,
                lightPreset: lightPreset,
                showPointOfInterestLabels: showLabels,
                showTransitLabels: showLabels,
                showPlaceLabels: showLabels,
                showRoadLabels: showLabels,
                show3dObjects: show3DObjects)
            )

            if showRealEstate {
                StyleImport(uri: StyleURI(url: styleURL)!)
            }
        }
        .mapStyle(.empty)
        .additionalSafeAreaInsets(.bottom, panelHeight)
        .ignoresSafeArea()
        .safeOverlay(alignment: .bottom) {
            settingsPanel.onChangeOfSize { panelHeight = $0.height }
        }
        .simpleAlert(message: $priceAlertMessage)
    }

    @ViewBuilder
    var settingsPanel: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Theme")
                Picker("Theme", selection: $theme) {
                    Text("Default").tag(Optional(StandardTheme.default))
                    Text("Faded").tag(Optional(StandardTheme.faded))
                    Text("Monochrome").tag(Optional(StandardTheme.monochrome))
                }.pickerStyle(.segmented)
            }
            HStack {
                Text("Light")
                Picker("Light preset", selection: $lightPreset) {
                    Text("Dawn").tag(Optional(StandardLightPreset.dawn))
                    Text("Day").tag(Optional(StandardLightPreset.day))
                    Text("Dusk").tag(Optional(StandardLightPreset.dusk))
                    Text("Night").tag(Optional(StandardLightPreset.night))
                    Text("None").tag(Optional<StandardLightPreset>.none)
                }.pickerStyle(.segmented)
            }
            Toggle("Labels", isOn: $showLabels)
            Toggle("Show Real Estate", isOn: $showRealEstate)
            Toggle("Show 3D Objects", isOn: $show3DObjects)
        }
        .padding(10)
        .floating(RoundedRectangle(cornerRadius: 10))
        .limitPaneWidth()
    }
}

private let styleURL = Bundle.main.url(forResource: "fragment-realestate-NY", withExtension: "json")!

@available(iOS 14.0, *)
struct StandardStyleImportExample_Previews: PreviewProvider {
    static var previews: some View {
        StandardStyleImportExample()
    }
}
