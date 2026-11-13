import SwiftUI
@_spi(Experimental) @_spi(Restricted) import MapboxMaps

/// Demonstrates the consolidated logo/attribution control in a SwiftUI map.
///
/// Use `.ornamentOptions(_:)` with a non-nil `consolidatedAttribution` value to opt in.
struct ConsolidatedAttributionSwiftUIExample: View {

    private enum Mode: Int {
        case legacy, consolidated
    }

    /// Each style brings a different set of data
    /// providers, and therefore a different attribution list.
    private enum Style: String, CaseIterable {
        case standard, standardSatellite, light, dark, streets, satelliteStreets, outdoors, manyAttributions, oneAttribution

        var title: String {
            switch self {
            case .standard: return "Standard"
            case .standardSatellite: return "Standard Satellite"
            case .light: return "Light"
            case .dark: return "Dark"
            case .streets: return "Streets"
            case .satelliteStreets: return "Satellite Streets"
            case .outdoors: return "Outdoors"
            case .manyAttributions: return "Many attributions"
            case .oneAttribution: return "One attribution(no link)"
            }
        }

        var mapStyle: MapStyle {
            switch self {
            case .standard: return .standard
            case .standardSatellite: return .standardSatellite
            case .light: return .light
            case .dark: return .dark
            case .streets: return .streets
            case .satelliteStreets: return .satelliteStreets
            case .outdoors: return .outdoors
            case .manyAttributions: return MapStyle(json: manyAttributionsStyleJSON)
            case .oneAttribution: return MapStyle(json: soleNonActionableAttributionStyleJSON)
            }
        }
    }

    @State private var mode: Mode = .consolidated
    @State private var position: OrnamentPosition = .bottomLeft
    @State private var collapsedStyle: ConsolidatedAttributionCollapsedStyle = .iconAndWordmark
    @State private var material: ConsolidatedAttributionMaterial = .solid
    @State private var tint: Color?
    @Environment(\.colorScheme) private var systemColorScheme
    @State private var appearance: ColorScheme?
    @State private var style: Style = .standard

    private var ornamentOptions: OrnamentOptions {
        OrnamentOptions(
            consolidatedAttribution: mode == .consolidated
                ? ConsolidatedAttributionOptions(
                    position: position,
                    introExpansion: .everyLaunch,
                    collapsedStyle: collapsedStyle,
                    material: material,
                    tintColor: tint.map { UIColor($0) }
                )
                : nil
        )
    }

    var body: some View {
        Map(
            initialViewport: .camera(
                center: CLLocationCoordinate2D(latitude: 37.788, longitude: -122.408),
                zoom: 13
            ),
            urlOpener: { url in UIApplication.shared.open(url) },
            content: { }
        )
        .mapStyle(style.mapStyle)
        .ornamentOptions(ornamentOptions)
        .environment(\.colorScheme, appearance ?? systemColorScheme)
        .ignoresSafeArea(edges: [.top, .horizontal])
        .safeAreaInset(edge: .bottom) { controlsPanel }
    }

    // MARK: - Controls panel

    private var controlsPanel: some View {
        VStack(spacing: 12) {
            modePicker
            stylePicker
            if mode == .consolidated {
                positionPicker
                collapsedStylePicker
                materialPicker
                appearancePicker
                tintPicker
            }
        }
        .padding(16)
        .background(.regularMaterial)
    }

    private var modePicker: some View {
        Picker("Mode", selection: $mode) {
            Text("Legacy").tag(Mode.legacy)
            Text("Consolidated").tag(Mode.consolidated)
        }
        .pickerStyle(.segmented)
    }

    private var stylePicker: some View {
        HStack {
            Text("Style")
            Spacer()
            Picker("Style", selection: $style) {
                ForEach(Style.allCases, id: \.self) { style in
                    Text(style.title).tag(style)
                }
            }
            .pickerStyle(.menu)
        }
    }

