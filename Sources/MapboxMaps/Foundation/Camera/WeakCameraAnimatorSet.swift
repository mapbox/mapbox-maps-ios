import Foundation

// swiftlint:disable force_cast
internal class WeakCameraAnimatorSet {
    private let hashTable = NSHashTable<NSObject>.weakObjects()

    internal func add(_ object: CameraAnimatorInterface) {
        hashTable.add((object as! NSObject))
    }

    internal func remove(_ object: CameraAnimatorInterface) {
        hashTable.remove((object as! NSObject))
    }

    internal func removeAll() {
        hashTable.removeAllObjects()
    }

    internal var allObjects: [CameraAnimatorInterface] {
        hashTable.allObjects.map { $0 as! CameraAnimatorInterface }
    }
}
