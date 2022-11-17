@testable import MapboxMaps

final class MockMainQueue: MainQueueProtocol {
    struct AsyncAfterItemParams {
        let deadline: DispatchTime
        let item: DispatchWorkItem
    }
    let asyncAfterItemStub = Stub<AsyncAfterItemParams, Void>()
    func asyncAfter(deadline: DispatchTime, execute: DispatchWorkItem) {
        asyncAfterItemStub.call(with: .init(deadline: deadline, item: execute))
    }

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
    struct AsyncAfterItemParams {
        let deadline: DispatchTime
        let item: DispatchWorkItem
    }
    let asyncAfterItemStub = Stub<AsyncAfterItemParams, Void>()
    func asyncAfter(deadline: DispatchTime, execute: DispatchWorkItem) {
        asyncAfterItemStub.call(with: .init(deadline: deadline, item: execute))
    }

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
