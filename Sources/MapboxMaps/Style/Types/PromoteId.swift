import Foundation

/// Denotes promote-id setting for ``VectorSource``.
///
/// In vector sources, a promote-id setting can be applied globally for all layers, or individually for each vector source layer.
public enum VectorSourcePromoteId: Equatable, Codable, Sendable {
    // The promoteId will be applied to all layers in the vector source.
    case global(Value<String>)

    // The promoteId will be applied per each layer in the vector source.
    case byLayer([String: Value<String>])

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let decodedSingle = try? container.decode(Value<String>.self) {
            self = .global(decodedSingle)
            return
        }

        if let decodedDict = try? container.decode([String: Value<String>].self) {
            self = .byLayer(decodedDict)
            return
        }

        let context = DecodingError.Context(codingPath: decoder.codingPath,
                                            debugDescription: "Failed to decode VectorSourcePromoteId")
        throw DecodingError.dataCorrupted(context)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .global(let string):
            try container.encode(string)
        case .byLayer(let object):
            try container.encode(object)
        }
    }
}

@available(*, deprecated, message: "Use VectorSourcePromoteId instead")
public enum PromoteId: Equatable, Codable, Sendable {
    case string(String)
    case object([String: String])

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let decodedString = try? container.decode(String.self) {
            self = .string(decodedString)
            return

        } else if let decodedObject = try? container.decode([String: String].self) {
            self = .object(decodedObject)
            return
        }

        let context = DecodingError.Context(codingPath: decoder.codingPath,
                                            debugDescription: "Failed to decode PromoteId")
        throw DecodingError.dataCorrupted(context)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .string(let string):
            try container.encode(string)
        case .object(let object):
            try container.encode(object)
        }
    }

    init?(from: VectorSourcePromoteId?) {
        guard let from else { return nil }
        switch from {
        case let .global(val):
            guard let constant = val.asConstant else { return nil }
            self = .string(constant)
        case let .byLayer(dict):
            self = .object(dict.compactMapValues { $0.asConstant })
        }
    }

    init?(from: Value<String>?) {
        guard let from, let const = from.asConstant else { return nil }
        self = .string(const)
    }
}

@available(*, deprecated)
extension VectorSourcePromoteId {
    init?(from: PromoteId?) {
        guard let from else { return nil }
        switch from {
        case .string(let string):
            self = .global(.constant(string))
        case .object(let dict):
            self = .byLayer(dict.mapValues { .constant($0) })
        }
    }
}

@available(*, deprecated)
extension Value where T == String {
    init?(from: PromoteId?) {
        if let from,
           case let .string(string) = from {
            self = .init(constant: string)
        } else {
            return nil
        }
    }
}
