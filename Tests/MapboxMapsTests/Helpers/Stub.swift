final class Stub<ParametersType, ReturnType> {

    struct Invocation {
        var parameters: ParametersType
        var returnValue: ReturnType
    }

    typealias SideEffect = (Invocation) -> Void

    private(set) var invocations = [Invocation]()

    var defaultReturnValue: ReturnType

    var returnValueQueue = [ReturnType]()

    var defaultSideEffect: SideEffect?

    var sideEffectQueue = [SideEffect]()

    init(defaultReturnValue: ReturnType) {
        self.defaultReturnValue = defaultReturnValue
    }

    func call(with parameters: ParametersType) -> ReturnType {
        let invocation = Invocation(parameters: parameters,
                                    returnValue: returnValueQueue.isEmpty ? defaultReturnValue : returnValueQueue.removeFirst())
        invocations.append(invocation)
        if let sideEffect = sideEffectQueue.isEmpty ? defaultSideEffect : sideEffectQueue.removeFirst() {
            sideEffect(invocation)
        }
        return invocation.returnValue
    }

    func reset() {
        invocations.removeAll()
    }
}

extension Stub where ReturnType == Void {
    convenience init() {
        self.init(defaultReturnValue: ())
    }
}

extension Stub where ParametersType == Void {
    func call() -> ReturnType {
        call(with: ())
    }
}

extension Stub.Invocation: Equatable where ParametersType: Equatable, ReturnType: Equatable {
    static func == (lhs: Stub.Invocation, rhs: Stub.Invocation) -> Bool {
        return (lhs.parameters == rhs.parameters &&
                lhs.returnValue == rhs.returnValue)
    }
}

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
}
