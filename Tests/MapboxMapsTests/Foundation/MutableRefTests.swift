import XCTest

@testable import MapboxMaps

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

    func testKeyPathInitialization() {
        class Foo {
            var count: Int = 0
            init(count: Int) {
                self.count = count
            }
        }
        let instance = Foo(count: 0)
        var ref = MutableRef(root: instance, keyPath: \.count)

        XCTAssertEqual(ref.wrappedValue, 0)
        instance.count += 1
        XCTAssertEqual(ref.wrappedValue, 1)
        ref.wrappedValue *= 10
        XCTAssertEqual(instance.count, 10)
    }
}
