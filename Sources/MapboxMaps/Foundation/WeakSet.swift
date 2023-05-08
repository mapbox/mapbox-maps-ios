import Foundation

internal class WeakSet<T> {
    private let hashTable = NSHashTable<AnyObject>.weakObjects()

    internal func add(_ object: T) {
        hashTable.add((object as AnyObject))
    }

    internal func remove(_ object: T) {
        hashTable.remove((object as AnyObject))
    }

    internal func removeAll() {
        hashTable.removeAllObjects()
    }

    internal var allObjects: [T] {
        // swiftlint:disable:next force_cast
        hashTable.allObjects.map { $0 as! T }
    }
}
