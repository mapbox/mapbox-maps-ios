import Foundation

// swiftlint:disable force_cast
internal class WeakSet<T> {
    private let hashTable = NSHashTable<NSObject>.weakObjects()

    internal func add(_ object: T) {
        hashTable.add((object as! NSObject))
    }

    internal func remove(_ object: T) {
        hashTable.remove((object as! NSObject))
    }

    internal func removeAll() {
        hashTable.removeAllObjects()
    }

    internal var allObjects: [T] {
        hashTable.allObjects.map { $0 as! T }
    }
}
