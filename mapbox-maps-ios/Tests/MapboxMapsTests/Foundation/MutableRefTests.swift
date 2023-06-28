import XCTest

@_spi(Package) @testable import MapboxMaps

class MutableRefTests: XCTestCase {
    func testGetSet() {
        var value = "Hello, World!"
        var ref = MutableRef(
            get: { value },
            set: { value = $0 }
        )
        XCTAssertEqual(ref.wrappedValue, value)
        ref.wrappedValue = "Goodbye, World!"
        XCTAssertEqual(ref.wrappedValue, "Goodbye, World!")
        XCTAssertEqual(value, "Goodbye, World!")
    }

    func testPropertyWrapper() {
        @MutableRef var mutableRef = "Hello, World!"
        let ref = $mutableRef
        XCTAssertEqual(mutableRef, "Hello, World!")
        XCTAssertEqual(_mutableRef.wrappedValue, "Hello, World!")
        XCTAssertEqual(ref.value, "Hello, World!")

        mutableRef = "Goodbye, World!"
        XCTAssertEqual(mutableRef, "Goodbye, World!")
        XCTAssertEqual(_mutableRef.wrappedValue, "Goodbye, World!")
        XCTAssertEqual(ref.value, "Goodbye, World!")
    }
}
