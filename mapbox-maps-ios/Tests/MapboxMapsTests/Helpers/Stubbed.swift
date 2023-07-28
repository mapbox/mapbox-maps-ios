@testable import MapboxMaps

@propertyWrapper
final class Stubbed<T>: StubProtocol {
    let getStub: Stub<Void, T>
    let setStub = Stub<T, Void>()

    var projectedValue: Stubbed<T> {
        return self
    }

    let file: String
    let line: Int

    init(file: String = #file, line: Int = #line, wrappedValue: T) {
        self.file = file
        self.line = line
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
