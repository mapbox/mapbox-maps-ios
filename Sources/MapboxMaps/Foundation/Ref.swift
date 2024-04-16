import UIKit

/// `Ref` is a read-only reference to an arbitrary value captured by closure.
/// It is used to pass the value, that might be changed over time.
struct Ref<Value> {
    let getter: () -> Value

    /// The referenced value.
    var value: Value { getter() }

    /// Creates a reference from the given closure.
    init(_ getter: @escaping () -> Value) {
        self.getter = getter
    }
}

/// `MutableRef` is read/write-reference to some external value.
///
///  It might be initialized either with get/set closures or initial value as Property Wrapper.
///  In latter case `MutableRef` acts as mutable source of truth and factory for read-only Refs.
///  Example:
///
///        class Person {
///          @MutableRef private(set) var age = 0
///          func birthday() { age += 1 }
///        }
///
///        let person = Person()
///        let age = person.$age // create read-only Ref
///        assert(age.value == 0)
///        person.birthday()
///        assert(age.value == 1)
@propertyWrapper
internal struct MutableRef<Value> {
    private let get: () -> Value
    private let set: (Value) -> Void

    var wrappedValue: Value {
        get { get() }
        set { set(newValue) }
    }

    /// Creates the read-only reference.
    var projectedValue: Ref<Value> { Ref(get) }

    /// Creates the mutable reference with referencing closures.
    init(get: @escaping () -> Value, set: @escaping (Value) -> Void) {
        self.get = get
        self.set = set
    }

    /// Creates the mutable reference with some initial value which can be modified later.
    init(wrappedValue: Value) {
        var value = wrappedValue
        self.init(
            get: { value },
            set: { value = $0 }
        )
    }
}

extension Ref {
    func map<U>(_ transform: @escaping (Value) -> U) -> Ref<U> {
        Ref<U> { [getter] in
            transform(getter())
        }
    }
}

extension Ref where Value: AnyObject {
    /// Creates a reference that weakly caches the value returned from the original Provider.
    internal func weaklyCached() -> Ref<Value> {
        weak var cache: Value?
        return Ref { [getter] in
            let value = cache ?? getter()
            cache = value
            return value
        }
    }
}

extension Ref where Value == Date {
    static let now = Ref { Date() }
}

extension Ref where Value == UIApplication.State {
    @available(iOSApplicationExtension, unavailable)
    static let global = Ref { UIApplication.shared.applicationState }
}

extension Ref {
    static func weakRef<O: AnyObject>(_ object: O) -> Ref where Value == O? {
        Ref { [weak object] in object }
    }

    static func weakRef<T, O: AnyObject>(_ object: O, property: KeyPath<O, T>) -> Ref where Value == T? {
        Ref { [weak object] in object?[keyPath: property] }
    }
}

extension MutableRef {
    /// Creates a mutable reference to a property in the `root` object accessed by the `keyPath`.
    init<Root: AnyObject>(root: Root, keyPath: ReferenceWritableKeyPath<Root, Value>) {
        self.init {
            root[keyPath: keyPath]
        } set: {
            root[keyPath: keyPath] = $0
        }
    }
}
