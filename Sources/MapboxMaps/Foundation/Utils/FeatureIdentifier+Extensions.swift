extension FeatureIdentifier {
    var string: String? {
        switch self {
        case .string(let s):
            return s
        default:
            return nil
        }
    }
}
