import Foundation

extension Process {
    static func shell(_ command: String, environment: [String: String]? = nil) -> Self {
        let process = Self()
        process.launchPath = "/bin/bash"
        process.arguments = ["-c", command]
        if let environment = environment {
            process.environment = process.environment ?? [:]
            process.environment?.merge(environment, uniquingKeysWith: { (_, rhs) in rhs })
        }
        return process
    }

    var outputString: String {
        return String(data: output, encoding: .utf8)!
    }

    var output: Data {
        let outputPipe = Pipe()
        standardOutput = outputPipe
        launch()
        return outputPipe.fileHandleForReading.readDataToEndOfFile()
    }
}
