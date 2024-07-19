import SwiftUI
import MapboxMaps

@available(iOS 13.0, *)
struct SnapshotMapExample: View {
    @State var image: UIImage?

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 10) {
                MapReader { proxy in
                    Map(initialViewport: .helsinkiOverview)
                        .mapStyle(.outdoors)
                        .onMapIdle { _ in image = proxy.captureSnapshot() }
                        .frame(height: geometry.size.height / 2)
                }

                SnapshotView(snapshot: image)
                    .frame(height: geometry.size.height / 2)
            }
        }
    }
}

@available(iOS 13.0, *)
struct SnapshotView: View {
    var snapshot: UIImage?

    var body: some View {
        if let snapshot {
            Image(uiImage: snapshot)
        } else {
            EmptyView()
        }
    }
}

@available(iOS 13.0, *)
private extension Viewport {
    static let helsinkiOverview = Self.overview(geometry: Polygon(center: .helsinki, radius: 10000, vertices: 30))
}

@available(iOS 13.0, *)
struct SnapshotMapExample_Preview: PreviewProvider {
    static var previews: some View {
        SnapshotMapExample()
    }
}
