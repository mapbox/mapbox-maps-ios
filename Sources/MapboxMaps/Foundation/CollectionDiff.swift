struct CollectionDiff<T, ID> {
    var remove = [ID]()
    var update = [T]()
    var add = [T]()

    var isEmpty: Bool { remove.isEmpty && update.isEmpty && add.isEmpty }
}

extension CollectionDiff: Equatable where T: Equatable, ID: Equatable {}

extension RandomAccessCollection {
    func diff<ID>(from old: Self, id keyPath: KeyPath<Element, ID>) -> CollectionDiff<Element, ID>
    where ID: Equatable, Element: Equatable {
        diff(from: old, id: { $0[keyPath: keyPath] })
    }
    /// Returns operations needed to perform in order to get `self` from `old` collection.
    /// Treats insertion in the middle as removing all the following elements and re-adding them.
    /// Updates element if its `id` and position are the same, but `old != new`.
    ///
    /// - Complexity: O(n + m), where *n* is length of `self` and *m* is length of `old`.
    func diff<ID>(from old: Self, id getId: (Element) -> ID) -> CollectionDiff<Element, ID>
    where ID: Equatable, Element: Equatable {
        var result = CollectionDiff<Element, ID>()

        var oldIt = old.startIndex
        var it = startIndex

        while oldIt != old.endIndex && it != endIndex {
            let element = self[it]
            let id = getId(element)

            let oldElement = old[oldIt]
            let oldId = getId(oldElement)

            if id == oldId {
                // The elements are the same, update them if changed.
                if oldElement != element {
                    result.update.append(element)
                }
                formIndex(&it, offsetBy: 1)
                old.formIndex(&oldIt, offsetBy: 1)

                continue
            }

            result.remove.append(oldId)
            old.formIndex(&oldIt, offsetBy: 1)
        }

        result.add.append(contentsOf: self[it...])
        result.remove.append(contentsOf: old[oldIt...].lazy.map(getId))
        return result
    }
}