    private var positionPicker: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Position")
                .font(.caption)
                .foregroundStyle(.secondary)
            Picker("Position", selection: $position) {
                Text("↙ BL").tag(OrnamentPosition.bottomLeft)
                Text("↘ BR").tag(OrnamentPosition.bottomRight)
                Text("↖ TL").tag(OrnamentPosition.topLeft)
                Text("↗ TR").tag(OrnamentPosition.topRight)
            }
            .pickerStyle(.segmented)
        }
    }

    private var collapsedStylePicker: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Collapsed style")
                .font(.caption)
                .foregroundStyle(.secondary)
            Picker("Collapsed style", selection: $collapsedStyle) {
                Text("Icon only").tag(ConsolidatedAttributionCollapsedStyle.iconOnly)
                Text("Icon + wordmark").tag(ConsolidatedAttributionCollapsedStyle.iconAndWordmark)
            }
            .pickerStyle(.segmented)
        }
    }

    private var materialPicker: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Material")
                .font(.caption)
                .foregroundStyle(.secondary)
            Picker("Material", selection: $material) {
                Text("Solid").tag(ConsolidatedAttributionMaterial.solid)
                Text("Translucent").tag(ConsolidatedAttributionMaterial.translucent)
            }
            .pickerStyle(.segmented)
        }
    }

    private var tintPicker: some View {
        HStack(spacing: 8) {
            Text("Tint")
            Spacer()
            ForEach(Self.tintPresets, id: \.description) { preset in
                Button {
                    tint = preset
                } label: {
                    Circle()
                        .fill(preset)
                        .frame(width: 20, height: 20)
                        .overlay(Circle().strokeBorder(tint == preset ? .primary : .secondary,
                                                       lineWidth: tint == preset ? 2 : 0.5))
                }
                .buttonStyle(.plain)
            }
            ColorPicker("Tint color", selection: tintBinding, supportsOpacity: false)
                .labelsHidden()
        }
    }

    private var tintBinding: Binding<Color> {
        Binding(get: { tint ?? .blue }, set: { tint = $0 })
    }

    private static let tintPresets: [Color] = [.blue, .green, .orange, .pink, .purple]

    private var appearancePicker: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Interface style")
                .font(.caption)
                .foregroundStyle(.secondary)
            Picker("Interface style", selection: $appearance) {
                Text("System").tag(ColorScheme?.none)
                Text("Light").tag(ColorScheme?.some(.light))
                Text("Dark").tag(ColorScheme?.some(.dark))
            }
            .pickerStyle(.segmented)
        }
    }
}

private let manyAttributionsStyleJSON: String = {
    let attributions = [
        #"<a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>"#,
        #"<a href="https://www.mapbox.com/about/maps/">Mapbox</a>"#,
        #"<a href="https://www.mapbox.com/feedback/">Improve this map</a>"#,
        #"<a href="https://www.maxar.com/">Maxar</a>"#,
        #"<a href="https://www.naturalearthdata.com/">Natural Earth</a>"#,
        #"<a href="https://www.usgs.gov/">U.S. Geological Survey</a>"#,
        #"<a href="https://www.noaa.gov/">NOAA</a>"#,
        #"<a href="https://www.eea.europa.eu/">European Environment Agency</a>"#,
        #"<a href="https://datasf.org/opendata/">City and County of San Francisco Open Data</a>"#,
        "NoLinkProvider",
    ]

    let sources = attributions.enumerated().map { index, attribution in
        let escaped = attribution.replacingOccurrences(of: "\"", with: "\\\"")
        return """
            "attribution-source-\(index)": {
                "type": "geojson",
                "attribution": "\(escaped)",
                "data": { "type": "FeatureCollection", "features": [] }
            }
            """
    }.joined(separator: ",\n")

    return """
        {
            "version": 8,
            "imports": [{ "id": "basemap", "url": "mapbox://styles/mapbox/standard" }],
            "sources": { \(sources) },
            "layers": []
        }
        """
}()

private let soleNonActionableAttributionStyleJSON: String = {
        let source =  """
            "attribution-source": {
                "type": "geojson",
                "attribution": "Not linked attribution",
                "data": { "type": "FeatureCollection", "features": [] }
            }
            """

    return """
        {
            "version": 8,
            "imports": [{ "id": "basemap", "url": "mapbox://styles/mapbox/standard" }],
            "sources": { \(source) },
            "layers": []
        }
        """
}()

struct ConsolidatedAttributionSwiftUIExample_Previews: PreviewProvider {
    static var previews: some View {
        ConsolidatedAttributionSwiftUIExample()
    }
}
