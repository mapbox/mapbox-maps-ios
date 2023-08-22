struct CollectionDiff<T> {
    var remove = [T]()
    var update = [T]()
    var add = [T]()

    var isEmpty: Bool { remove.isEmpty && update.isEmpty && add.isEmpty }
}

extension CollectionDiff: Equatable where T: Equatable {}

extension RandomAccessCollection {
    /// Returns operations needed to perform in order to get `self` from `old` collection.
    /// Treats insertion in the middle as removing all the following elements and re-adding them.
    /// Updates element if its `id` and position are the same, but `old != new`.
    ///
    /// - Complexity: O(n + m), where *n* is length of `self` and *m* is length of `old`.
    func diff<ID>(from old: Self, id: (Element) -> ID) -> CollectionDiff<Element>
    where ID: Hashable, Element: Equatable {
        var result = CollectionDiff<Element>()

        let oldIdsMap = Dictionary(uniqueKeysWithValues: zip(old, old.indices).map { (id($0), $1) })

        var oldIt = old.startIndex
        var it = startIndex

        while oldIt != old.endIndex && it != self.endIndex {
            let element = self[it]
            let oldElement: Element = old[oldIt]
            let newId = id(element)
            let oldId = id(oldElement)

            if newId == oldId {
                if oldElement != element {
                    result.update.append(element)
                }
                self.formIndex(&it, offsetBy: 1)
                old.formIndex(&oldIt, offsetBy: 1)
                continue
            }

            if let foundOldIt = oldIdsMap[newId], foundOldIt > oldIt {
                while oldIt != foundOldIt {
                    result.remove.append(old[oldIt])
                    old.formIndex(&oldIt, offsetBy: 1)
                }
                oldIt = foundOldIt
                continue
            }

            break
        }

        while it != self.endIndex {
            result.add.append(self[it])
            self.formIndex(&it, offsetBy: 1)
        }

        while oldIt != old.endIndex {
            result.remove.append(old[oldIt])
            old.formIndex(&oldIt, offsetBy: 1)
        }

        return result
    }
}
