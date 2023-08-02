import Foundation
import MapboxMaps

struct TakeSnapshotCommand: AsyncCommand, Decodable {

    @MainActor
    func execute(context: Context) async throws {
        guard let mapView = context.mapView else {
            throw ExecutionError.cannotFindMapboxMap
        }

        let size = mapView.bounds.size
        let renderer = UIGraphicsImageRenderer(size: size)

        // Wait for the map to draw everything before taking a snapshot
        _ = try await withCheckedThrowingContinuation { continuation in
            mapView.mapboxMap.onMapIdle.observeNext { event in
                let image = renderer.image { context in
                    _ = mapView.drawHierarchy(in: CGRect(origin: .zero, size: size), afterScreenUpdates: true)
                }

                return continuation.resume(returning: image)
            }.store(in: &context.cancellables)
        }
    }
}
