import SwiftUI
import Turf
@_spi(Experimental) import MapboxMaps

struct MarkersExample: View {
    @State private var markerColor = Color(red: 207/255, green: 218/255, blue: 247/255, opacity: 1.0)
    @State private var strokeColor = Color(red: 58/255, green: 89/255, blue: 250/255, opacity: 1.0)
    @State private var showStroke: Bool = true
    @State private var showText: Bool = true
    @State private var overlayHeight: CGFloat = 0
    @State private var markerText: String = "Central Helsinki"
    @State private var tappedPoints = [CLLocationCoordinate2D]()

    var body: some View {
        Map(initialViewport: .camera(center: .helsinki, zoom: 15, pitch: 60)) {
            Marker(coordinate: .helsinki)
                .color(markerColor)
                .stroke(showStroke ? strokeColor : nil)
                .text(showText ? markerText : nil)
                .onTapGesture {
                    markerColor = .random
                }

            ForEvery(tappedPoints, id: \.latitude) { coord in
                Marker(coordinate: coord)
                    .color(markerColor)
                    .stroke(showStroke ? strokeColor : nil)
                    .text(showText ? String(format: "%.3f, %.3f", coord.latitude, coord.longitude) : nil)
                    .onTapGesture {
                        markerColor = .random
                    }
            }

            TapInteraction { tapContext in
                tappedPoints.append(tapContext.coordinate)
                return true
            }

            LongPressInteraction { _ in
                tappedPoints.removeAll()
                return true
            }
        }
        .additionalSafeAreaInsets(.bottom, overlayHeight)
        .ignoresSafeArea(edges: [.all] )
        .overlay(alignment: .bottom) {
            VStack(alignment: .leading) {
                Text("Tap to add a Marker")
                ColorPicker("Marker Color", selection: $markerColor)
                ColorPicker("Stroke Color", selection: $strokeColor)
                Toggle("Show stroke", isOn: $showStroke)
                Toggle("Show Marker text", isOn: $showText)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .floating(RoundedRectangle(cornerRadius: 10))
            .limitPaneWidth()
            .onChangeOfSize { size in
                overlayHeight = size.height
            }
        }
    }
}

struct MarkersExample_Previews: PreviewProvider {
    static var previews: some View {
        MarkersExample()
    }
}
