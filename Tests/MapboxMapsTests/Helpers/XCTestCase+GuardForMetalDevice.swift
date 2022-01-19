import XCTest

extension XCTestCase {
    func guardForMetalDevice() throws {
        guard MTLCreateSystemDefaultDevice() != nil else {
            throw XCTSkip("No valid Metal device (OS version or VM?)")
        }
    }
}
