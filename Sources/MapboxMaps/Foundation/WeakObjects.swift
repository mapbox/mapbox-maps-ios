internal struct WeakObjects<T: AnyObject> {
    struct Weak {
        weak var value: T?
    }

    private var objects = [Weak]()

    var isEmpty: Bool {
        mutating get {
            clean()
            return objects.isEmpty
        }
    }

    mutating func add(_ object: T) {
        let added = objects.contains { $0.value === object }
        if !added {
            objects.append(Weak(value: object))
        }
        clean()
    }

    mutating func remove(_ object: T) {
        objects.removeAll { $0.value === object }
        clean()
    }

    private mutating func clean() {
        objects.removeAll { $0.value == nil }
    }

    func forEach(callback: (T) -> Void) {
        let objectsCopy = objects
        for weak in objectsCopy {
            if let object = weak.value {
                callback(object)
            }
        }
    }

    var asHashTable: NSHashTable<T> {
        let result = NSHashTable<T>.weakObjects()
        forEach { object in
            result.add(object)
        }
        return result
    }
}
