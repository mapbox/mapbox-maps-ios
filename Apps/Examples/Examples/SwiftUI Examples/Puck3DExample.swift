import SwiftUI
@_spi(Experimental) import MapboxMapsSwiftUI

@available(iOS 14.0, *)
struct Puck3DExample: View {
    @State private var camera = CameraState(center: .helsinki, zoom: 12)
    @State private var puckOpacity = 1.0
    @State private var puckScale = 1.0
    private let model = Model(uri: Bundle.main.url(forResource: "sportcar", withExtension: "glb"))

    var body: some View {
        Map(
            camera: $camera,
            locationOptions: LocationOptions(
                puckType: .puck3D(.init(
                    model: model,
                    modelScale: .constant([puckScale, puckScale, puckScale]),
                    modelOpacity: .constant(puckOpacity)
                ))
            )
        )
        .ignoresSafeArea()
        .safeOverlay(alignment: .bottom) {
            VStack(alignment: .leading) {
                Text("Opacity \(String(format: "%.2f", puckOpacity))")
                Slider(value: $puckOpacity, in: 0...1) {
                    Text("Adjust opacity")
                } minimumValueLabel: {
                    Text("0")
                } maximumValueLabel: {
                    Text("1")
                }.font(.system(size: 12))
                Text("Scale \(String(format: "%.2f", puckScale))")
                Slider(value: $puckScale, in: 0...2, step: 0.25) {
                    Text("Adjust scale")
                } minimumValueLabel: {
                    Text("0")
                } maximumValueLabel: {
                    Text("2")
                }.font(.system(size: 12))
            }
            .padding(10)
            .floating(RoundedRectangle(cornerRadius: 10))
        }
    }
}

@available(iOS 14.0, *)
struct Puck3DExample_Preview: PreviewProvider {

    static var previews: some View {
        Puck3DExample()
    }
}
