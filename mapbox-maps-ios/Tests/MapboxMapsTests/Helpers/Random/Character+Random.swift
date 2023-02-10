extension Character {
    static func randomASCII() -> Self {
        return Character(UnicodeScalar(.random(in: 0x20...0x7E))!)
    }
}
