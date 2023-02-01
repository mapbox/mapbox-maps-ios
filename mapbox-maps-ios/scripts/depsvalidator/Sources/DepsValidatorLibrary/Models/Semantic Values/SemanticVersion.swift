import Foundation

struct SemanticVersion: Hashable, Comparable, CustomStringConvertible, Decodable {

    enum Error: Swift.Error, Equatable {
        case notASemanticVersion(String)
    }

    // swiftlint:disable:next force_try
    private static let regex = try! NSRegularExpression(
        pattern: "^v?(?<major>[0-9]+).(?<minor>[0-9]+)(?:.(?<patch>[0-9]+)(?<suffix>.*)?)?$", options: [])

    init(string: String) throws {
        let nsString = NSString(string: string)
        let matches = Self.regex.matches(in: string, options: [], range: NSRange(location: 0, length: nsString.length))
        guard matches.count == 1, let match = matches.first else {
            throw Error.notASemanticVersion(string)
        }
        major = Int(nsString.substring(with: match.range(withName: "major")))!
        minor = Int(nsString.substring(with: match.range(withName: "minor")))!

        let patchRange = match.range(withName: "patch")
        if patchRange.location != NSNotFound {
            patch = Int(nsString.substring(with: patchRange))
        }

        let suffixRange = match.range(withName: "suffix")
        if suffixRange.location != NSNotFound, suffixRange.length > 0 {
            suffix = nsString.substring(with: suffixRange)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        self = try SemanticVersion(string: string)
    }

    var description: String {
        let versionComponent = components.map { $0.description }.joined(separator: ".")
        return "v\(versionComponent)\(suffix ?? "")"
    }

    var major: Int

    var minor: Int

    var patch: Int?

    var suffix: String?

    var nextMajor: SemanticVersion {
        var result = self
        result.major += 1
        result.minor = 0
        result.patch = nil
        result.suffix = nil
        return result
    }

    var nextMinor: SemanticVersion {
        var result = self
        result.minor += 1
        result.patch = nil
        result.suffix = nil
        return result
    }

    var components: [Int] {
        [major, minor, patch].compactMap { $0 }
    }

    static func == (lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
        lhs.major == rhs.major
            && lhs.minor == rhs.minor
            && (lhs.patch ?? 0) == (rhs.patch ?? 0)
            && lhs.suffix == rhs.suffix
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(major)
        hasher.combine(minor)
        hasher.combine(patch ?? 0)
        hasher.combine(suffix)
    }

    static func < (lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
        lhs.components.lexicographicallyPrecedes(rhs.components)
    }
}
