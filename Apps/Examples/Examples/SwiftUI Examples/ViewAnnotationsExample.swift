import SwiftUI
@_spi(Experimental) import MapboxMapsSwiftUI

extension Point: Identifiable {
    public var id: String { "\(coordinates)" }
}

@available(iOS 14.0, *)
struct ViewAnnotationsExample: View {
    @State var camera = CameraState(center: .helsinki, zoom: 5)
    @State var points: [Point] = []

    var body: some View {
        MapReader { proxy in
            Map(camera: $camera, viewAnnotationItems: points) { point in
                ViewAnnotation(id: point.id, geometry: point, size: CGSize(width: 150, height: 50), allowOverlap: true) {
                    ViewAnnotationContent(point: point, onRemoveButtonTapped: {
                        points.removeAll(where: { $0 == point })
                    })
                }
            }
            .styleURI(.streets, darkMode: .dark)
            .onMapTapGesture { point in
                guard let map = proxy.map else { return }

                let coordinate = map.coordinate(for: point)
                points.append(Point(coordinate))
            }
            .ignoresSafeArea(edges: [.leading, .trailing, .bottom])
        }
    }
}

@available(iOS 14.0, *)
private struct ViewAnnotationContent: View {
    let point: Point
    let onRemoveButtonTapped: () -> Void

    var body: some View {
        let latlon = String(format: "%.2f, %.2f", point.coordinates.latitude, point.coordinates.longitude)
        HStack(alignment: .firstTextBaseline) {
            Text("(\(latlon))")
                .font(.safeMonospaced)
            Image(systemName: "clear.fill")
                .onTapGesture(perform: onRemoveButtonTapped)
        }
        .padding(5)
        .background(Color.primary)
        .foregroundColor(.white)
    }
}

@available(iOS 14.0, *)
struct ViewAnnotationsExample_Previews: PreviewProvider {
    static var previews: some View {
        ViewAnnotationsExample()
    }
}
