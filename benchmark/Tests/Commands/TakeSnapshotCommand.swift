import Foundation
import MapboxMaps

struct TakeSnapshotCommand: AsyncCommand, Decodable {

    @MainActor
    func execute() async throws {
        guard let mapView = UIViewController.rootController?.findMapView() else {
            throw ExecutionError.cannotFindMapboxMap
        }

        let size = mapView.bounds.size
        let renderer = UIGraphicsImageRenderer(size: size)

        // Wait for the map to draw everything before taking a snapshot
        try await Task.sleep(nanoseconds: 1_000_000_000)

        let _ = renderer.image { context in
            mapView.drawHierarchy(in: CGRect(origin: .zero, size: size), afterScreenUpdates: true)
        }
    }
}
