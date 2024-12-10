import SwiftUI
import MapboxMaps

struct SimpleMapExample: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        let polygon = Polygon(center: .helsinki, radius: 10000, vertices: 30)
        Map(initialViewport: .overview(geometry: polygon))
            .mapStyle(.standard(lightPreset: colorScheme == .light ? .day : .dusk))
            .ignoresSafeArea()
    }
}

struct SimpleMapExample_Previews: PreviewProvider {
    static var previews: some View {
        SimpleMapExample()
    }
}
