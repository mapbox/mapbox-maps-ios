import Foundation

final class Stub<ParametersType, ReturnType> {

    class Invocation: CustomStringConvertible {
        var parameters: ParametersType
        var returnValue: ReturnType
        init(parameters: ParametersType, returnValue: ReturnType) {
            self.parameters = parameters
            self.returnValue = returnValue
        }

        var description: String {
            "Invocation<\(ParametersType.self), \(ReturnType.self)>"
        }
    }

    typealias SideEffect = (Invocation) -> Void

    private(set) var invocations = [Invocation]()

    var defaultReturnValue: ReturnType

    var returnValueQueue = [ReturnType]()

    var defaultSideEffect: SideEffect?

    var sideEffectQueue = [SideEffect]()

    let file: String
    let line: Int

    init(file: String = #file, line: Int = #line, defaultReturnValue: ReturnType) {
        self.file = file
        self.line = line
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
    convenience init(file: String = #file, line: Int = #line) {
        self.init(file: file, line: line, defaultReturnValue: ())
    }
}

extension Stub where ParametersType == Void {
    func call() -> ReturnType {
        call(with: ())
    }

    func callAsFunction() -> ReturnType {
        call()
    }
}

extension Stub {
    func callAsFunction(with parameters: ParametersType) -> ReturnType {
        call(with: parameters)
    }
}

extension Stub where ParametersType == Void, ReturnType == Void {
    convenience init(file: String = #file, line: Int = #line) {
        self.init(file: file, line: line, defaultReturnValue: ())
    }
}

extension Stub.Invocation: Equatable where ParametersType: Equatable, ReturnType: Equatable {
    static func == (lhs: Stub.Invocation, rhs: Stub.Invocation) -> Bool {
        return (lhs.parameters == rhs.parameters &&
                lhs.returnValue == rhs.returnValue)
    }
}

extension Stub: CustomStringConvertible {
    var description: String {
        let filePath = NSURL(fileURLWithPath: file).lastPathComponent ?? file

        var result = "Stub<\(ParametersType.self), \(ReturnType.self)> created at \(filePath):\(line)"
        result += "\n  Default return value is \(defaultReturnValue)"

        if let defaultSideEffect = defaultSideEffect {
            result += "\n  Has a default side-effect \(String(describing: defaultSideEffect))"
        } else {
            result += "\n  Has no default side-effect"
        }

        if invocations.isEmpty {
            result += "\n  Has no stored invocations"
        } else {
            result += "\n  Has \(invocations.count) stored invocations"
            for invocation in invocations {
                result += "\n    \(invocation)"
            }
        }

        return result
    }
}
