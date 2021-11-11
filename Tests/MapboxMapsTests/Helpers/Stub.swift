import Foundation

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

    var returnedValues: [ReturnType] {
        invocations.map(\.returnValue)
    }

    var parameters: [ParametersType] {
        invocations.map(\.parameters)
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
