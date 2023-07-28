import Combine

@available(iOS 13, *)
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
