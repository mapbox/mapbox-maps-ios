import Foundation

protocol AsyncCommand {
    func execute() async throws
}
