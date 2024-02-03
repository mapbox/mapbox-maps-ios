import SwiftUI
@_spi(Experimental) import MapboxMaps

@available(iOS 14.0, *)
struct PuckPlayground: View {
    enum PuckType: String, CaseIterable, CustomStringConvertible {
        case d2
        case d3
        var description: String {
            switch self {
            case .d2: return "2D"
            case .d3: return "3D"
            }
        }
    }

    @Environment(\.verticalSizeClass) var sizeClass

    @State private var puckType = PuckType.d2
    @State private var bearingType = PuckBearing.heading
    @State private var opacity = 1.0
    @State private var puck3dSettings = Puck3DSettings()
    @State private var puck2dSettings = Puck2DSettings()
    @State private var mapStyle = MapStyle.standard(lightPreset: .day)
    @State private var settingsHeight = 0.0

    var body: some View {
        Map(initialViewport: .followPuck(zoom: 18, bearing: .heading, pitch: 60)) {
            switch puckType {
            case .d2:
                Puck2D(bearing: bearingType)
                    .pulsing(puck2dSettings.pulsing.asPuckPulsing)
                    .showsAccuracyRing(puck2dSettings.accuracyRing)
                    .opacity(opacity)
                    .topImage(puck2dSettings.topImage.asPuckTopImage)
            case .d3:
                Puck3D(model: puck3dSettings.modelType.model, bearing: bearingType)
                    .modelScale(puck3dSettings.modelScale)
                    .modelOpacity(opacity)
                    .modelEmissiveStrength(puck3dSettings.emission)
            }
        }
        .mapStyle(mapStyle)
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
        .onChange(of: puckType) { newValue in
            if puckType == .d3 { // Switch to dusk mode to see model light emission
                mapStyle = .standard(lightPreset: .dusk)
            }
        }
    }

    var sidePanel: Bool {
        return sizeClass == .compact
    }

    @ViewBuilder
    private var settingsBody: some View {
        VStack(alignment: .leading) {
            RadioButtonSettingView(title: "Puck Type", value: $puckType)
            RadioButtonSettingView(title: "Bearing", value: $bearingType)
            SliderSettingView(title: "Opacity", value: $opacity, range: 0...1, step: 0.1)

            switch puckType {
            case .d2:
                VStack {
                    Toggle("Accuracy ring", isOn: $puck2dSettings.accuracyRing)
                    RadioButtonSettingView(title: "Pulsing", value: $puck2dSettings.pulsing)
                    RadioButtonSettingView(title: "Top Image", value: $puck2dSettings.topImage)
                }
            case.d3:
                RadioButtonSettingView(title: "Model", value: $puck3dSettings.modelType)
                SliderSettingView(title: "Scale", value: $puck3dSettings.scale, range: 1...3, step: 0.25)
                SliderSettingView(title: "Light emission", value: $puck3dSettings.emission, range: 0...2, step: 0.1)
            }
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

@available(iOS 13.0, *)
private struct SliderSettingView: View {
    var title: String
    @Binding var value: Double
    var range: ClosedRange<Double>
    var step: Double

    var body: some View {
        HStack {
            Text("\(title)")
            Slider(value: $value, in: range, step: step) {
            } minimumValueLabel: {
                Text("")
            } maximumValueLabel: {
                Text("\(String(format: "%.2f", value))")
                    .font(.system(size: 12))
            }

        }
    }
}

private struct Puck3DSettings {
    enum ModelType: String, CaseIterable {
        case sportcar
        case duck
        var model: Model {
            switch self {
            case .sportcar: return .sportcar
            case .duck: return .duck
            }
        }
        var initialScale: Double {
            switch self {
            case .sportcar: return 15
            case .duck: return 25
            }
        }
    }
    var scale = 1.0
    var modelScale: [Double] { .init(repeating: scale * modelType.initialScale, count: 3) }
    var modelType = ModelType.sportcar
    var emission = 1.0
}

private struct Puck2DSettings {
    enum Pulsing: String, CaseIterable {
        case none
        case accuracy
        case `default`
        var asPuckPulsing: Puck2DConfiguration.Pulsing {
            var pulsing = Puck2DConfiguration.Pulsing()
            switch self {
            case .none:
                pulsing.isEnabled = false
            case .accuracy:
                pulsing.radius = .accuracy
            case .`default`: ()
            }
            return pulsing
        }
    }
    enum TopImage: String, CaseIterable {
        case `default`
        case dash
        case jpeg

        var asPuckTopImage: UIImage? {
            switch self {
            case .default:
                return nil
            case .dash:
                return UIImage(named: "dash-puck")
            case .jpeg:
                return UIImage(named: "jpeg-image")
            }
        }
    }

    var bearing = true
    var accuracyRing = false
    var pulsing: Pulsing = .default
    var topImage: TopImage = .default
}

extension PuckBearing: CaseIterable {
    public static var allCases: [PuckBearing] = [.course, .heading]
}

private extension Model {
    static let sportcar = Model(
        uri: Bundle.main.url(forResource: "sportcar", withExtension: "glb"),
        orientation: [0, 0, 180] // orient source model to point the bearing property
    )
    static let duck = Model(
        uri: URL(string: "https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/Duck/glTF-Embedded/Duck.gltf")!,
        orientation: [0, 0, -90] // orient source model to point the bearing property
    )
}

@available(iOS 14.0, *)
struct PuckPlayground_Preview: PreviewProvider {
    static var previews: some View {
        PuckPlayground()
    }
}
