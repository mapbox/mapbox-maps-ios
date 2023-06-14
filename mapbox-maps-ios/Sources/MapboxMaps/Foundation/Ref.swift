import Foundation

/// `Ref` is read-only reference to arbitrary value captured by closure.
/// It is used to pass the value, that might be changed over time.
internal struct Ref<Value> {
    private let get: () -> Value

    internal var value: Value { `get`() }

    internal init(_ get: @escaping () -> Value) {
        self.get = get
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
        Ref<U> { [get] in
            transform(get())
        }
    }
}

extension Ref where Value: AnyObject {
    /// Creates a reference that weakly caches the value returned from the original Provider.
    internal func weaklyCached() -> Ref<Value> {
        weak var cache: Value?
        return Ref { [get] in
            let value = cache ?? get()
            cache = value
            return value
        }
    }
}

extension Ref where Value == UIApplication.State {
    @available(iOSApplicationExtension, unavailable)
    static let global = Ref { UIApplication.shared.applicationState }
}
