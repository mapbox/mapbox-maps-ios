import XCTest
import Foundation

protocol Metric: XCTMetric {
    func commandWillStartExecuting(_ command: AsyncCommand, context: Context)
    func commandDidFinishExecuting(_ command: AsyncCommand, context: Context)
}

extension Metric {
    func commandWillStartExecuting(_ command: AsyncCommand, context: Context) { }
    func commandDidFinishExecuting(_ command: AsyncCommand, context: Context) { }
}

extension XCTCPUMetric: Metric { }
extension XCTMemoryMetric: Metric { }
extension XCTStorageMetric: Metric { }
extension XCTClockMetric: Metric { }
