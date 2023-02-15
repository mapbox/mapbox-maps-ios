import Foundation
import Dispatch

@_spi(Package)
public protocol MainQueueProtocol: DispatchQueueProtocol { }

@_spi(Package)
public final class MainQueueWrapper: MainQueueProtocol {
    public init() {}
    public func async(
        group: DispatchGroup?,
        qos: DispatchQoS,
        flags: DispatchWorkItemFlags,
        execute work: @escaping @convention(block) () -> Void
    ) {
        DispatchQueue.main.async(group: group, qos: qos, flags: flags, execute: work)
    }

    public func async(execute workItem: DispatchWorkItem) {
        DispatchQueue.main.async(execute: workItem)
    }
}
