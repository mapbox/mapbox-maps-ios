import Foundation
import XCResultKit
import ArgumentParser

struct MetricsCommand: ParsableCommand {
    static var configuration = CommandConfiguration(commandName: "metrics")

    @Option(name: [.customLong("path")], help: ArgumentHelp("Path to XCResult with perfomance metrics", valueName: "path-to-xcresult" ), transform: { (path: String) in
        return URL(fileURLWithPath: (path as NSString).expandingTildeInPath,
            relativeTo: URL(fileURLWithPath: FileManager.default.currentDirectoryPath))
    })
    var pathToXCResult: URL

    @Option(name: [.short, .long], help: "Git repository to be used for build metadata", transform: { path in
        (path as NSString).expandingTildeInPath
    })
    var repositoryPath: String

    @Flag(help: "Generate human-readable JSON")
    var humanReadable: Bool = false

    @Option(name: [.short, .customLong("output")], help: "Save generated content to the file", transform: { path in
        (path as NSString).expandingTildeInPath
    })
    var outputPath: String?

    func run() throws {
        let resultFile = XCResultFile(url: pathToXCResult)
        let metricTests = try parseMetrics(resultFile: resultFile)
        let content = try generateOutputContent(tests: metricTests)

        try outputContent(content)
    }

    func validate() throws {
        var isDirectory: ObjCBool = false
        guard
            FileManager.default.fileExists(atPath: repositoryPath, isDirectory: &isDirectory),
            isDirectory.boolValue else {
            throw ValidationError("Repository path argument should be a directory (input: '\(repositoryPath)')")
        }

        guard !shell("git -C \(repositoryPath) rev-parse HEAD ").starts(with: "fatal") else {
            throw ValidationError("Repository path argument should be a git repository")
        }

        guard
            FileManager.default.fileExists(atPath: pathToXCResult.path, isDirectory: &isDirectory),
            isDirectory.boolValue else {
            throw ValidationError("Path [to XCResult] argument should be a directory (input: '\(pathToXCResult.path)')")
        }
    }

    struct PerfomanceTest {
        let testName: String
        let metric: ActionTestPerformanceMetricSummary
        let actionRecord: ActionRecord

        static func metrics(from test: ActionTestMetadata, in resultFile: XCResultFile, for actionRecord: ActionRecord) -> [PerfomanceTest] {
            guard
                let testSummaryRef = test.summaryRef,
                let actionTestSummary = resultFile.getActionTestSummary(id: testSummaryRef.id)
            else { return [] }

            return actionTestSummary.performanceMetrics.map { metric in
                return PerfomanceTest(testName: refineTestFunctionName(test.name), metric: metric, actionRecord: actionRecord)
            }
        }
    }

    func parseMetrics(resultFile: XCResultFile) throws -> [PerfomanceTest] {
        let invocation = resultFile.getInvocationRecord()!
        let actionRecord = invocation.actions[0]
        let testPlanRunSummariesId = actionRecord.actionResult.testsRef!.id

        let testPlanRunSummaries = resultFile.getTestPlanRunSummaries(id: testPlanRunSummariesId)!

        let testTargetResults = testPlanRunSummaries.summaries[0] // name : "Test Scheme Action"
            .testableSummaries[0] // projectRelativePath: MobileMetrics.xcodeproj, targetName: MobileMetricsTests
            .tests[0] // name : "All tests"
            .subtestGroups[0]

        let testMetrics = testTargetResults.subtestGroups.flatMap { testSuit in
            testSuit.subtests.flatMap({ PerfomanceTest.metrics(from: $0, in: resultFile, for: actionRecord) })
        }

        return testMetrics
    }

