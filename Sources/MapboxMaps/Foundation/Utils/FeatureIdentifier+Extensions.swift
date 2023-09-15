extension FeatureIdentifier {
    var string: String? {
        switch self {
        case .string(let s):
            return s
        case .number(let _):
            return nil
        }
    }
}
