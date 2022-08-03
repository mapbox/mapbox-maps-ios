import Foundation

internal extension Array where Element == CodingKey {

    func appending(key codingKey: CodingKey) -> [CodingKey] {
        self + [codingKey]
    }

    func appending(index: Int) -> [CodingKey] {
        self + [IndexedKey(intValue: index)]
    }

    private struct IndexedKey: CodingKey {
        var intValue: Int? { index }
        var stringValue: String { "Index \(index)" }

        private let index: Int

        init(intValue index: Int) {
            self.index = index
        }

        init?(stringValue: String) {
            return nil
        }
    }
}
