import Foundation

private enum StubAssocicatedKey {
    static var mockery: UInt8 = 0
}

protocol Stubbable: AnyObject {}

extension Stubbable {

    var mockery: Mockery<Self> {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }

        if let mockery = objc_getAssociatedObject(self, &StubAssocicatedKey.mockery) as? Mockery<Self> {
            return mockery
        }

        let newMockery = Mockery(host: self)
        objc_setAssociatedObject(self, &StubAssocicatedKey.mockery, newMockery, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return newMockery
    }
}

final class Mockery<Host: AnyObject> {

    unowned let host: Host
    private var stubs: [String: Any] = [:]

    init(host: Host) {
        self.host = host
    }

    func registerStub<T>(name: String, for _: (Host) -> T, stubbedValue: T) {
        if let existingStub = stubs[name] as? Stub<Host, T> {
            existingStub.returnValueQueue.append(stubbedValue)
            stubs[name] = existingStub
        } else {
            let newStub = Stub<Host, T>(defaultReturnValue: stubbedValue)
            newStub.returnValueQueue = [stubbedValue]
            stubs[name] = newStub
        }
    }

    func stub<T>(of _: (Host) -> T, name: String = #function) -> Stub<Host, T>? {
        stubs[name] as? Stub<Host, T>
    }
}
