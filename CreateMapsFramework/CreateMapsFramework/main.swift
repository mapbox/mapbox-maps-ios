import Foundation


// MARK:- Parse arguments + Setup
let args = CommandLine.arguments
let fm = FileManager.default
guard args.count == 2 else {
    fatalError("Invalid arguments. Usage: \(args[0]) <path-to-bundle-zip>")
}
let currentDirectoryURL = URL(fileURLWithPath: fm.currentDirectoryPath)

let zipURL = URL(fileURLWithPath: args[1])
let unzipDestinationURL = currentDirectoryURL.appendingPathComponent("MapboxMaps.unzipped")

// Unzip file to destination
unzip(file: zipURL, to: unzipDestinationURL)

let artifactsURL = unzipDestinationURL.appendingPathComponent("artifacts")
let outputURL = currentDirectoryURL.appendingPathComponent("MapboxMaps.Output")
let buildURL = currentDirectoryURL.appendingPathComponent("MapboxMaps.Tmp")

do {
    try fm.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
    try fm.createDirectory(at: buildURL, withIntermediateDirectories: true, attributes: nil)
} catch {
    fatalError("Could not create build/output directories due to error: \(error)")
}

// MARK:- Create xcframework

let xcframeworks = XCFramework.readListOfXcFrameworks(in: artifactsURL)

for xcframework in xcframeworks {
    print("Creating fat fromework from \(xcframework.name).xcframework")
    xcframework.createFatFramework(withBuildDirectory: buildURL, outputDirectory: outputURL)
}


// MARK:- Cleanup
do {
    try fm.removeItem(at: unzipDestinationURL)
    try fm.removeItem(at: buildURL)
    try fm.removeItem(at: outputURL)
} catch {
    print("Could not clean up! Error: \(error)")
}

// MARK:- Data structures
enum LibraryType {
    case device
    case simulator
    case maccatalyst
}

struct Framework {
    var url: URL
    var info: InfoPlist

    var executable: URL {
        return url.appendingPathComponent(info.executable)
    }

    init(url: URL) throws {
        self.url = url
        let data = try Data(contentsOf: url.appendingPathComponent("Info.plist"))
        self.info = try PropertyListDecoder().decode(InfoPlist.self, from: data)
    }

    private static let lipoInfoRegex = try! NSRegularExpression(
        pattern: "^(?:Non-fat file|Architectures in the fat file): [^:]*: ((?:[^ ]+ ?)+)", options: [])

    func extract(architectures: [String], to destination: URL) {
        func parseArchitectures(fromLipoInfoOutput lipoInfoOutput: String) -> [String] {
            let nsString = NSString(string: lipoInfoOutput)
            let matches = Self.lipoInfoRegex.matches(in: lipoInfoOutput, options: [], range: NSRange(location: 0, length: nsString.length))
            guard matches.count == 1, let match = matches.first, match.numberOfRanges == 2 else {
                return []
            }
            
            let archsString: [String] = String(nsString.substring(with: match.range(at: 1))).components(separatedBy: " ")
            return archsString.map { $0.replacingOccurrences(of: "\n", with: "") }
        }

        // Use `lipo <binary> -info` to make sure the binary contains the requisite architectures
        guard let lipoInfoOutput = launch(command: "lipo", arguments: [executable.path, "-info"]) else {
            fatalError("Command 'lipo \(executable.path) -info' failed")
        }

        let availableArchs = parseArchitectures(fromLipoInfoOutput: lipoInfoOutput)
        guard Set(architectures).isSubset(of: availableArchs) else {
            fatalError("Framework \(url.path) contains architectures \(availableArchs), but the required archs are \(architectures).")
        }

        guard availableArchs.count > 1 else {
            // not a universal binary, so just copy it to destination
            do {
                try fm.copyItem(at: executable, to: destination)
            } catch {
                fatalError("Error while copying \(executable.path) to \(destination.path): \(error)")
            }
            return
        }

        // universal binary, so extract the desired architectures
        let extractArgs = architectures.flatMap { ["-extract", $0] }
        let arguments = [executable.path] + extractArgs + ["-output", destination.path]
        launch(command: "lipo", arguments: arguments, streamOutput: true)
    }

    struct InfoPlist: Decodable {
        var executable: String

        enum CodingKeys: String, CodingKey {
            case executable = "CFBundleExecutable"
        }
    }
}

struct XCFramework {

    var url: URL
    var info: InfoPlist

    var name: String {
        return url.deletingPathExtension().lastPathComponent
    }

    var deviceFramework: Framework {
        let library = info.library(for: .device)!
        return try! Framework(url: url.appendingPathComponent(library.libraryIdentifier)
                  .appendingPathComponent(library.libraryPath))
    }

    var simulatorFramework: Framework {
        let library = info.library(for: .simulator)!
        return try! Framework(url: url.appendingPathComponent(library.libraryIdentifier)
                  .appendingPathComponent(library.libraryPath))
    }

    init(url: URL) {
        self.url = url
        do {
            let data = try Data(contentsOf: url.appendingPathComponent("Info.plist"))
            self.info = try PropertyListDecoder().decode(InfoPlist.self, from: data)
        } catch {
            fatalError("Could not create XCFramework object due to error: \(error)")
        }
    }

