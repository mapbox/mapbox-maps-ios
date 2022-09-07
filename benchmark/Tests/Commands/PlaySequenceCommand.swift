import Foundation
@testable import MapboxMaps
import XCTest
import DataCompression

struct PlaySequenceCommand: AsyncCommand, Decodable {
    private let playbackContent: PlaybackContent
    let playbackCount: Int

    enum CodingKeys: String, CodingKey {
        case filename = "fileName"
        case playbackCount
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        playbackCount = try container.decode(Int.self, forKey: .playbackCount)

        let fileName = try container.decode(String.self, forKey: .filename)
        let fileURL = Bundle.main.bundleURL.appendingPathComponent(fileName, isDirectory: false)
        do {
            playbackContent = try PlaybackContent(contentsOf: fileURL)
        } catch ExecutionError.resourceFileNotFound {
            playbackContent = try PlaybackContent(contentsOf: fileURL.appendingPathExtension("gz"))
        } catch {
            throw error
        }
    }

    @MainActor
    func execute() async throws {
        let subviews = UIViewController.rootController!.view.subviews
        guard let mapView = subviews.lazy.compactMap({ $0 as? MapView }).first else {
            throw ExecutionError.cannotFindMapboxMap
        }

        let recorder = mapView.mapboxMap.makeRecorder()
        await recorder.replay(content: playbackContent.content, playbackCount: playbackCount)
    }
}

private struct PlaybackContent {
    let content: String

    enum FileExtension: String {
        case json, gz
    }

    init(contentsOf url: URL) throws {
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw ExecutionError.resourceFileNotFound
        }

        switch FileExtension(rawValue: url.pathExtension) {
        case .json:
            self.content = try String(contentsOf: url)
        case .gz:
            // If the data at the given url is compressed data, we assume it is using gzip format,
            // and will first decompress the data to pass it to MapRecorder/.
            // GL-Native 10.9.0-beta-1 will support gzip data for MapRecorder, by then we will be
            // using that new API and dismiss this implementation.
            if let data = try Data(contentsOf: url).gunzip(), let content = String(data: data, encoding: .utf8) {
                self.content = content
            } else {
                fallthrough
            }
        case .none:
            throw ExecutionError.unsupportedResourceFile
        }
    }
}
