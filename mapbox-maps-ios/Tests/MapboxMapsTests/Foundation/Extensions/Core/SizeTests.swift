import XCTest
@testable import MapboxMaps

final class SizeTests: XCTestCase {

    func testInitSizeWithCGSize() {
        let cgSize = CGSize(
            width: .random(in: 0...1000),
            height: .random(in: 0...1000))

        let size = Size(cgSize)

        XCTAssertEqual(size.width, Float(cgSize.width))
        XCTAssertEqual(size.height, Float(cgSize.height))
    }

    func testInitCGSizeWithSize() {
        let size = Size(
            width: .random(in: 0...1000),
            height: .random(in: 0...1000))

        let cgSize = CGSize(size)

        XCTAssertEqual(cgSize.width, CGFloat(size.width))
        XCTAssertEqual(cgSize.height, CGFloat(size.height))
    }
}
