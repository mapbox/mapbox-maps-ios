import Foundation
@testable import MapboxMaps
import XCTest

struct PlaySequenceCommand: AsyncCommand, Decodable {
    let filename: String
    let playbackCount: Int

    enum CodingKeys: String, CodingKey {
        case filename = "fileName"
        case playbackCount
    }

    @MainActor
    func execute() async throws {
        let subviews = UIViewController.rootController!.view.subviews
        guard let mapView = subviews.lazy.compactMap({ $0 as? MapView }).first else {
            throw ExecutionError.cannotFindMapboxMap
        }

        let url = Bundle.main.bundleURL.appendingPathComponent(filename, isDirectory: false)
        let replayContent = try String(contentsOf: url)

        let recorder = mapView.mapboxMap.makeRecorder()
        await recorder.replay(content: replayContent, playbackCount: playbackCount)
    }
}
