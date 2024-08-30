import Dispatch

// depending on this protocol instead of on DispatchQueue directly
// allow mocking the main queue in tests which avoids the need for waits
protocol DispatchQueueProtocol: AnyObject {
    @preconcurrency func async(
        group: DispatchGroup?,
        qos: DispatchQoS,
        flags: DispatchWorkItemFlags,
        execute work: @Sendable @escaping @convention(block) () -> Void
    )
    func async(execute workItem: DispatchWorkItem)
}

extension DispatchQueueProtocol {
    @preconcurrency func async(execute work: @Sendable @escaping @convention(block) () -> Void) {
        async(group: nil, qos: .unspecified, flags: [], execute: work)
    }

    @preconcurrency func async(
        qos: DispatchQoS,
        execute work: @Sendable @escaping @convention(block) () -> Void
    ) {
        async(group: nil, qos: qos, flags: [], execute: work)
    }
}

extension DispatchQueue: DispatchQueueProtocol {}
