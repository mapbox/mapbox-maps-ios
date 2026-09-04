/// Identifies the UI framework used to create a map instance.
@_spi(Restricted)
public struct UIFramework: Sendable, Equatable {
    let rawValue: String

    private init(rawValue: String) {
        self.rawValue = rawValue
    }

    public static let uiKit = UIFramework(rawValue: "uikit")
    public static let swiftUI = UIFramework(rawValue: "swiftui")
    public static let flutter = UIFramework(rawValue: "flutter")
}
