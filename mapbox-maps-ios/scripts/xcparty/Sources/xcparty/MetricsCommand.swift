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

    /// Deprecated
    @Option(name: [.customLong("single-run-test-ids")], help: "DERPECATED. Pass test id in format 'TestSuite/testExample()' to ignore all but last run measurements")
    var listOfSingleRunTests: [String] = []

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

        guard shell("git -C \(repositoryPath) rev-parse HEAD").terminatedSuccessfully else {
            throw ValidationError("Repository path argument should be a git repository")
        }

        guard
            FileManager.default.fileExists(atPath: pathToXCResult.path, isDirectory: &isDirectory),
            isDirectory.boolValue else {
            throw ValidationError("Path [to XCResult] argument should be a directory (input: '\(pathToXCResult.path)')")
        }
    }

    struct PerformanceTest {
        let testName: String
        let metrics: [ActionTestPerformanceMetricSummary]
        let actionRecord: ActionRecord
        let shouldProcessOnlyLastRun: Bool

        static func metrics(from test: ActionTestMetadata,
                            in resultFile: XCResultFile,
                            for actionRecord: ActionRecord,
                            shouldProcessOnlyLastRun: Bool) -> PerformanceTest? {
            guard
                let testName = test.name,
                let testSummaryRef = test.summaryRef,
                let actionTestSummary = resultFile.getActionTestSummary(id: testSummaryRef.id)
            else { return nil }

            return PerformanceTest(testName: refineTestFunctionName(testName),
                                   metrics: actionTestSummary.performanceMetrics,
                                   actionRecord: actionRecord,
                                   shouldProcessOnlyLastRun: shouldProcessOnlyLastRun)
        }
    }

    func parseMetrics(resultFile: XCResultFile) throws -> [PerformanceTest] {
        let invocation = resultFile.getInvocationRecord()!

        return invocation.actions.flatMap { actionOnConcreteDevice -> [PerformanceTest] in
            let testPlanRunSummariesId = actionOnConcreteDevice.actionResult.testsRef!.id

            let testPlanRunSummaries = resultFile.getTestPlanRunSummaries(id: testPlanRunSummariesId)!

            let testTargetResults = testPlanRunSummaries.summaries[0] // name : "Test Scheme Action"
                .testableSummaries[0] // projectRelativePath: MobileMetrics.xcodeproj, targetName: MobileMetricsTests
                .tests[0] // name : "All tests"
                .subtestGroups[0]

            return testTargetResults.subtestGroups.flatMap { testSuit in
                testSuit.subtests.compactMap({ subtest in
                    guard let identifier = subtest.identifier else { return nil }

                    return PerformanceTest.metrics(from: subtest,
                                                   in: resultFile,
                                                   for: actionOnConcreteDevice,
                                                   shouldProcessOnlyLastRun: listOfSingleRunTests.contains(identifier))
                })
            }
        }
    }

    static var decimalValueFormatter: NumberFormatter = {
        let valueFormatter = NumberFormatter()
        valueFormatter.numberStyle = .decimal
        valueFormatter.usesGroupingSeparator = false
        valueFormatter.locale = Locale(identifier: "en_US_POSIX")

        return valueFormatter
    }()

    func generateOutputContent(tests: [PerformanceTest]) throws -> String {
        return try tests
            .flatMap(generateTestReport)
            .map(convertToString)
            .joined(separator: "\n")
    }

    func generateTestReport(test: PerformanceTest) -> [[String: Any]] {
        let testName = refineTestFunctionName(test.testName)
        let createdDate = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: [.withInternetDateTime])
        let testUUID = UUID()

        let numberOfRuns = test.metrics.map({ $0.measurements.count }).max() ?? 0

        return (0..<numberOfRuns).map { runIndex in
            let counters = test.metrics.reduce(into: [:]) { partialResult, metric in
                guard metric.measurements.indices.contains(runIndex) else { return }

                let value = metric.measurements[runIndex]
                let metricName = metric.displayName.replacingOccurrences(of: " ", with: "")

                partialResult[metricName] = MetricsCommand.decimalValueFormatter.string(from: value as NSNumber)
                partialResult[metricName+"_units"] = metric.unitOfMeasurement
            }

            let report: [String: Any] = [
                "name": "ios-maps-v2",
                "version": 3,
                "created": createdDate,
                "counters": counters,
                "attributes": [
                    "test_name": testName,
                    "run_index": runIndex,
                    "test_id": testUUID.uuidString
                ],
                "metadata": deviceMetadata(actionRecord: test.actionRecord),
                "build": buildMetadata()
            ]
            return report
        }
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

    static var cachedBuildMetadata: [String: Any]!

    func buildMetadata() -> [String: Any] {
        guard MetricsCommand.cachedBuildMetadata == nil else { return MetricsCommand.cachedBuildMetadata }

        let repositoryURL = URL(fileURLWithPath: repositoryPath,
            isDirectory: true,
            relativeTo: URL(fileURLWithPath: FileManager.default.currentDirectoryPath))

        let repoFullPath = repositoryURL.path

        func git(_ command: String) -> Process {
            return shell("git -C '\(repoFullPath)' \(command)")
        }

        var buildMetadata: [String: Any] = [:]
        buildMetadata["sha"] = git("rev-parse HEAD").output
        buildMetadata["author"] = git("log -1 --format=%an").output
        buildMetadata["branch"] = git("rev-parse --abbrev-ref HEAD").output
        buildMetadata["message"] = git("log -1 --format=%B").output
        buildMetadata["project"] = git("rev-parse --show-toplevel").output
            .map { URL(fileURLWithPath: $0).lastPathComponent }
        buildMetadata["timestamp"] = git("log -1 --format=%at").output.flatMap(Int.init)

        if let ciBuildNumber = ProcessInfo.processInfo.environment["CIRCLE_BUILD_NUM"] {
            buildMetadata["ci_ref"] = ciBuildNumber
        }

        if let tagName = git("describe --tags --exact-match HEAD").output, tagName.starts(with: "v") {
            buildMetadata["tag_name"] = tagName
        }

        MetricsCommand.cachedBuildMetadata = buildMetadata

        return buildMetadata
    }

    func convertToString(input: [String: Any]) throws -> String {
        var options: JSONSerialization.WritingOptions = [.sortedKeys, .withoutEscapingSlashes]
        if humanReadable {
            options.insert([.prettyPrinted])
        }
        let data = try JSONSerialization.data(withJSONObject: input, options: options)
        return String(data: data, encoding: .utf8) ?? ""
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
