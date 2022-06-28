import Foundation

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
