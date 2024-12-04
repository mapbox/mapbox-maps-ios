import Foundation
import SwiftUI
import MapboxMaps

struct MapScrollExample: View {
    var body: some View {
        List {
            Section {
                Text("Test Map behaviour inside scroll.")
                    .font(.title)
                    .bold()
            }
            Section {
                Map(initialViewport: .followPuck(zoom: 18, bearing: .heading, pitch: 60)) {
                    Puck2D(bearing: .heading)
                }.aspectRatio(1.0, contentMode: .fill)
            }
        }
    }
}

struct MapScrollExample_Previews: PreviewProvider {
    static var previews: some View {
        MapScrollExample()
    }
}
