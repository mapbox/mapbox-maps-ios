import Combine

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension AnyCancelable {
    /// Stores cancellable object in set of `Combine.AnyCancellable`.
    public func store(in set: inout Set<Combine.AnyCancellable>) {
        Combine.AnyCancellable(self.cancel).store(in: &set)
    }

    /// Stores cancellable object in collection of `Combine.AnyCancellable`.
    public func store<C: RangeReplaceableCollection>(in collection: inout C) where C.Element == Combine.AnyCancellable {
        Combine.AnyCancellable(self.cancel).store(in: &collection)
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension AnyCancellable {
    /// Stores this type-erasing cancellable instance in the specified set.
    ///
    /// - Parameter set: The set in which to store this ``AnyCancellable``.
    public func store(in set: inout Set<AnyCancelable>) {
        set.insert(AnyCancelable(cancel))
    }

    /// Stores this type-erasing cancellable instance in the specified collection.
    ///
    /// - Parameter collection: The collection in which to store this ``AnyCancellable``.
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    final public func store<C>(in collection: inout C) where C: RangeReplaceableCollection, C.Element == AnyCancelable {
        collection.append(AnyCancelable(cancel))
    }
}
