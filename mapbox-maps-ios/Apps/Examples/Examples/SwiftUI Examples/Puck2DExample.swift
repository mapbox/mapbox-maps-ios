import SwiftUI
@_spi(Experimental) import MapboxMapsSwiftUI

extension Puck2DConfiguration {

    fileprivate static func makeDefault(
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

@available(iOS 14.0, *)
struct Puck2DExample: View {
    @State private var camera = CameraState(center: .helsinki, zoom: 12)

    @State private var isPuckBearingVisible = true
    @State private var isPuckAccuracyRingVisible = false
    @State private var puckOpacity = 1.0
    @State private var pulsing = Puck2DConfiguration.Pulsing.default

    var body: some View {
        Map(
            camera: $camera,
            locationOptions: .init(
                puckType: .puck2D(.makeDefault(
                    showBearing: isPuckBearingVisible,
                    pulsing: pulsing,
                    showAccuracyRing: isPuckAccuracyRingVisible,
                    opacity: puckOpacity))
            )
        )
        .styleURI(.dark)
        .onLocationUpdated { location in
            camera.center = location.coordinate
        }
        .ignoresSafeArea()
        .safeOverlay(alignment: .bottom) {
            VStack(alignment: .leading) {
                Toggle("Show bearing", isOn: $isPuckBearingVisible)
                Toggle("Show accuracy ring", isOn: $isPuckAccuracyRingVisible)
                Text("Opacity \(String(format: "%.2f", puckOpacity))")
                Slider(value: $puckOpacity, in: 0...1) {
                    Text("Adjust opacity")
                } minimumValueLabel: {
                    Text("0")
                } maximumValueLabel: {
                    Text("1")
                }.font(.system(size: 12))
                Toggle("Enable pulsing", isOn: $pulsing.isEnabled)
            }
            .padding(10)
            .floating(RoundedRectangle(cornerRadius: 10))
        }
    }
}

@available(iOS 14.0, *)
struct Puck2DExample_Preview: PreviewProvider {

    static var previews: some View {
        Puck2DExample()
    }
}
