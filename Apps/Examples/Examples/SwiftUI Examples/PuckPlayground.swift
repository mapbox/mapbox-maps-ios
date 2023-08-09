import SwiftUI
@_spi(Experimental) import MapboxMaps

extension Puck2DConfiguration {
    static func makeDefault(
        showBearing: Bool,
        pulsing: Puck2DConfiguration.Pulsing,
        showAccuracyRing: Bool,
        opacity: Double
    ) -> Puck2DConfiguration {
        var config = Puck2DConfiguration.makeDefault(showBearing: showBearing)
        config.pulsing = pulsing
        config.showsAccuracyRing = showAccuracyRing
        config.opacity = opacity
        return config
    }
}

private struct Puck3DSettings {
    var scale = 15.0
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
    var bearing = true
    var accuracyRing = false
    var pulsing: Pulsing = .default
}

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
    @State private var puckType = PuckType.d2
    @State private var bearingType = PuckBearing.heading
    @State private var opacity = 1.0
    @State private var puck3dSettings = Puck3DSettings()
    @State private var puck2dSettings = Puck2DSettings()

    var body: some View {
        Map(initialViewport: .followPuck(zoom: 17, bearing: .heading, pitch: 60)) {
            switch puckType {
            case .d2:
                PuckAnnotation2D(bearing: bearingType) {
                    $0.pulsing = puck2dSettings.pulsing.asPuckPulsing
                    $0.showsAccuracyRing = puck2dSettings.accuracyRing
                    $0.opacity = opacity
                }
            case .d3:
                PuckAnnotation3D(model: sportCar, bearing: bearingType) {
                    $0.modelScale = .constant([puck3dSettings.scale, puck3dSettings.scale, puck3dSettings.scale])
                    $0.modelOpacity = .constant(opacity)
                }
            }
        }
        .ignoresSafeArea()
        .safeOverlay(alignment: .bottom) {
            settingsBody
        }
    }

    @ViewBuilder var settingsBody: some View {
        VStack(alignment: .leading) {
            RadioButtonSettingView(title: "Puck Type", value: $puckType)
            RadioButtonSettingView(title: "Bearing", value: $bearingType)
            SliderSettingView(title: "Opacity", value: $opacity, range: 0...1, step: 0.1)

            switch puckType {
            case .d2:
                VStack {
                    Toggle("Accuracy ring", isOn: $puck2dSettings.accuracyRing)
                    RadioButtonSettingView(title: "Pulsing", value: $puck2dSettings.pulsing)
                }
            case.d3:
                SliderSettingView(title: "Scale", value: $puck3dSettings.scale, range: 15...45, step: 5)
            }
        }
        .padding(10)
        .floating(RoundedRectangle(cornerRadius: 10))
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

extension PuckBearing: CaseIterable {
    public static var allCases: [PuckBearing] = [.course, .heading]
}

private let sportCar = Model(
    uri: Bundle.main.url(forResource: "sportcar", withExtension: "glb"),
    orientation: [0, 0, 180] // orient source model to point the bearing property
)

@available(iOS 14.0, *)
struct PuckPlayground_Preview: PreviewProvider {
    static var previews: some View {
        PuckPlayground()
    }
}
