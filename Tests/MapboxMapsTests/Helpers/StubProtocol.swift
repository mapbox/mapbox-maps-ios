/// Simple Stub description to enable non-generic casting
/// Can be useful for debugging purposes in conjunction with `Mirror`
protocol StubProtocol {
    func reset()

    var file: String { get }
    var line: Int { get }
}

extension Stub: StubProtocol { }
