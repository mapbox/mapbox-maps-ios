@testable import MapboxMaps

final class MockMainQueue: MainQueueProtocol {
    struct AsyncParams {
        let group: DispatchGroup?
        let qos: DispatchQoS
        let flags: DispatchWorkItemFlags
        let work: () -> Void
    }
    let asyncClosureStub = Stub<AsyncParams, Void>()
    func async(
        group: DispatchGroup?,
        qos: DispatchQoS,
        flags: DispatchWorkItemFlags,
        execute work: @escaping @convention(block) () -> Void
    ) {
        asyncClosureStub.call(with: AsyncParams(group: group, qos: qos, flags: flags, work: work))
    }

    let asyncWorkItemStub = Stub<DispatchWorkItem, Void>()
    func async(execute workItem: DispatchWorkItem) {
        asyncWorkItemStub.call(with: workItem)
    }
}

final class MockDispatchQueue: DispatchQueueProtocol {
    struct AsyncParams {
        let group: DispatchGroup?
        let qos: DispatchQoS
        let flags: DispatchWorkItemFlags
        let work: () -> Void
    }
    let asyncClosureStub = Stub<AsyncParams, Void>()
    func async(
        group: DispatchGroup?,
        qos: DispatchQoS,
        flags: DispatchWorkItemFlags,
        execute work: @escaping @convention(block) () -> Void
    ) {
        asyncClosureStub.call(with: AsyncParams(group: group, qos: qos, flags: flags, work: work))
    }

    let asyncWorkItemStub = Stub<DispatchWorkItem, Void>()
    func async(execute workItem: DispatchWorkItem) {
        asyncWorkItemStub.call(with: workItem)
    }
}
