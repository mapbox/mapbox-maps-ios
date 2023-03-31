@testable import MapboxMaps
import XCTest

class ProviderTests: XCTestCase {
    func testProvider() {
        var value = 0
        let provider = Provider {
            return value
        }

        XCTAssertEqual(provider.value, 0)

        value = 42
        XCTAssertEqual(provider.value, 42)
    }

    func testWeakCacheObjects() {
        var value = 5
        let provider = Provider {
            Object(value: value)
        }.weaklyCached()

        var obj1: Object? = provider.value
        var obj2: Object? = provider.value

        XCTAssertIdentical(obj1, obj2) // cached value is returned
        XCTAssertEqual(obj1?.value, 5)

        value = 42
        var obj3: Object? = provider.value
        XCTAssertIdentical(obj2, obj3) // cached value is returned

        obj1 = nil
        obj2 = nil
        obj3 = nil

        let obj4 = provider.value
        let obj5 = provider.value
        XCTAssertIdentical(obj4, obj5)
        XCTAssertEqual(obj4.value, 42)
    }

    func testWeakCacheWithAutoreleasepool() {
        let provider = Provider {
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
