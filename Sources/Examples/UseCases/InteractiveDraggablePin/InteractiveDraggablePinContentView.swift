import SwiftUI
@_spi(Experimental) import MapboxMaps

// MARK: - Interactive Draggable Pin Use Case

/// Shows the full potential of draggable view annotations: a custom SwiftUI pin bound to a coordinate via
/// `MapViewAnnotation(coordinate:content:onDraggingChanged:)` that lifts, tilts and lands with animations,
/// while the distance badge and map geometry follow the updated coordinate.
struct InteractiveDraggablePinContentView: View {
    private let startCoordinate = InteractiveDraggablePinConstants.startCoordinate
    @State private var coordinate = InteractiveDraggablePinConstants.startCoordinate
    @State private var isDragging = false
    @State private var viewport: Viewport = .camera(InteractiveDraggablePinConstants.cameraOptions)
    @State private var returnTask: Task<Void, Never>?

    private var distance: CLLocationDistance {
        CLLocation(latitude: startCoordinate.latitude, longitude: startCoordinate.longitude)
            .distance(from: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
    }

    private var showsReturnButton: Bool { distance >= 1 && !isDragging }

    var body: some View {
        MapReader { proxy in
            mapView(proxy)
                .overlay(alignment: .bottom) {
                    if showsReturnButton {
                        ReturnButton { returnToStart(from: proxy.map?.cameraState) }
                            .padding(.bottom, 24)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: showsReturnButton)
        }
    }

    private func mapView(_ proxy: MapProxy) -> some View {
        Map(viewport: $viewport) {
            PolylineAnnotationGroup {
                PolylineAnnotation(lineCoordinates: [startCoordinate, coordinate])
                    .lineColor(StyleColor(.systemRed))
                    .lineWidth(3)
            }
            .lineCap(.round)
            .lineDashArray([0, 2])

            CircleAnnotation(centerCoordinate: startCoordinate)
                .circleColor(StyleColor(.white))
                .circleRadius(5)
                .circleStrokeColor(StyleColor(.systemRed))
                .circleStrokeWidth(2)

            MapViewAnnotation(coordinate: $coordinate) {
                InteractivePinView(
                    screenX: proxy.map?.point(for: coordinate).x ?? 0,
                    distance: distance,
                    isDragging: isDragging
                )
            } onDraggingChanged: { dragging in
                if dragging { returnTask?.cancel() }
                isDragging = dragging
            }
            .allowOverlap(true)
            .variableAnchors([ViewAnnotationAnchorConfig(anchor: .bottom)])
        }
        .mapStyle(.outdoors)
        .ignoresSafeArea()
        .onDisappear { returnTask?.cancel() }
    }

    /// Flies the pin back to the start, lifted as if dragged, so it tilts on the way and bounces on landing.
    /// The camera moves in lockstep, keeping the pin on screen while it glides to the screen center.
    private func returnToStart(from camera: CameraState?) {
        guard let camera else { return }
        let target = InteractiveDraggablePinConstants.cameraOptions
        let targetZoom = target.zoom ?? camera.zoom
        // Bigger zoom change takes longer to come back, capped to keep it snappy.
        let duration = min(0.55 + 0.15 * abs(targetZoom - camera.zoom), 1.2)
        let steps = Int(duration * 60)

        // Mercator space with a 512 pt world; offsets are in screen points at the initial zoom.
        let fromCenter = Projection.project(camera.center, zoomScale: 1)
        let toCenter = Projection.project(startCoordinate, zoomScale: 1)
        let pin = Projection.project(coordinate, zoomScale: 1)
        let initialScale = pow(2, camera.zoom)
        let pinOffsetX = (pin.x - fromCenter.x) * initialScale
        let pinOffsetY = (pin.y - fromCenter.y) * initialScale
        let startOffsetX = (toCenter.x - fromCenter.x) * initialScale
        let startOffsetY = (toCenter.y - fromCenter.y) * initialScale
        // Rotate back to north along the shortest way.
        let bearingDelta = (camera.bearing + 540).truncatingRemainder(dividingBy: 360) - 180

        returnTask?.cancel()
        returnTask = Task {
            isDragging = true
            for step in 1...steps {
                try? await Task.sleep(nanoseconds: UInt64(duration / Double(steps) * 1_000_000_000))
                guard !Task.isCancelled else { return }
                let t = Double(step) / Double(steps)
                let eased = t < 0.5 ? 2 * t * t : 1 - pow(-2 * t + 2, 2) / 2

                let zoom = camera.zoom + (targetZoom - camera.zoom) * eased
                // Screen offsets of the start and the pin shrink linearly, so both slide straight to the center while the map zooms.
                let offsetScale = (1 - eased) / pow(2, zoom)
                let centerX = toCenter.x - startOffsetX * offsetScale
                let centerY = toCenter.y - startOffsetY * offsetScale

                viewport = .camera(
                    center: Projection.unproject(MercatorCoordinate(x: centerX, y: centerY), zoomScale: 1),
                    zoom: zoom,
                    bearing: camera.bearing - bearingDelta * eased,
                    pitch: camera.pitch * (1 - eased)
                )
                coordinate = Projection.unproject(
                    MercatorCoordinate(x: centerX + pinOffsetX * offsetScale, y: centerY + pinOffsetY * offsetScale),
                    zoomScale: 1
                )
            }
            coordinate = startCoordinate
            viewport = .camera(target)
            isDragging = false
        }
    }
}

// MARK: - ReturnButton

/// Floating capsule that sends the pin back to the start point.
private struct ReturnButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label("Back to Zugspitze", systemImage: "arrow.uturn.backward")
                .font(.system(.subheadline, design: .rounded).weight(.semibold))
                .foregroundStyle(Color(.systemRed))
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .background(.regularMaterial, in: Capsule())
                .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    InteractiveDraggablePinContentView()
}

#Preview("Return Button") {
    ReturnButton(action: {})
        .padding()
}
