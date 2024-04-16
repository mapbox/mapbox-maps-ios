struct CollectionDiff<C: Collection>: Equatable where C.Element: Equatable {
    struct Move: Equatable {
        let value: C.Element
        let from: C.Index
        let to: C.Index
    }

    var remove = [C.Element]()
    var add = [C.Element]()
    var update = [C.Element]()
    var move = [Move]()
}

extension CollectionDiff {
    var isEmpty: Bool { remove.isEmpty && update.isEmpty && add.isEmpty && move.isEmpty }
}

// swiftlint:disable cyclomatic_complexity function_body_length
extension RandomAccessCollection where Element: Equatable, Index == Int {
    func diff<ID: Hashable>(from old: Self, id keyPath: KeyPath<Element, ID>, trackMoves: Bool = false) -> CollectionDiff<Self> {
            diff(from: old, id: { $0[keyPath: keyPath] }, trackMoves: trackMoves)
        }

    /// Returns operations needed to perform in order to get `self` from `old` collection.
    /// Treats insertion in the middle as removing all the following elements and re-adding them if `trackMoves == false`.
    /// Updates element if its `id` and position are the same, but `old != new`.
    /// Moves element if its `id` are equal and new position can't  be retrieved by adding/removing previous elements.
    ///
    /// - Complexity: O(n + m), where *n* is length of `self` and *m* is length of `old`.
    func diff<ID: Hashable>(from source: Self, id: (Element) -> ID, trackMoves: Bool = false) -> CollectionDiff<Self> {
        var remove = [Element]()
        var add = [Element]()
        var update = [Element]()
        var move = [CollectionDiff<Self>.Move]()

        var sourceDescriptors = ContiguousArray<SourceElementDescriptor<ID>>()
        sourceDescriptors.reserveCapacity(source.count)

        var targetIndexToSourceIndexMap = ContiguousArray<Index?>(repeating: nil, count: count)
        var sourceElementIdToIndexMap = [ID: Index](minimumCapacity: source.count)

        for (index, element) in source.enumerated() {
            let id = id(element)
            sourceDescriptors.append(SourceElementDescriptor(id: id))
            sourceElementIdToIndexMap[id] = index
        }

        /// Map new index of element to it's old index, if element with the same id still exist in new collection.
        for targetIndex in indices {
            if let sourceIndex = sourceElementIdToIndexMap[id(self[targetIndex])] {
                targetIndexToSourceIndexMap[targetIndex] = sourceIndex
                sourceDescriptors[sourceIndex].indexInTarget = targetIndex
            }
        }

        var offsetAfterDelete = 0

        /// Identify removed elements.
        for sourceIndex in source.indices {
            sourceDescriptors[sourceIndex].deleteOffset = offsetAfterDelete

            if sourceDescriptors[sourceIndex].indexInTarget == nil {
                remove.append(source[sourceIndex])
                sourceDescriptors[sourceIndex].isTracked = true
                offsetAfterDelete += 1
            }
        }

        var untrackedSourceIndex: Index? = startIndex

        /// Identify updated, moved and added elements.
        for targetIndex in indices {
            if trackMoves {
                untrackedSourceIndex = untrackedSourceIndex.flatMap { index in
                    sourceDescriptors.suffix(from: index).firstIndex { !$0.isTracked }
                }
            }

            if let sourceIndex = targetIndexToSourceIndexMap[targetIndex] {
                sourceDescriptors[sourceIndex].isTracked = true
                let deleteOffset = sourceDescriptors[sourceIndex].deleteOffset

                if !trackMoves, (sourceIndex - deleteOffset) != targetIndex {
                    remove.append(source[sourceIndex])
                    add.append(self[targetIndex])
                    continue
                }

                if self[targetIndex] != source[sourceIndex] {
                    update.append(self[targetIndex])
                }

                if trackMoves, sourceIndex != untrackedSourceIndex {
                    move.append(CollectionDiff<Self>.Move(value: self[targetIndex], from: sourceIndex - deleteOffset, to: targetIndex))
                }

            } else {
                add.append(self[targetIndex])
            }
        }

        return CollectionDiff(remove: remove, add: add, update: update, move: move)
    }
}
// swiftlint:enable cyclomatic_complexity function_body_length

/// Information needed to properly identify element position in new collection.
private struct SourceElementDescriptor<ID: Hashable> {
    var id: ID
    var indexInTarget: Int?
    var deleteOffset = 0
    var isTracked = false
}
