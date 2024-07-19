import SwiftUI
import MapboxMaps

@available(iOS 14.0, *)
struct ViewportPlayground: View {
    @State var viewport: Viewport = .styleDefault
    @State var mapStyle: MapStyle = .standard
    @State var useSafeAreaAsPaddings: Bool = true
    @State var additionalSafeArea: Bool = true
    @State var settingsHeight = 0.0

    var body: some View {
        Map(viewport: $viewport) {
            Puck2D(bearing: .course)

            ForEvery(parks.coordinates, id: \.latitude) { coord in
                MapViewAnnotation(coordinate: coord) {
                    Image(systemName: "tree")
                        .foregroundColor(.white)
                        .padding(.all, 5)
                        .background(
                            Circle()
                                .strokeBorder(.black, lineWidth: 0.5)
                                .background(Circle().fill(Color(.systemGreen)))
                        )
                }
                .allowOverlap(true)
            }

            PolygonAnnotation(id: "polygon", polygon: maineBoundaries)
                .fillColor(StyleColor(red: 0, green: 128, blue: 255, alpha: 0.5)!)
                .fillOutlineColor(StyleColor(.black))
        }
        .mapStyle(mapStyle)
        .debugOptions([.camera, .padding])
        .usesSafeAreaInsetsAsPadding(useSafeAreaAsPaddings)
        .additionalSafeAreaInsets(.bottom, additionalBottomSafeArea)
        .ignoresSafeArea()
        .safeOverlay(alignment: .bottomLeading) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Viewport sate: \(viewportShortDescription)")
                MiniToggle(title: "Use safe area as padding", isOn: $useSafeAreaAsPaddings)
                MiniToggle(title: "Use additional safe area", isOn: $additionalSafeArea)
            }
            .font(.safeMonospaced)
            .floating()
            .onChangeOfSize { size in
                settingsHeight = size.height
            }
        }
        .safeOverlay(alignment: .trailing) {
            MapStyleSelectorButton(mapStyle: $mapStyle)
        }
        .toolbar {
            ToolbarItem {
                ViewportMenu(viewport: $viewport)
            }
        }
    }

    private var additionalBottomSafeArea: CGFloat {
        additionalSafeArea ? settingsHeight : 0
    }

    var viewportShortDescription: String {
        if viewport.isIdle {
            return "idle"
        }
        if let _ = viewport.camera {
            return "camera"
        }
        if let overview = viewport.overview {
            var geometryType = ""
            switch overview.geometry {
            case .point:
                geometryType = "point"
            case .lineString:
                geometryType = "lineString"
            case .polygon:
                geometryType = "polygon"
            case .multiPoint:
                geometryType = "multiPoint"
            case .multiLineString:
                geometryType = "multiLineString"
            case .multiPolygon:
                geometryType = "multiPolygon"
            case .geometryCollection:
                geometryType = "geometryCollection"
            #if USING_TURF_WITH_LIBRARY_EVOLUTION
            @unknown default:
                geometryType = "unknownType"
            #else
            #endif
            }
            return "overview(\(geometryType))"
        }
        if let _ = viewport.followPuck {
            return "followPuck"
        }
        return "default"
    }
}

@available(iOS 13.0, *)
private struct MiniToggle: View {
    var title: String
    @Binding var isOn: Bool
    var body: some View {
        HStack(spacing: 0) {
            Text(title)
            Toggle(isOn: $isOn) { EmptyView() }
                .scaleEffect(0.7)
                .fixedSize()
                .padding(.bottom, -5)
        }
    }
}

@available(iOS 14.0, *)
private struct ViewportMenu: View {
    @Binding var viewport: Viewport

