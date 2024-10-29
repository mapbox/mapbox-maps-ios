import SwiftUI
import MapboxMaps

@available(iOS 14.0, *)
struct SnapshotMapExample: View {
    @State var image: UIImage?

    struct SnapshotterImage: Identifiable {
        var id: ObjectIdentifier { ObjectIdentifier(image) }
        let image: UIImage
    }
    @State var snapshotterImage: SnapshotterImage?
    @State var snapshotter = Snapshotter(options: MapSnapshotOptions(size: CGSize(width: 512, height: 512), pixelRatio: 2.0))

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 10) {
                MapReader { proxy in
                    Map(initialViewport: .helsinkiOverview)
                        .mapStyle(.outdoors)
                        .onMapIdle { _ in image = proxy.captureSnapshot() }
                        .onCameraChanged { event in
                            snapshotter.setCamera(to: CameraOptions(cameraState: event.cameraState))
                        }
                        .frame(height: geometry.size.height / 2)
                }

                SnapshotView(snapshot: image)
                    .frame(height: geometry.size.height / 2)
            }
        }
        .ignoresSafeArea()
        .safeOverlay(alignment: .bottom) {
            Button("Make snapshot via Snapshotter") {
                snapshotter.start(overlayHandler: nil) { result in
                    switch result {
                        case .success(let image):
                        self.snapshotterImage = SnapshotterImage(image: image)
                    case .failure(let error):
                        print("Failure: \(error)")
                    }
                }
            }
            .floating()
        }
        .onAppear {
            snapshotter.mapStyle = .standardSatellite
        }
        .sheet(item: $snapshotterImage) {
            Image(uiImage: $0.image)
                .resizable()
                .scaledToFit()
        }
    }
}

@available(iOS 14.0, *)
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

@available(iOS 14.0, *)
struct SnapshotMapExample_Preview: PreviewProvider {
    static var previews: some View {
        SnapshotMapExample()
    }
}
