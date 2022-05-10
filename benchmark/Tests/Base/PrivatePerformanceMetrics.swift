import XCTest

public extension XCTPerformanceMetric {
    static let userTime = XCTPerformanceMetric(rawValue: "com.apple.XCTPerformanceMetric_UserTime")
    static let runTime = XCTPerformanceMetric(rawValue: "com.apple.XCTPerformanceMetric_RunTime")
    static let systemTime = XCTPerformanceMetric(rawValue: "com.apple.XCTPerformanceMetric_SystemTime")
    static let transientVMKB = XCTPerformanceMetric(rawValue: "com.apple.XCTPerformanceMetric_TransientVMAllocationsKilobytes")
    static let temporaryHeapKB = XCTPerformanceMetric(rawValue: "com.apple.XCTPerformanceMetric_TemporaryHeapAllocationsKilobytes")
    static let highWatermarkVM = XCTPerformanceMetric(rawValue: "com.apple.XCTPerformanceMetric_HighWaterMarkForVMAllocations")
    static let totalHeapKB = XCTPerformanceMetric(rawValue: "com.apple.XCTPerformanceMetric_TotalHeapAllocationsKilobytes")
    static let persistentVM = XCTPerformanceMetric(rawValue: "com.apple.XCTPerformanceMetric_PersistentVMAllocations")
    static let persistentHeap = XCTPerformanceMetric(rawValue: "com.apple.XCTPerformanceMetric_PersistentHeapAllocations")
    static let transientHeapKB = XCTPerformanceMetric(rawValue: "com.apple.XCTPerformanceMetric_TransientHeapAllocationsKilobytes")
    static let persistentHeapNodes = XCTPerformanceMetric(rawValue: "com.apple.XCTPerformanceMetric_PersistentHeapAllocationsNodes")
    static let highWatermarkHeap = XCTPerformanceMetric(rawValue: "com.apple.XCTPerformanceMetric_HighWaterMarkForHeapAllocations")
    static let transientHeapNodes = XCTPerformanceMetric(rawValue: "com.apple.XCTPerformanceMetric_TransientHeapAllocationsNodes")

    static let all: [XCTPerformanceMetric] = [.wallClockTime,
                                                     .userTime,
                                                     .runTime,
                                                     .systemTime,
                                                     .transientVMKB,
                                                     .temporaryHeapKB,
                                                     .highWatermarkVM,
                                                     .totalHeapKB,
                                                     .persistentVM,
                                                     .persistentHeap,
                                                     .transientHeapKB,
                                                     .persistentHeapNodes,
                                                     .highWatermarkHeap,
                                                     .transientHeapNodes]
}
