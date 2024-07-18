import SwiftUI
import Turf
@_spi(Experimental) import MapboxMaps

@available(iOS 14.0, *)
struct ViewAnnotationsExample: View {
    @State private var taps: [Tap] = []
    @State private var allowOverlap: Bool = false
    @State private var allowZElevate: Bool = false
    @State private var ignoreAllSafeArea: Bool = true
    @State private var selected = false
    @State private var etaAnnotationAnchor = ViewAnnotationAnchor.center
    @State private var overlayHeight: CGFloat = 0

    var body: some View {
        Map(initialViewport: .camera(center: .helsinki, zoom: 5)) {
            // A single view annotation, tap on it to change selected state.
            MapViewAnnotation(coordinate: .helsinki) {
                Text("🏠")
                    .frame(width: 22, height: 22)
                    .scaleEffect(selected ? 1.8 : 1)
                    .padding(selected ? 20 : 10)
                    .background(
                        Circle().fill(selected ? .red : .blue))
                    .animation(.spring(), value: selected)
                    .hoverEffect()
                    .onTapGesture {
                        selected.toggle()
                    }
            }
            .allowOverlap(allowOverlap)
            .selected(selected)

            // Dynamic view annotations, appeared on tap.
            // The anchor can point to bottom, top, left, or right direction.
            ForEvery(taps) { tap in
                MapViewAnnotation(coordinate: tap.coordinate) {
                    ViewAnnotationContent(tap: tap) {
                        taps.removeAll(where: { $0.id == tap.id })
                    }
                }
                .allowZElevate(allowZElevate)
                .allowOverlap(allowOverlap)
                // Allow bottom, top, left, right positions of anchor.
                .variableAnchors(
                    [ViewAnnotationAnchor.bottom, .bottomLeft, .bottomRight].map { .init(anchor: $0) }
                )
                .onAnchorChanged { config in
                    guard let idx = taps.firstIndex(where: { $0.id == tap.id }) else { return }
                    taps[idx].selectedAnchor = config
                }
            }

            // A Dynamic View Annotation annotation, that is attached to the Polyline annotation.
            let routeLayer = "route"
            let routeFeature = "route-feature"

            // Route polyline
            PolylineAnnotationGroup {
                PolylineAnnotation(id: routeFeature, lineCoordinates: routeCoordinates)
                    .lineColor("#57A9FB")
                    .lineBorderColor("#327AC2")
                    .lineWidth(10)
                    .lineBorderWidth(2)
            }
            .layerId(routeLayer) // Specify id for underlying line layer.
            .lineCap(.round)
            .slot("middle") // Display above roads and below 3D buildings and labels (for Standard Style).

            MapViewAnnotation(layerId: routeLayer, featureId: routeFeature) {
                Text("1h 30m")
                    .padding(3)
                    .callout(
                        anchor: etaAnnotationAnchor,
                        color: Color(UIColor.systemBackground),
                        tailSize: 5.0)
            }
            .allowOverlap(allowOverlap)
            .allowZElevate(allowZElevate)
            .variableAnchors(.all) // Allow all directions for anchor
            .onAnchorChanged { self.etaAnnotationAnchor = $0.anchor }
            .selected(true)
        }
        .onMapTapGesture { context in
            taps.append(Tap(coordinate: context.coordinate))
        }
        // Add bottom padding for the bottom config panel, View Annotations won't appear there.
        .additionalSafeAreaInsets(.bottom, overlayHeight)
        .ignoresSafeArea(edges: ignoreAllSafeArea ? [.all] : [.horizontal, .bottom])
        .safeOverlay(alignment: .bottom) {
            VStack(alignment: .leading) {
                Text("Tap to add annotations")
                Toggle("Allow overlap", isOn: $allowOverlap)
                Toggle("Allow Z elevation", isOn: $allowZElevate)
                Toggle("Ignore all safe area", isOn: $ignoreAllSafeArea)
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

@available(iOS 13.0, *)
private struct Tap: Equatable, Identifiable {
    var id = UUID()
    var coordinate: CLLocationCoordinate2D
    var color: Color = .random
    var selectedAnchor: ViewAnnotationAnchorConfig?
}

@available(iOS 14.0, *)
private struct ViewAnnotationContent: View {
    var tap: Tap
    var onRemove: () -> Void

    @State var appeared = false

    var body: some View {
        let latlon = String(format: "%.2f, %.2f", tap.coordinate.latitude, tap.coordinate.longitude)

        HStack(alignment: .firstTextBaseline) {
            Text("(\(latlon))")
                .font(.safeMonospaced)
            Image(systemName: "clear.fill")
                .onTapGesture(perform: onRemove)
        }
        .padding(5)
        .foregroundColor(.white)
        // Wrap annotation view into callout shape.
        .callout(anchor: tap.selectedAnchor?.anchor ?? .center, color: tap.color)
        .opacity(appeared ? 1 : 0)
        .scaleEffect(appeared ? 1 : 0.2)
        .animation(.spring(), value: appeared)
        .onAppear {
            appeared = true
        }
        .onDisappear {
            appeared = false
        }
    }

    private func tail() -> some View {
        tap.color.frame(width: 6, height: 6)
    }
}

private let routeCoordinates: [CLLocationCoordinate2D] = [
    .init(latitude: 61.493343399275375, longitude: 21.79401104323395),
    .init(latitude: 61.369485877583685, longitude: 21.6497937188623),
    .init(latitude: 61.20121331932606, longitude: 21.723373986398713),
    .init(latitude: 61.15722935505474, longitude: 21.579156662028026),
    .init(latitude: 61.1174491345069, longitude: 21.517349237298163),
    .init(latitude: 61.03916342463762, longitude: 21.532065290804866),
    .init(latitude: 60.922086661997184, longitude: 21.611531979743546),
    .init(latitude: 60.82754056454698, longitude: 21.82049993954618),
    .init(latitude: 60.662131116075585, longitude: 22.02063826724438),
    .init(latitude: 60.543665503992116, longitude: 22.129538402396946),
    .init(latitude: 60.461061119997595, longitude: 22.206061880634536),
    .init(latitude: 60.4538050749446, longitude: 22.270812516066485)
]

@available(iOS 14.0, *)
struct ViewAnnotationsExample_Previews: PreviewProvider {
    static var previews: some View {
        ViewAnnotationsExample()
    }
}
