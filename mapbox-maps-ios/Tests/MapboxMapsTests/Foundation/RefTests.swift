@testable import MapboxMaps
import XCTest

final class RefTests: XCTestCase {
    func testRef() {
        var value = 0
        let ref = Ref {
            return value
        }

        XCTAssertEqual(ref.value, 0)

        value = 42
        XCTAssertEqual(ref.value, 42)
    }

    func testWeakCacheObjects() {
        var value = 5
        let ref = Ref {
            Object(value: value)
        }.weaklyCached()

        var obj1: Object? = ref.value
        var obj2: Object? = ref.value

        XCTAssertIdentical(obj1, obj2) // cached value is returned
        XCTAssertEqual(obj1?.value, 5)

        value = 42
        var obj3: Object? = ref.value
        XCTAssertIdentical(obj2, obj3) // cached value is returned

        obj1 = nil
        obj2 = nil
        obj3 = nil

        let obj4 = ref.value
        let obj5 = ref.value
        XCTAssertIdentical(obj4, obj5)
        XCTAssertEqual(obj4.value, 42)
    }

    func testMap() {
        var value = 0
        let strRef = Ref { value }.map { "value: \($0)" }
        let positiveRef = Ref { value }.map { $0 > 0 }

        XCTAssertEqual(strRef.value, "value: 0")
        XCTAssertEqual(positiveRef.value, false)

        value = 5
        XCTAssertEqual(strRef.value, "value: 5")
        XCTAssertEqual(positiveRef.value, true)

        value = -1
        XCTAssertEqual(strRef.value, "value: -1")
        XCTAssertEqual(positiveRef.value, false)

    }

    func testWeakCacheWithAutoreleasepool() {
        let provider = Ref {
            UIImage.generateSquare(color: .random())
        }.weaklyCached()

        var pngData: Data?

        autoreleasepool {
            var obj1: UIImage? = provider.value
            var obj2: UIImage? = provider.value
            XCTAssertIdentical(obj1, obj2) // cached value is returned

            var obj3: UIImage? = provider.value
            XCTAssertIdentical(obj2, obj3) // cached value is returned

            pngData = obj1?.pngData()
            obj1 = nil
            obj2 = nil
            obj3 = nil
        }

        let obj4: UIImage? = provider.value
        let obj5: UIImage? = provider.value
        XCTAssertIdentical(obj4, obj5)
        XCTAssertNotEqual(pngData, obj4?.pngData()) // new cached image is created
    }
}

private final class Object {
    var value: Int

    init(value: Int) {
        self.value = value
    }
}
