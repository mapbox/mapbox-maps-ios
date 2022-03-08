import MapboxMaps

extension StyleColor {
    static func random() -> Self {
        return StyleColor(
            red: .random(in: 0...255),
            green: .random(in: 0...255),
            blue: .random(in: 0...255),
            alpha: .random(in: 0...1))!
    }
}
