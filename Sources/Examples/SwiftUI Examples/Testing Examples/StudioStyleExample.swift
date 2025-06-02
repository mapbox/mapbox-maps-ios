import SwiftUI
import MapboxMaps

struct StudioStyleExample: View {
    @State private var mapStyle: MapStyle = .standard
    @State private var styleURLInputAlertPresented = false
    @State private var invalidStyleURLAlertPresented = false
    @State private var styleURLInput = ""

    var body: some View {
        Map(initialViewport: .camera(center: CLLocationCoordinate2D(latitude: 51.5015, longitude: -0.1213), zoom: 15, bearing: 57, pitch: 60))
            .mapStyle(mapStyle)
            .ignoresSafeArea()
            .toolbar {
                Button("Change style") {
                    styleURLInputAlertPresented = true
                }
            }
            .alert("Mapbox Style URL", isPresented: $styleURLInputAlertPresented) {
                TextField("Style URL", text: $styleURLInput)
                Button("Save") {
                    Task {
                        await saveStyleURLInput(styleURLInput)
                    }
                }
                Button("Cancel", action: {})
            } message: {
                Text("Paste the “Share URL” for your public Mapbox style")
            }
            .alert("Invalid URL", isPresented: $invalidStyleURLAlertPresented) {
                Button("Cancel", action: {})
            } message: {
                Text("Please check your Mapbox Studio Style URL")
            }
    }

    private func saveStyleURLInput(_ input: String) async {
        guard let url = URL(string: input),
        let styleURI = StyleURI(url: url) else {
            invalidStyleURLAlertPresented = true
            return
        }
        let style = MapStyle(uri: styleURI)
        mapStyle = style
    }
}

struct StudioStyleExample_Previews: PreviewProvider {
    static var previews: some View {
        StudioStyleExample()
    }
}
