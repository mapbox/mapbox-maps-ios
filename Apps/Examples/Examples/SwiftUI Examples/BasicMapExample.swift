import SwiftUI
import MapboxMaps

@available(iOS 13.0, *)
struct BasicMapExample: View {
    let center = CLLocationCoordinate2D(latitude: 41.879, longitude: -87.635)

    var body: some View {
        Map(initialViewport: .camera(center: center, zoom: 16, bearing: 12, pitch: 60))
            .ignoresSafeArea()
    }
}