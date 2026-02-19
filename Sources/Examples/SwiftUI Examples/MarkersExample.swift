import SwiftUI
import Turf
@_spi(Experimental) import MapboxMaps

struct MarkersExample: View {
    @State private var markerColor = Color(red: 207/255, green: 218/255, blue: 247/255, opacity: 1.0)
    @State private var strokeColor = Color(red: 58/255, green: 89/255, blue: 250/255, opacity: 1.0)
    @State private var showStroke: Bool = true
    @State private var showText: Bool = true
    @State private var overlayHeight: CGFloat = 0
    @State private var showPresetMarkers: Bool = true

    // Helsinki coordinates for the map center
    private let centerCoord = CLLocationCoordinate2D(latitude: 60.1699, longitude: 24.9384)

    // User-added markers
    @State private var userMarkers: [MarkerData] = []

    var body: some View {
        Map(initialViewport: .camera(center: centerCoord, zoom: 13, pitch: 45)) {
            // Three preset markers demonstrating different animation types
            if showPresetMarkers {
                let coord1 = CLLocationCoordinate2D(latitude: 60.1699, longitude: 24.9384 - 0.01)
                Marker(coordinate: coord1)
                    .color(markerColor)
                    .stroke(showStroke ? strokeColor : nil)
                    .text(showText ? "Wiggle+Scale" : nil)
                    .animation(.wiggle, .scale, when: .appear)
                    .animation(.wiggle, .scale(from: 1, to: 0), when: .disappear)
                    .onTapGesture {
                        print("Marker tapped at: \(coord1.latitude), \(coord1.longitude)")
                    }

                let coord2 = CLLocationCoordinate2D(latitude: 60.1699, longitude: 24.9384)
                Marker(coordinate: coord2)
                    .color(markerColor)
                    .stroke(showStroke ? strokeColor : nil)
                    .text(showText ? "Scale" : nil)
                    .animation(.scale, when: .appear)
                    .animation(.scale(from: 1, to: 0), when: .disappear)
                    .onTapGesture {
                        print("Marker tapped at: \(coord2.latitude), \(coord2.longitude)")
                    }

                let coord3 = CLLocationCoordinate2D(latitude: 60.1699, longitude: 24.9384 + 0.01)
                Marker(coordinate: coord3)
                    .color(markerColor)
                    .stroke(showStroke ? strokeColor : nil)
                    .text(showText ? "Fade" : nil)
                    .animation(.fadeIn, when: .appear)
                    .animation(.fadeOut, when: .disappear)
                    .onTapGesture {
                        print("Marker tapped at: \(coord3.latitude), \(coord3.longitude)")
                    }
            }

            // User-added markers
            ForEvery(userMarkers, id: \.id) { markerData in
                Marker(coordinate: markerData.coordinate)
                    .color(markerColor)
                    .stroke(showStroke ? strokeColor : nil)
                    .text(showText ? String(format: "%.2f, %.2f", markerData.coordinate.latitude, markerData.coordinate.longitude) : nil)
                    .animation(.wiggle, .scale, when: .appear)
                    .animation(.wiggle, .scale(from: 1, to: 0), when: .disappear)
                    .onTapGesture {
                        print("Marker tapped at: \(markerData.coordinate.latitude), \(markerData.coordinate.longitude)")
                    }
            }

            TapInteraction { context in
                addMarker(at: context.coordinate)
                return false
            }

            LongPressInteraction { _ in
                userMarkers.removeAll()
                showPresetMarkers = false
                return false
            }
        }
        .additionalSafeAreaInsets(Edge.Set.bottom, overlayHeight)
        .ignoresSafeArea(edges: [.all])
        .overlay(alignment: .bottom) {
            HStack {
                Spacer()
                VStack(alignment: .leading, spacing: 8) {
                    Text("Marker Animations")
                        .font(.headline)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("• Three preset markers show different animation types")
                            .font(.caption2)
                        Text("• Tap the map to add new markers with animation")
                            .font(.caption2)
                        Text("• Long press the map to remove all markers")
                            .font(.caption2)
                    }
                    .foregroundColor(.secondary)

                    Divider()

                    // Styling Controls
                    Text("Styling")
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    ColorPicker("Marker Color", selection: $markerColor)
                    ColorPicker("Stroke Color", selection: $strokeColor)

                    Toggle("Show stroke", isOn: $showStroke)
                    Toggle("Show text", isOn: $showText)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .floating(RoundedRectangle(cornerRadius: 10))
                .limitPaneWidth()
                .onChangeOfSize { size in
                    overlayHeight = size.height
                }
                Spacer()
            }
        }
    }

    private func addMarker(at coordinate: CLLocationCoordinate2D) {
        let newMarker = MarkerData(
            id: UUID().uuidString,
            coordinate: coordinate
        )
        userMarkers.append(newMarker)
    }
}

// MARK: - MarkerData

struct MarkerData: Identifiable {
    let id: String
    let coordinate: CLLocationCoordinate2D
}

// MARK: - Previews

struct MarkersExample_Previews: PreviewProvider {
    static var previews: some View {
        MarkersExample()
    }
}
