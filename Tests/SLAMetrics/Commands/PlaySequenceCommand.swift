import Foundation
@_spi(Internal) import MapboxMaps
import XCTest

struct PlaySequenceCommand: AsyncCommand, Decodable {
    private let playbackContent: PlaybackContent
    let playbackCount: Int

    enum CodingKeys: String, CodingKey {
        case filename = "fileName"
        case playbackCount
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            filename: try container.decode(String.self, forKey: .filename),
            playbackCount: try container.decode(Int.self, forKey: .playbackCount))
    }

    init(filename: String, playbackCount: Int) throws {
        self.playbackCount = playbackCount
        let fileURL = try Bundle.testSpecifications.bundleURL.appendingPathComponent(filename, isDirectory: false)
        let platformFileURL = fileURL.appendingSuffixToLastPathComponent("-ios")
        do {
            playbackContent = try PlaybackContent(variants: [
                fileURL,
                platformFileURL,
                fileURL.appendingPathExtension("gz"),
                platformFileURL.appendingPathExtension("gz")
            ])
        } catch {
            throw error
        }
    }

    @MainActor
    func execute(context: Context) async throws {
        let recorder = context.mapView.mapboxMap.makeRecorder()
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

    init(variants urls: [URL]) throws {
        let content = urls.lazy
                          .compactMap({ try? PlaybackContent(contentsOf: $0) })
                          .first

        guard let content = content else {
            throw ExecutionError.resourceFileNotFound
        }
        self = content
    }
}