    func generateOutputContent(tests: [PerfomanceTest]) throws -> String {
        return try tests
            .map { test in
                [
                    "name": "ios-maps-v2",
                    "version": 2,
                    "created": ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: [.withInternetDateTime]),
                    "counters": [
                        "id": test.metric.identifier!,
                        "displayName": test.metric.displayName,
                        "average": test.metric.measurements.reduce(0.0, +) / Double(test.metric.measurements.count),
                        "units": test.metric.unitOfMeasurement
                    ],
                    "attributes": [
                        "test_name": refineTestFunctionName(test.testName)
                    ],
                    "metadata": deviceMetadata(actionRecord: test.actionRecord),
                    "build": buildMetadata()
                ]
            }
            .map { json -> String in
                var options: JSONSerialization.WritingOptions = [.sortedKeys, .withoutEscapingSlashes]
                if humanReadable {
                    options.insert([.prettyPrinted])
                }
                let data = try JSONSerialization.data(withJSONObject: json, options: options)
                return String(data: data, encoding: .utf8) ?? ""
            }
            .joined(separator: "\n")
    }

    func deviceMetadata(actionRecord: ActionRecord) -> [String: Any] {
        /*
         ▿ ActionRunDestinationRecord
           - displayName : "PDX000193484"
           - targetArchitecture : "arm64e"
           ▿ targetDeviceRecord : ActionDeviceRecord
             - name : "PDX000193484"
             - isConcreteDevice : true
             - operatingSystemVersion : "15.0.2"
             - operatingSystemVersionWithBuildNumber : "15.0.2 (19A404)"
             - nativeArchitecture : "arm64e"
             - modelName : "iPhone 12 Pro"
             - modelCode : "iPhone13,3"
             - modelUTI : "com.apple.iphone-12-pro-1"
             - identifier : "0000810100184CE00152001E"
             - isWireless : nil
             - cpuKind : nil
             ▿ cpuCount : Optional<Int>
               - some : 0
             - cpuSpeedInMhz : nil
             - busSpeedInMhz : nil
             ▿ ramSizeInMegabytes : Optional<Int>
               - some : 0
             ▿ physicalCPUCoresPerPackage : Optional<Int>
               - some : 0
             ▿ logicalCPUCoresPerPackage : Optional<Int>
               - some : 0
             ▿ platformRecord : ActionPlatformRecord
               - identifier : "com.apple.platform.iphoneos"
               - userDescription : "iOS"
           ▿ localComputerRecord : ActionDeviceRecord
             - name : "My Mac"
             - isConcreteDevice : true
             - operatingSystemVersion : "11.2"
             - operatingSystemVersionWithBuildNumber : "11.2 (20D64)"
             - nativeArchitecture : "x86_64"
             - modelName : "Mac mini"
             - modelCode : "Macmini8,1"
             - modelUTI : "com.apple.macmini-2018"
             - identifier : "6BFD7522-4109-4780-9C2F-7DA7FB35554C"
             - isWireless : nil
             ▿ cpuKind : Optional<String>
               - some : "Unknown"
             ▿ cpuCount : Optional<Int>
               - some : 1
             - cpuSpeedInMhz : nil
             - busSpeedInMhz : nil
             ▿ ramSizeInMegabytes : Optional<Int>
               - some : 4096
             ▿ physicalCPUCoresPerPackage : Optional<Int>
               - some : 2
             ▿ logicalCPUCoresPerPackage : Optional<Int>
               - some : 2
             ▿ platformRecord : ActionPlatformRecord
               - identifier : "com.apple.platform.macosx"
               - userDescription : "macOS"
           ▿ targetSDKRecord : ActionSDKRecord
             - name : "iOS 15.0"
             - identifier : "iphoneos15.0"
             - operatingSystemVersion : "15.0"
             - isInternal : nil
         */
        return [
            "abi": actionRecord.runDestination.targetArchitecture,
            "brand": "Apple",
            "device": actionRecord.runDestination.targetDeviceRecord.modelCode,
            "deviceName": actionRecord.runDestination.targetDeviceRecord.modelName,
            "systemSDK": actionRecord.runDestination.targetSDKRecord.name,
//            "dpi": "2",
//            "gpu": "Apple A13 GPU",
//            "locale": "en_US",
            "manufacturer": "Apple",
//            "model": "N104AP",
            "os": actionRecord.runDestination.targetDeviceRecord.platformRecord.userDescription,
//            "ram": "4031430656",
//            "screen_resolution": "828x1792",
//            "storage_space": "54898139136",
            "version": actionRecord.runDestination.targetDeviceRecord.operatingSystemVersion
        ]
    }

    func buildMetadata() -> [String: Any] {

        let repositoryURL = URL(fileURLWithPath: repositoryPath,
            isDirectory: true,
            relativeTo: URL(fileURLWithPath: FileManager.default.currentDirectoryPath))

        let repoFullPath = repositoryURL.path

        func git(_ command: String) -> String {
            return shell("git -C '\(repoFullPath)' \(command)")
        }

        var baseMetadata: [String: Any] = [
            "sha": git("rev-parse HEAD"),
            "author": git("log -1 --pretty=format:'%an'"),
            "branch": git("rev-parse --abbrev-ref HEAD"),
            "message": git("log -1 --pretty=%B"),
            "project": shell("basename \(git("rev-parse --show-toplevel"))"),
            "timestamp": Int(git("log -1 --format=%at"))!
        ]
        if let ciBuildNumber = ProcessInfo.processInfo.environment["CIRCLE_BUILD_NUM"] {
            baseMetadata["ci_ref"] = ciBuildNumber
        }

        return baseMetadata
    }

    func outputContent(_ content: String) throws {
        if let outputPath = outputPath {
            let outputURL = URL(fileURLWithPath: outputPath,
                                   relativeTo: URL(fileURLWithPath: FileManager.default.currentDirectoryPath))
            try content.write(to: outputURL, atomically: true, encoding: .utf8)
        } else {
            print(content)
        }
    }
}

func refineTestFunctionName(_ name: String) -> String {
    return name
        .replacingOccurrences(of: "test_sla_", with: "")
        .replacingOccurrences(of: "()", with: "")
}

func shell(_ command: String) -> String {
    let task = Process()
    let pipe = Pipe()

    task.standardOutput = pipe
    task.standardError = pipe
    task.arguments = ["-c", command]
    task.launchPath = "/bin/zsh"
    task.launch()
    task.waitUntilExit()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)!

    return output.trimmingCharacters(in: .whitespacesAndNewlines)
}
