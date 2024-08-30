import Foundation
import Dispatch

protocol MainQueueProtocol: DispatchQueueProtocol { }

final class MainQueueWrapper: MainQueueProtocol {
    func async(
        group: DispatchGroup?,
        qos: DispatchQoS,
        flags: DispatchWorkItemFlags,
        execute work: @Sendable @escaping @convention(block) () -> Void
    ) {
        DispatchQueue.main.async(group: group, qos: qos, flags: flags, execute: work)
    }

    func async(execute workItem: DispatchWorkItem) {
        DispatchQueue.main.async(execute: workItem)
    }
}
