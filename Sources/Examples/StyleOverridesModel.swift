import SwiftUI
import Combine
@_spi(Internal) import MapboxMaps

class StyleOverridesModel: ObservableObject {
    @Published var overrides: [StyleOverride] = [] {
        didSet {
            saveOverrides()
            applyOverrides()
        }
    }

    @Published var previouslyUsedURIs: [String: Date] = [:] {
        didSet {
           savePreviouslyUsed()
        }
    }

    var activeCount: Int {
        overrides.filter { $0.active }.count
    }

    private let userDefaults: UserDefaults = .standard

    init() {
        loadOverrides()
        loadPreviouslyUsedURIs()
        applyOverrides()
    }

    private func saveOverrides() {
        if let encoded = try? JSONEncoder().encode(overrides) {
            userDefaults.set(encoded, forKey: "styleOverrides")
        }
    }

    private func savePreviouslyUsed() {
        if let encoded = try? JSONEncoder().encode(previouslyUsedURIs) {
            userDefaults.set(encoded, forKey: "previouslyUsedURIs")
        }
    }

    private func loadPreviouslyUsedURIs() {
        guard let data = userDefaults.data(forKey: "previouslyUsedURIs"),
              let decoded = try? JSONDecoder().decode([String: Date].self, from: data)
        else { return }
        previouslyUsedURIs = decoded
    }

    private func loadOverrides() {
        guard let data = userDefaults.data(forKey: "styleOverrides"),
              let decoded = try? JSONDecoder().decode([StyleOverride].self, from: data)
        else { return }
        overrides = decoded
    }

    private func applyOverrides() {
        MapStyle._overrides.removeAll()
        overrides.forEach { override in
            guard override.active else { return }
            MapStyle._overrides[override.baseStyle] = override.asMapStyle
        }
    }

    func save(override: StyleOverride) {
        let index = overrides.firstIndex { $0.id == override.id }
        if let index {
            overrides[index] = override
        } else {
            overrides.append(override)
        }
        // disable all overrides with the same base style uri
        for i in overrides.indices {
            if overrides[i].id != override.id && overrides[i].baseStyle == override.baseStyle {
                overrides[i].active = false
            }
        }

        previouslyUsedURIs[override.style.rawValue] = Date()
        previouslyUsedURIs[override.baseStyle.rawValue] = Date()
    }

    func remove(with id: UUID) {
        overrides.removeAll(where: { $0.id == id })
    }
}

extension StyleURI: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        guard let styleURI = StyleURI(rawValue: rawValue) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid StyleURI: \(rawValue)")
        }
        self = styleURI
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

struct StyleOverride: Equatable, Codable, Identifiable {
    var id = UUID()
    var baseStyle: StyleURI
    var style: StyleURI
    var options: [ConfigOption]
    var active = true

    var asMapStyle: MapStyle {
        let jsonObject: JSONObject = Dictionary(uniqueKeysWithValues: options.map { ($0.key, $0.value as JSONValue?) })
        return .init(uri: style, configuration: jsonObject.isEmpty ? nil : jsonObject)
    }

    var asText: String {
        var text = style.rawValue
        if !options.isEmpty {
            for keyValue in options {
                text += "\n  - \(keyValue.key): \(keyValue.value.asText)"
            }
        }
        return text
    }
}

struct ConfigOption: Equatable, Identifiable, Codable {
    let id: UUID
    var key: String
    var value: JSONValue

    init(key: String = "", value: JSONValue = .string("")) {
        self.id = UUID()
        self.key = key
        self.value = value
    }
}

extension JSONValue {
    var asText: String {
        switch self {
        case .string(let str): str
        case .number(let num): String(num)
        case .boolean(let bool): bool ? "true" : "false"
        case .array(let array): String(describing: array)
        case .object(let object): String(describing: object)
        default: ""
        }
    }
}
