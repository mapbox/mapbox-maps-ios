import SwiftUI
import MapboxMaps

class VisitManager: ObservableObject {
    @Published private var visitedIds: Set<String> = []

    func visitFeature(_ mapboxId: String) {
        visitedIds.insert(mapboxId)
    }

    var allVisitedIds: [String] {
        Array(visitedIds)
    }
}
