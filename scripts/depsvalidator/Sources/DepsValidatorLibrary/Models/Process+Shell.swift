import Foundation

extension Process {
    static func shell(_ command: String) -> Self {
        let process = Self()
        process.launchPath = "/bin/bash"
        process.arguments = ["-c", command]
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