    var body: some View {
        Menu {
            Button(".idle") {
                viewport = .idle
            }
            Button(".styleDefault") {
                viewport = .styleDefault
            }
            Button(".camera()") {
                viewport = .camera(center: CLLocationCoordinate2D(latitude: 41.8915, longitude: -87.6087), zoom: 16.52, bearing: 290, pitch: 68.5)
            }
            Button(".overview(.multiPoint())") {
                viewport = viewport(for: parks, coordinatePadding: 20)
            }
            Button(".overview(.polygon())") {
                viewport = viewport(for: maineBoundaries, coordinatePadding: 10)
                    .padding(.all, 10)
            }
            .padding(10)
            Button(".followPuck(bearing: .course)") {
                viewport = .followPuck(zoom: 13, bearing: .course, pitch: 55)
            }
            Button(".followPuck(bearing: .heading)") {
                viewport = .followPuck(zoom: 13, bearing: .heading)
            }
            Group {
                Divider()
                Text("Animated")
                Button("[default] .styleDefault") {
                    withViewportAnimation {
                        viewport = .styleDefault
                    }
                }
                Button("[easeIn] .camera()") {
                    withViewportAnimation(.easeIn(duration: 1)) {
                        viewport = .camera(center: CLLocationCoordinate2D(latitude: 41.8915, longitude: -87.6087), zoom: 16.52, bearing: 290, pitch: 68.5)
                    }
                }
                Button("[fly] .overview(.multiPoint())") {
                    withViewportAnimation(.fly(duration: 1)) {
                        viewport = viewport(for: parks, coordinatePadding: 20)
                    }

                }
                Button("[fly] .overview(.polygon())") {
                    withViewportAnimation(.fly(duration: 1)) {
                        viewport = viewport(for: maineBoundaries, coordinatePadding: 10)
                            .padding(.all, 10)
                    }
                }
                Button("[default] .followPuck(bearing: .heading)") {
                    withViewportAnimation(.default) {
                        viewport = .followPuck(zoom: 16.3, bearing: .heading, pitch: 42)
                    }
                }

                Button("[default] .followPuck(bearing: .course)") {
                    withViewportAnimation(.default(maxDuration: 1)) {
                        viewport = .followPuck(zoom: 16.3, bearing: .course, pitch: 60)
                    }
                }
            }
        } label: {
            Text("Set viewport")
        }
    }

    private func viewport(for geometry: GeometryConvertible, coordinatePadding: CGFloat) -> Viewport {
        let padding = EdgeInsets(
            top: coordinatePadding,
            leading: coordinatePadding,
            bottom: coordinatePadding,
            trailing: coordinatePadding)
        return .overview(geometry: geometry, geometryPadding: padding)
    }
}

private let parks = MultiPoint([
    CLLocationCoordinate2D(latitude: 38.089600, longitude: -111.149910),
    CLLocationCoordinate2D(latitude: 36.491508, longitude: -121.197243),
    CLLocationCoordinate2D(latitude: 40.343182, longitude: -105.688103),
    CLLocationCoordinate2D(latitude: 38.000000, longitude: -82.000000),
    CLLocationCoordinate2D(latitude: 38.865097, longitude: -91.504852),
    CLLocationCoordinate2D(latitude: 39.198364, longitude: -119.930984),
    CLLocationCoordinate2D(latitude: 32.779720, longitude: -106.171669),
    CLLocationCoordinate2D(latitude: 43.582767, longitude: -110.821999),
    CLLocationCoordinate2D(latitude: 35.141689, longitude: -115.510399),
])

private let maineBoundaries = Polygon([[
    CLLocationCoordinate2D(latitude: 45.13745, longitude: -67.13734),
    CLLocationCoordinate2D(latitude: 44.8097, longitude: -66.96466),
    CLLocationCoordinate2D(latitude: 44.3252, longitude: -68.03252),
    CLLocationCoordinate2D(latitude: 43.98, longitude: -69.06),
    CLLocationCoordinate2D(latitude: 43.68405, longitude: -70.11617),
    CLLocationCoordinate2D(latitude: 43.09008, longitude: -70.64573),
    CLLocationCoordinate2D(latitude: 43.08003, longitude: -70.75102),
    CLLocationCoordinate2D(latitude: 43.21973, longitude: -70.79761),
    CLLocationCoordinate2D(latitude: 43.36789, longitude: -70.98176),
    CLLocationCoordinate2D(latitude: 43.46633, longitude: -70.94416),
    CLLocationCoordinate2D(latitude: 45.30524, longitude: -71.08482),
    CLLocationCoordinate2D(latitude: 45.46022, longitude: -70.66002),
    CLLocationCoordinate2D(latitude: 45.91479, longitude: -70.30495),
    CLLocationCoordinate2D(latitude: 46.69317, longitude: -70.00014),
    CLLocationCoordinate2D(latitude: 47.44777, longitude: -69.23708),
    CLLocationCoordinate2D(latitude: 47.18479, longitude: -68.90478),
    CLLocationCoordinate2D(latitude: 47.35462, longitude: -68.2343),
    CLLocationCoordinate2D(latitude: 47.06624, longitude: -67.79035),
    CLLocationCoordinate2D(latitude: 45.70258, longitude: -67.79141),
    CLLocationCoordinate2D(latitude: 45.13745, longitude: -67.13734)
]])

@available(iOS 14.0, *)
struct MapViewportExample_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ViewportPlayground()
        }
    }
}
