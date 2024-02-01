import SwiftUI
@_spi(Experimental) import MapboxMaps

@available(iOS 14.0, *)
struct StandardStyleImportExample: View {
    @State private var lightPreset: StandardLightPreset = .night
    @State private var showLabels = true
    @State private var priceAlertMessage: String?
    @State private var panelHeight: CGFloat = 0

    var style: MapStyle {
        let styleURI = StyleURI(url: styleURL)!
        return MapStyle(
            uri: styleURI,
            importConfigurations: [
                // The 'fragment-realestate-NY.json' style imports standard style with "standard" import id.
                // Here we specify import config to that style.
                .standard(
                    importId: "standard",
                    lightPreset: lightPreset,
                    showPointOfInterestLabels: showLabels,
                    showTransitLabels: showLabels,
                    showPlaceLabels: showLabels,
                    showRoadLabels: showLabels)
            ]
        )
    }

    var body: some View {
        Map(initialViewport: .camera(center: .init(latitude: 40.72, longitude: -73.99), zoom: 11, pitch: 45))
            .mapStyle(style)
            .onLayerTapGesture("NY-hotels-price") { queriedFeature, _ in
                // Show house price by tap to the 'NY-hotels-price' layer defined in 'fragment-realestate-NY.json' style.
                // The QueriedFeature represents the rendered GeoJSON feature that was tapped.
                guard let price = queriedFeature.feature.properties?["price"],
                      case .number(let priceNum) = price else { return true }
                priceAlertMessage = "Price: $\(String(format: "%.2f", priceNum))"
                return true
            }
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
                Text("Light")
                Picker("Light preset", selection: $lightPreset) {
                    Text("Dawn").tag(StandardLightPreset.dawn)
                    Text("Day").tag(StandardLightPreset.day)
                    Text("Dusk").tag(StandardLightPreset.dusk)
                    Text("Night").tag(StandardLightPreset.night)
                }.pickerStyle(.segmented)
            }
            Toggle("Labels", isOn: $showLabels)
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
