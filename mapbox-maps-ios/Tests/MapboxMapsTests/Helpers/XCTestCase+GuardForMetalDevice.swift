import XCTest

extension XCTestCase {
    func guardForMetalDevice() throws {
        guard MTLCreateSystemDefaultDevice() != nil else {
            XCTFail("No valid Metal device (OS version or VM?)")
            return
        }
    }
}
