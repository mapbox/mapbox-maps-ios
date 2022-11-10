@propertyWrapper
final class Stubbed<T> {
    let getStub: Stub<Void, T>
    let setStub = Stub<T, Void>()

    var projectedValue: Stubbed<T> {
        return self
    }

    init(wrappedValue: T) {
        getStub = Stub(defaultReturnValue: wrappedValue)
    }

    var wrappedValue: T {
        get {
            getStub.call()
        }
        set {
            setStub.call(with: newValue)
            getStub.defaultReturnValue = newValue
        }
    }

    func reset() {
        getStub.reset()
        setStub.reset()
    }
}
