import SwiftUI
@_spi(Experimental) import MapboxMaps

@available(iOS 14.0, *)
struct DynamicStylingExample: View {

    enum ConnectionType: String, CaseIterable {
        case line
        case polygon
    }

    enum CityCollection: CaseIterable {
        case northern
        case southern

        var pointFeatureCollection: FeatureCollection {
            switch self {
            case .northern:
                FeatureCollection(features: [
                    Feature(geometry: .point(Point(.london))),
                    Feature(geometry: .point(Point(.berlin))),
                    Feature(geometry: .point(Point(.helsinki))),
                ])
            case .southern:
                FeatureCollection(features: [
                    Feature(geometry: .point(Point(.kyiv))),
                    Feature(geometry: .point(Point(.tunis))),
                    Feature(geometry: .point(Point(.barcelona))),
                ])
            }
        }

        var lineFeatureCollection: FeatureCollection {
            switch self {
            case .northern:
                FeatureCollection(features: [
                    Feature(geometry: .lineString(LineString(Ring(coordinates: [.london, .berlin, .helsinki, .london]))))
                ])
            case .southern:
                FeatureCollection(features: [
                    Feature(geometry: .lineString(LineString(Ring(coordinates: [.kyiv, .tunis, .barcelona, .kyiv]))))
                ])
            }
        }
    }

    @Environment(\.verticalSizeClass) var sizeClass

    @State var connectionType = ConnectionType.line
    @State var showConnections = true
    @State private var settingsHeight = 0.0
    @State var cities = CityCollection.northern
    @State private var mapStyle = MapStyle.standard

    let pin = UIImage(named: "intermediate-pin")!

    var body: some View {
        MapReader { proxy in
            Map(initialViewport: .camera(center: .init(latitude: 46.80, longitude: 11.18), zoom: 3, pitch: 45))
                .mapStyle(mapStyle {
                    Atmosphere()
                        .range(.constant([0, 12]))
                        .horizonBlend(.constant(0.1))
                        .starIntensity(.constant(0.2))
                        .color(.constant(StyleColor(red: 240, green: 196, blue: 152, alpha: 1)!))
                        .highColor(.constant(StyleColor(red: 221, green: 209, blue: 197, alpha: 1)!))
                        .spaceColor(.constant(StyleColor(red: 153, green: 180, blue: 197, alpha: 1)!))

                    if showConnections {
                        GeoJSONSource(id: "lines")
                            .data(.featureCollection(cities.lineFeatureCollection))
                        switch connectionType {
                        case .line:
                            LineLayer(id: "lineLayer", source: "lines")
                                .lineColor(.constant(StyleColor(red: 195, green: 088, blue: 049, alpha: 1)!))
                                .lineWidth(.constant(20))
                        case .polygon:
                            FillLayer(id: "fill", source: "lines")
                                .fillColor(.constant(StyleColor(.blue)))
                                .fillOpacity(.constant(0.5))
                        }
                    }

                    GeoJSONSource(id: "points")
                        .data(.featureCollection(cities.pointFeatureCollection))
                    StyleImage(id: "pin", image: self.pin)
                    SymbolLayer(id: "pin", source: "points")
                            .iconImage(.constant(.name("pin")))
                })
                .additionalSafeAreaInsets(sidePanel ? .trailing : .bottom, settingsHeight)
                .ignoresSafeArea()
                .safeOverlay(alignment: sidePanel ? .trailing : .bottom) {
                    settingsBody
                        .frame(maxWidth: sidePanel ? 300 : .infinity)
                        .onChangeOfSize { settingsHeight = sidePanel ? $0.width : $0.height }
                }
                .safeOverlay(alignment: .trailing) {
                    MapStyleSelectorButton(mapStyle: $mapStyle)
                        .padding(.trailing, sidePanel ? 300 : 0)
                }
        }
    }

    var sidePanel: Bool {
        return sizeClass == .compact
    }

    @ViewBuilder
    private var settingsBody: some View {
        VStack(alignment: .leading) {
            RadioButtonSettingView(title: "Cities:", value: $cities)
            RadioButtonSettingView(title: "Connection Type:", value: $connectionType)
            Toggle("Show connections", isOn: $showConnections)
        }
        .padding(10)
        .floating(RoundedRectangle(cornerRadius: 10))
        .limitPaneWidth()
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

@available(iOS 14.0, *)
struct StyleDSLExample_Previews: PreviewProvider {
    static var previews: some View {
        DynamicStylingExample()
    }
}
