extension Array {
    /// Removes elements from `self` whose `key` is duplicated with other elements.
    ///
    /// - Returns: A list of duplicated keys.
    mutating func removeDuplicates<Key: Hashable>(by key: (Element) -> Key) -> [Element] {
        var keys = Set<Key>()
        var duplicates = [Element]()
        self.removeAll { el in
            let k = key(el)
            let isUnique = keys.insert(k).inserted
            if !isUnique {
                duplicates.append(el)
            }
            return !isUnique
        }
        return duplicates
    }
}
