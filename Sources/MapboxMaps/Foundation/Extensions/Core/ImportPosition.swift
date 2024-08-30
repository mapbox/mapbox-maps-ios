/// Specifies the position at which an import will be added when using `Style.addImport`
public enum ImportPosition: Equatable, Codable, Sendable {
    /// Default behavior; add to the top of the imports stack.
    case `default`

    /// Import should be positioned above the specified import id.
    case above(String)

    /// Import should be positioned below the specified import id.
    case below(String)

    /// Import should be positioned at the specified index in the imports stack.
    case at(Int)

    var corePosition: CoreImportPosition {
        switch self {
        case .default:
            return CoreImportPosition()
        case .above(let importId):
            return CoreImportPosition(above: importId)
        case .below(let importId):
            return CoreImportPosition(below: importId)
        case .at(let index):
            return CoreImportPosition(at: index)
        }
    }
}

// MARK: - CoreImportPosition conveniences

extension CoreImportPosition {
    convenience init(above: String? = nil, below: String? = nil, at: Int? = nil) {
        self.init(__above: above, below: below, at: at?.NSNumber)
    }

    /// Import should be positioned at a specified index in the imports stack
    var at: UInt32? { __at?.uint32Value }
}
