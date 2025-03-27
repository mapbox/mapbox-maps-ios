extension Character {
    static func testConstantASCII(index: Int) -> Self {
        let characters = Array(" !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~")
        return characters[index % characters.count]
    }
}
