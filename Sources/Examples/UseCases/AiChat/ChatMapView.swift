import MapboxMaps
import SwiftUI

@available(iOS 17.0, *)
struct ChatMapView: View {
    var response: MapResponse
    var sectionId: UUID
    @State var allowPan = false
    @State var viewport: Viewport = .idle
    @State var showResetButton = false

    @Environment(\.colorScheme) var colorScheme
    @Environment(ChatModel.self) private var model

    var body: some View {
        ZStack {
            Map(viewport: $viewport) {
                ForEvery(response.pins, id: \.id) { pin in
                    /// Display data as view annotations - the easiest and most customizable way to display dynamic data.
                    MapViewAnnotation(coordinate: pin.location) {
                        CirclePinView(icon: pin.icon, active: pin.id == model.selectedPinId)
                            .onTapGesture {
                                model.selectedPinId = pin.id
                            }
                            .id(pin.id)
                    }
                    .allowOverlap(true)

                    Puck2D()
                }
            }
            /// Remove unnecessary ScaleBar in restricted space
            .ornamentOptions(
                .init(
                    scaleBar: .init(visibility: .hidden), compass: .init(),
                    logo: .init(), attributionButton: .init())
            )
            .mapStyle(
                .standard(
                    theme: .faded,
                    lightPreset: colorScheme == .light ? .day : .dusk))

            toolbar
        }
        .frame(height: 300)
        .onChange(of: response.id) { _, _ in
            if let customCamera = response.camera {
                withViewportAnimation(.fly) {
                    viewport = .camera(
                        center: customCamera.center,
                        zoom: customCamera.zoom ?? 16,
                        bearing: customCamera.bearing ?? 0,
                        pitch: customCamera.pitch ?? 0
                    )
                }
            } else {
                updateViewport(animated: true)
            }
        }
        .onChange(of: model.selectedPinId) { oldValue, newValue in
            /// When selected pin is changed, focus camera on that pin.
            let selectedPin = response.pins.first(where: { $0.id == newValue })
            if let selectedPin {
                withViewportAnimation(.fly) {
                    viewport = .camera(center: selectedPin.location, zoom: 16, bearing: 0, pitch: 0)
                }
            }
        }
        .onChange(of: viewport) { _, newValue in
            /// When viewport changes to non-overview, display a button to reset viewport and see results again.
            showResetButton = newValue.overview == nil
        }
        .onAppear {
            updateViewport(animated: false)
        }
    }

    var toolbar: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                if showResetButton {
                    Button(action: {
                        updateViewport(animated: true)
                        showResetButton = false
                    }) {
                        Image(systemName: "arrow.counterclockwise")
                            .renderingMode(.template)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.primary)
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(MapFloatingButtonStyle())
                }
            }
        }
        .padding(.trailing, 16)
        .padding(.bottom, 56)
    }

    func updateViewport(animated: Bool = true) {
        /// Initial viewport should overview the pins.
        let newViewport = Viewport.overview(
            geometry: Polygon([response.pins.map(\.location)]),
            geometryPadding: .init(top: 50, leading: 50, bottom: 50, trailing: 50), maxZoom: 16)
        if animated {
            withViewportAnimation(.fly) {
                viewport = newViewport
            }
        } else {
            viewport = newViewport
        }

    }
}
