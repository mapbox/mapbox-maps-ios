import Dispatch

// depending on this protocol instead of on DispatchQueue directly
// allow mocking the main queue in tests which avoids the need for waits
internal protocol DispatchQueueProtocol: AnyObject {
    func async(
        group: DispatchGroup?,
        qos: DispatchQoS,
        flags: DispatchWorkItemFlags,
        execute work: @escaping @convention(block) () -> Void
    )
    func async(execute workItem: DispatchWorkItem)
}

extension DispatchQueueProtocol {
    func async(execute work: @escaping @convention(block) () -> Void) {
        async(group: nil, qos: .unspecified, flags: [], execute: work)
    }

    func async(
        qos: DispatchQoS,
        execute work: @escaping @convention(block) () -> Void
    ) {
        async(group: nil, qos: qos, flags: [], execute: work)
    }
}

extension DispatchQueue: DispatchQueueProtocol { }
extension DispatchWorkItem: Cancelable { }
