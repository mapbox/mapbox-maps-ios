import SwiftUI
@_spi(Experimental) import MapboxMaps

struct RasterParticleExample: View {
    @State var mapStyle = MapStyle.dark
    @State var rasterParticleCount: Double = 2048
    @State var rasterParticleFadeOpacityFactor = 0.8
    @State var resetRateFactor = 0.4
    @State var speedFactor = 0.4

    var body: some View {
        Map(initialViewport: .camera(zoom: 1)) {
            RasterArraySource(id: "wind-mrt-source")
                .url("mapbox://mapbox.gfs-winds")

            RasterParticleLayer(id: "layer_particles", source: "wind-mrt-source")
                .sourceLayer("10winds")
                .rasterParticleSpeedFactor(speedFactor)
                .rasterParticleMaxSpeed(70)
                .rasterParticleCount(rasterParticleCount)
                .rasterParticleFadeOpacityFactor(rasterParticleFadeOpacityFactor)
                .rasterParticleResetRateFactor(resetRateFactor)
                .rasterParticleColor(particlesSpeedGradient)
        }
        .mapStyle(mapStyle)
        .debugOptions(.camera)
        .ignoresSafeArea()
        .overlay(alignment: .trailing) {
            MapStyleSelectorButton(mapStyle: $mapStyle)
        }
        .overlay(alignment: .bottom) {
            VStack(alignment: .center) {
                SliderSettingView(title: "Particle Count", value: $rasterParticleCount, range: 1...4096, step: 1)
                SliderSettingView(title: "Opacity Factor", value: $rasterParticleFadeOpacityFactor, range: 0...1, step: 0.01)
                SliderSettingView(title: "Reset Rate", value: $resetRateFactor, range: 0...1, step: 0.01)
                SliderSettingView(title: "Speed Factor", value: $speedFactor, range: 0...1, step: 0.01)
            }
            .foregroundColor(.white)
            .padding(.bottom, 40)
            .padding(.horizontal, 16)
        }
    }
}

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

private let particlesSpeedGradient = Exp(.interpolate) {
    Exp(.linear)
    Exp(.rasterParticleSpeed)
    1.5
    Exp(.rgb) { 134.0; 163.0; 171.0 }

    2.5
    Exp(.rgb) { 134.0; 163.0; 171.0 }

    4.63
    Exp(.rgb) { 110.0; 143.0; 208.0 }

    6.17
    Exp(.rgb) { 15.0; 147.0; 167.0 }

    7.72
    Exp(.rgb) { 15.0; 147.0; 167.0 }

    9.26
    Exp(.rgb) { 57.0; 163.0; 57.0 }

    10.29
    Exp(.rgb) { 57.0; 163.0; 57.0 }

    11.83
    Exp(.rgb) { 194.0; 134.0; 62.0 }

    13.37
    Exp(.rgb) { 194.0; 134.0; 63.0 }

    14.92
    Exp(.rgb) { 200.0; 66.0; 13.0 }

    16.46
    Exp(.rgb) { 200.0; 66.0; 13.0 }

    18.00
    Exp(.rgb) { 210.0; 0.0; 50.0 }

    20.06
    Exp(.rgb) { 215.0; 0.0; 50.0 }

    21.60
    Exp(.rgb) { 175.0; 80.0; 136.0 }

    23.66
    Exp(.rgb) { 175.0; 80.0; 136.0 }

    25.21
    Exp(.rgb) { 117.0; 74.0; 147.0 }

    27.78
    Exp(.rgb) { 117.0; 74.0; 147.0 }

    29.32
    Exp(.rgb) { 68.0; 105.0; 141.0 }

    31.89
    Exp(.rgb) { 68.0; 105.0; 141.0 }

    33.44
    Exp(.rgb) { 194.0; 251.0; 119.0 }

    42.18
    Exp(.rgb) { 194.0; 251.0; 119.0 }

    43.72
    Exp(.rgb) { 241.0; 255.0; 109.0 }

    48.87
    Exp(.rgb) { 241.0; 255.0; 109.0 }

    50.41
    Exp(.rgb) { 255.0; 255.0; 255.0 }

    57.61
    Exp(.rgb) { 255.0; 255.0; 255.0 }

    59.16
    Exp(.rgb) { 255.0; 255.0; 255.0 }

    68.93
    Exp(.rgb) { 255.0; 255.0; 255.0 }

    69.44
    Exp(.rgb) { 255.0; 37.0; 255.0 }
}
