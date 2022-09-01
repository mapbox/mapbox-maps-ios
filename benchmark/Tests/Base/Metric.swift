import XCTest
import Foundation

protocol Metric: XCTMetric {
    func commandWillStartExecuting(_ command: AsyncCommand)
    func commandDidFinishExecuting(_ command: AsyncCommand)
}

extension Metric {
    func commandWillStartExecuting(_ command: AsyncCommand) { }
    func commandDidFinishExecuting(_ command: AsyncCommand) { }
}

extension XCTCPUMetric: Metric { }
extension XCTMemoryMetric: Metric { }
extension XCTStorageMetric: Metric { }
extension XCTClockMetric: Metric { }
