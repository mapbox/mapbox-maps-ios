import Foundation

func refineTestFunctionName(_ name: String) -> String {
    return name
        .replacingOccurrences(of: "test_sla_", with: "")
        .replacingOccurrences(of: "()", with: "")
}

func shell(_ command: String) -> Process {
    let task = Process()
    let pipe = Pipe()

    task.standardOutput = pipe
    task.standardError = pipe
    task.arguments = ["-c", command]
    task.launchPath = "/bin/zsh"
    task.launch()
    task.waitUntilExit()

    return task
}

extension Process {
    var output: String? {
        guard terminatedSuccessfully else { return nil }

        guard let pipe = standardOutput as? Pipe else { return nil }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var terminatedSuccessfully: Bool {
        return terminationStatus == EXIT_SUCCESS
    }
}