    static func readListOfXcFrameworks(in directory: URL) -> [XCFramework] {
        do {
            let fileNames = try fm.contentsOfDirectory(atPath: directory.path)
            let fileUrls = fileNames.map { directory.appendingPathComponent($0) }
            let xcframeworkUrls = fileUrls.filter { $0.pathExtension == "xcframework" }
            guard xcframeworkUrls.count > 0 else {
                fatalError("Could not find any xcframeworks.")
            }
            return xcframeworkUrls.map { XCFramework(url: $0) }
        } catch {
            fatalError("Could not read contents of directory due to error: \(error)")
        }
    }

    func createFatFramework(withBuildDirectory buildDirectory: URL, outputDirectory: URL) {

        // Define intermediate build paths
        let extractedDeviceBinaryURL = buildDirectory.appendingPathComponent("\(name)-device")
        let extractedSimulatorBinaryURL = buildDirectory.appendingPathComponent("\(name)-simulator")
        let combinedBinaryURL = buildDirectory.appendingPathComponent("\(name)-combined")

        // Extract required architectures
        deviceFramework.extract(architectures: ["arm64"], to: extractedDeviceBinaryURL)
        simulatorFramework.extract(architectures: ["x86_64"], to: extractedSimulatorBinaryURL)

        // Combine binaries
        combineBinaries(atBinaryUrls: [extractedDeviceBinaryURL, extractedSimulatorBinaryURL], to: combinedBinaryURL)

        // Create framework and copy required directories
        let frameworkURL = outputURL.appendingPathComponent(name + ".framework")
        do {
            print("Creating directory at \(frameworkURL.path).")
            try fm.createDirectory(at: frameworkURL, withIntermediateDirectories: false, attributes: nil)
            
            print("Copy 'Headers' from \(simulatorFramework.url.appendingPathComponent("Headers")) to \(frameworkURL.path).")
            try fm.copyItem(at: simulatorFramework.url.appendingPathComponent("Headers"),
                            to: frameworkURL.appendingPathComponent("Headers"))
            
            print("Copy 'Modules' from \(simulatorFramework.url.appendingPathComponent("Modules")) to \(frameworkURL.path).")
            try fm.copyItem(at: simulatorFramework.url.appendingPathComponent("Modules"),
                            to: frameworkURL.appendingPathComponent("Modules"))
            
            print("Copy 'Info.plist' from \(simulatorFramework.url.appendingPathComponent("Info.plist")) to \(frameworkURL.path).")
            try fm.copyItem(at: simulatorFramework.url.appendingPathComponent("Info.plist"),
                            to: frameworkURL.appendingPathComponent("Info.plist"))
            
            print("Copy combined binary from \(combinedBinaryURL) to \(frameworkURL.path).")
            try fm.copyItem(at: combinedBinaryURL,
                            to: frameworkURL.appendingPathComponent(name))
        } catch {
            fatalError("Could not create fat framework due to error: \(error)")
        }
    }

    func combineBinaries(atBinaryUrls binaryUrls:[URL], to output: URL) {
        let arguments = [ "-create"] + binaryUrls.map { $0.path } + ["-output", output.path]
        launch(command: "lipo", arguments: arguments, streamOutput: true)
    }

    struct InfoPlist: Decodable {

        var availableLibraries: [XCFrameworkLibrary]

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.availableLibraries = try container.decode([XCFrameworkLibrary].self, forKey: .availableLibraries)
        }

        func library(for type: LibraryType) -> XCFrameworkLibrary? {
            return self.availableLibraries.first { $0.type == type}
        }

        enum CodingKeys: String, CodingKey {
            case availableLibraries = "AvailableLibraries"
        }

        struct XCFrameworkLibrary: Decodable {
            var libraryIdentifier: String
            var libraryPath: String
            var supportedArchitectures: [String]
            var supportedPlatformVariant: String?

            var type: LibraryType {
                switch supportedPlatformVariant {
                case .none:
                    return .device
                case .some("simulator"):
                    return .simulator
                case .some("maccatalyst"):
                    return .maccatalyst
                default:
                    fatalError("Unsupported library type")
                }
            }

            enum CodingKeys: String, CodingKey {
                case libraryIdentifier = "LibraryIdentifier"
                case libraryPath = "LibraryPath"
                case supportedArchitectures = "SupportedArchitectures"
                case supportedPlatformVariant = "SupportedPlatformVariant"
            }
        }
    }
}

// MARK:- Process management
extension Process {
    @discardableResult
    public func shell(command: String, streamOutput: Bool = false) -> String? {
        launchPath = "/bin/bash"
        arguments = ["-c", command]

        if (streamOutput) {
            standardOutput = FileHandle.standardOutput
            launch()
            waitUntilExit()
            return nil
        } else {
            let outputPipe = Pipe()
            standardOutput = outputPipe
            launch()
            let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
            guard let outputData = String(data: data, encoding: String.Encoding.utf8) else {
                fatalError("Error converting data")
            }
            return outputData
        }
    }
}

@discardableResult
public func launch(command: String, arguments: [String], streamOutput: Bool = false) -> String? {
    let process = Process()
    let command = "\(command) \(arguments.joined(separator: " "))"
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .replacingOccurrences(of: "  ", with: " ")
        .replacingOccurrences(of: "\n", with: "")
    print("\u{001B}[0;32mRunning command:\u{001B}[0;33m \"\(command)\" \u{001B}[0;0m\n")
    return process.shell(command: command, streamOutput: streamOutput)
}

func unzip(file zipFile: URL, to destination: URL) {
    let arguments = [zipFile.path, "-d", destination.path]
    launch(command: "unzip", arguments: arguments, streamOutput: false)
}
