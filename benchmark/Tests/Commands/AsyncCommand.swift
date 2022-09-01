import Foundation

protocol AsyncCommand {
    func execute() async throws
    func cleanup()
}

extension AsyncCommand {
    func cleanup() { }
}
