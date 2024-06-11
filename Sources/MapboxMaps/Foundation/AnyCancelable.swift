/// A Cancellable object that automatically cancels on deinit.
///
/// Any resources referred by `AnyCancelable` will be released after cancellation.
///
/// This class has similar behavior to `Combine.AnyCancellable`, but doesn't require iOS 13.
public class AnyCancelable: Cancelable {
    private var closure: (() -> Void)?

    /// Creates AnyCancelable with the cancelling closure.
    ///
    ///  - Parameters:
    ///     - closure: A closure that will be called when AnyCancellable is cancelled.
    public init(_ closure: @escaping () -> Void) {
        self.closure = closure
    }

    /// Creates AnyCancelable with the canceler object.
    ///
    ///  - Parameters:
    ///     - canceler: The `Cancelable` token to be cancelled.
    public convenience init<C: Cancelable>(_ canceler: C) {
        self.init(canceler.cancel)
    }

    /// Creates AnyCancelable with the sequence of cancellables which will be canelled when AnyCancelable is cancelled.
    ///
    ///  - Parameters:
    ///     - sequence: Sequence of cancellables.
    public convenience init<S: Sequence>(_ sequence: S) where S.Element: Cancelable {
        self.init {
            for el in sequence {
                el.cancel()
            }
        }
    }

    /// Cancels the activity.
    public func cancel() {
        closure?()
        closure = nil // Relinquish resources captured by closure
    }

    deinit {
        cancel()
    }
}

extension AnyCancelable: Hashable {
    /// Hashes the essential components of this value by feeding them into the given hasher.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }

    /// Returns a Boolean value that indicates whether two instances are equal, as determined by comparing
    /// whether their references point to the same instance.
    public static func == (lhs: AnyCancelable, rhs: AnyCancelable) -> Bool {
        return lhs === rhs
    }
}

extension AnyCancelable {
    /// Stores cancellable object in a set.
    public func store(in set: inout Set<AnyCancelable>) {
        set.insert(self)
    }

    /// Stores cancellable object in a collection.
    public func store<C: RangeReplaceableCollection>(in collection: inout C) where C.Element == AnyCancelable {
        collection.append(self)
    }
}

extension AnyCancelable {
    static var empty: AnyCancelable { AnyCancelable {} }
}
