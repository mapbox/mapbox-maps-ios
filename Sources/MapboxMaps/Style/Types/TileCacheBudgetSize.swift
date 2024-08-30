import MapboxCoreMaps

/// Defines a TileCacheBudgetSize, which can be set as either a megabyte or tile count limit.
/// Whenever tile cache goes over the defined limit
/// the least recently used tile will be evicted from the in-memory cache
///
///  To use, create a TileCacheBudgetSize and then either:
///  (1) Set it for an individual source with with the tileCacheBudget property, or
///  (2) Set if for the map with ``MapboxMap/setTileCacheBudget(size:)``
public enum TileCacheBudgetSize: Sendable {

    /// A tile cache budget measured in tile units
    case tiles(Int)

    /// A tile cache budget measured in megabyte units
    case megabytes(Int)

    /// The TileCacheBudget formatted for core
    var coreTileCacheBudget: TileCacheBudget {
        switch self {
        case .tiles(let size):
            return TileCacheBudget.fromTileCacheBudget(TileCacheBudgetInTiles(size: UInt64(size)))
        case .megabytes(let size):
            return TileCacheBudget.fromTileCacheBudget(TileCacheBudgetInMegabytes(size: UInt64(size)))
        }
    }
}

extension TileCacheBudgetSize: Codable, Equatable {
    enum CodingKeys: String, CodingKey {
        case tiles
        case megabytes
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        guard let budget = container.allKeys.first,
              container.allKeys.count == 1 else {
            throw TypeConversionError.invalidObject
        }

        switch budget {
        case .tiles:
            self = .tiles(try container.decode(Int.self, forKey: .tiles))
        case .megabytes:
            self = .megabytes(try container.decode(Int.self, forKey: .megabytes))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .tiles(let size):
            try container.encode(size, forKey: .tiles)
        case .megabytes(let size):
            try container.encode(size, forKey: .megabytes)
        }
    }
}
