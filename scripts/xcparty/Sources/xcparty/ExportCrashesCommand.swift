import Foundation
import ArgumentParser
import XCResultKit

struct ExportCrashesCommand: ParsableCommand {
    static var configuration = CommandConfiguration(commandName: "crash-export")

    @Option(name: [.short, .customLong("output")], help: "Export crash reports to the outputPath", transform: { path in
        return URL(fileURLWithPath: (path as NSString).expandingTildeInPath,
                   relativeTo: URL(fileURLWithPath: FileManager.default.currentDirectoryPath))
    })
    var outputPath: URL

    @Option(name: [.customLong("path")], help: ArgumentHelp("Path to XCResult with crash reports", valueName: "path-to-xcresult" ), transform: { (path: String) in
        return URL(fileURLWithPath: (path as NSString).expandingTildeInPath,
                   relativeTo: URL(fileURLWithPath: FileManager.default.currentDirectoryPath))
    })
    var pathToXCResult: URL

    @Option(name: [.customLong("overwrite")])
    var shouldOverwrite: Bool = true

    func validate() throws {
        var isDirectory: ObjCBool = false

        guard
            FileManager.default.fileExists(atPath: pathToXCResult.path, isDirectory: &isDirectory),
            isDirectory.boolValue else {
            throw ValidationError("Path [to XCResult] argument should be a directory\n\tinput: '\(pathToXCResult.path)'")
        }

        guard
            FileManager.default.fileExists(atPath: outputPath.path, isDirectory: &isDirectory),
            isDirectory.boolValue else {
            throw ValidationError("Output path argument should be an existing directory\n\tinput: '\(outputPath.path)'")
        }
    }

    func run() throws {
        let resultFile = XCResultFile(url: pathToXCResult)
        let invocation = resultFile.getInvocationRecord()!

        invocation.actions
            .compactMap(\.actionResult.testsRef?.id)
            .compactMap(resultFile.getTestPlanRunSummaries)
            .flatMap(\.summaries)
            .flatMap(\.testableSummaries)
            .flatMap(\.tests)
            .flatMap(\.subtestGroups)
            .flatMap(\.subtestGroups)
            .flatMap(\.subtests)
            .compactMap(\.summaryRef?.id)
            .compactMap(resultFile.getActionTestSummary)
            .flatMap(\.activitySummaries)
            .flatMap(\.attachments)
            .forEach { attachment in
                if let url = export(attachment: attachment, xcResultFile: resultFile)?.path {
                    print(url)
                }
            }

    }

    @discardableResult
    func export(attachment: ActionTestAttachment, xcResultFile: XCResultFile) -> URL? {
        guard let payloadId = attachment.payloadRef?.id else {
            return nil
        }
        guard let payloadTempURL = xcResultFile.exportPayload(id: payloadId) else {
            return nil
        }

        let filename = attachment.filename ?? "\(payloadId).crash"
        let destinationURL = outputPath.appendingPathComponent(filename, isDirectory: false)
        do {

            if shouldOverwrite {
                return try FileManager.default.replaceItemAt(destinationURL, withItemAt: payloadTempURL)
            } else {
                try FileManager.default.copyItem(at: payloadTempURL, to: destinationURL)
                return destinationURL
            }
        } catch {
            print("Error during copying \(destinationURL.path): \(error.localizedDescription)")
            return nil
        }

    }
}
