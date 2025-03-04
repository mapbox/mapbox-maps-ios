import XCTest
@testable import MapboxMaps

class WeakObjectsTests: XCTestCase {

    class TestObject {
        let id: Int

        init(id: Int) {
            self.id = id
        }
    }

    var sut: WeakObjects<TestObject>!

    override func setUp() {
        super.setUp()
        sut = WeakObjects<TestObject>()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testisEmptyhenEmpty_ReturnsTrue() {
        XCTAssertTrue(sut.isEmpty)
    }

    func testisEmptyhenContainsObjects_ReturnsTrue() {
        let object = TestObject(id: 1)
        sut.add(object)
        XCTAssertFalse(sut.isEmpty)

        sut.remove(object)
        XCTAssertTrue(sut.isEmpty)
    }

    func testisEmptyhenAllObjectsAreDeallocated_ReturnsTrue() {
        var object: TestObject? = TestObject(id: 1)
        sut.add(object!)

        object = nil

        XCTAssertTrue(sut.isEmpty)
    }

    func testAdd_WhenAddingSameObjectTwice_AddsOnlyOnce() {
        let object = TestObject(id: 1)
        sut.add(object)
        sut.add(object)

        var count = 0
        sut.forEach { _ in count += 1 }
        XCTAssertEqual(count, 1)
    }

    func testRemove_WhenRemovingExistingObject_RemovesFromCollection() {
        let object = TestObject(id: 1)
        sut.add(object)
        sut.remove(object)
        XCTAssertTrue(sut.isEmpty)
    }

    func testRemove_WhenRemovingNonExistingObject_DoesNothing() {
        let object1 = TestObject(id: 1)
        let object2 = TestObject(id: 2)
        sut.add(object1)
        sut.remove(object2)

        XCTAssertFalse(sut.isEmpty)
    }

    func testRemove_RemovesNilReferences() {
        var object1: TestObject? = TestObject(id: 1)
        let object2 = TestObject(id: 2)
        sut.add(object1!)
        sut.add(object2)

        object1 = nil
        sut.remove(object2)

        XCTAssertTrue(sut.isEmpty)
    }

    func testForEach_CallsCallbackForEachObject() {
        let object1 = TestObject(id: 1)
        let object2 = TestObject(id: 2)
        sut.add(object1)
        sut.add(object2)

        var ids: [Int] = []
        sut.forEach { object in
            ids.append(object.id)
        }

        XCTAssertEqual(ids, [1, 2])
    }

    func testForEach_SkipsDeallocatedObjects() {
        var object1: TestObject? = TestObject(id: 1)
        let object2 = TestObject(id: 2)
        sut.add(object1!)
        sut.add(object2)

        object1 = nil
        var ids: [Int] = []
        sut.forEach { object in
            ids.append(object.id)
        }

        XCTAssertEqual(ids, [2])
    }

    func testForEach_WorksWithEmptyCollection() {
        var called = false
        sut.forEach { _ in
            called = true
        }

        XCTAssertFalse(called)
    }

    func testAsHashTable_ContainsAllObjects() {
        let object1 = TestObject(id: 1)
        let object2 = TestObject(id: 2)
        sut.add(object1)
        sut.add(object2)

        let hashTable = sut.asHashTable
        XCTAssertTrue(hashTable.contains(object1))
        XCTAssertTrue(hashTable.contains(object2))
        XCTAssertEqual(hashTable.count, 2)
    }

    func testAsHashTable_DoesNotContainDeallocatedObjects() {
        var object1: TestObject? = TestObject(id: 1)
        let object2 = TestObject(id: 2)
        sut.add(object1!)
        sut.add(object2)

        object1 = nil
        let hashTable = sut.asHashTable

        // Then
        XCTAssertEqual(hashTable.count, 1)
        XCTAssertTrue(hashTable.contains(object2))
    }

    func testObjectsAreDeallocated() {
        weak var weakObject: TestObject?

        autoreleasepool {
            let object = TestObject(id: 1)
            weakObject = object
            sut.add(object)
        }

        XCTAssertNil(weakObject, "Object should be deallocated")
        XCTAssertTrue(sut.isEmpty, "Collection should not have objects")
    }

    func testMultipleObjectsLifecycle() {
        weak var weakObject1: TestObject?
        weak var weakObject2: TestObject?
        weak var weakObject3: TestObject?

        autoreleasepool {
            let object1 = TestObject(id: 1)
            let object2 = TestObject(id: 2)
            let object3 = TestObject(id: 3)

            weakObject1 = object1
            weakObject2 = object2
            weakObject3 = object3

            sut.add(object1)
            sut.add(object2)
            sut.add(object3)

            sut.remove(object2)
        }

        XCTAssertNil(weakObject1, "Object1 should be deallocated")
        XCTAssertNil(weakObject2, "Object2 should be deallocated")
        XCTAssertNil(weakObject3, "Object3 should be deallocated")
        XCTAssertTrue(sut.isEmpty, "Collection should not have objects")
    }

    func testForEachSafelyHandlesDeallocatedObjectsDuringIteration() {
        let object1 = TestObject(id: 1)
        var object2: TestObject? = TestObject(id: 2)
        let object3 = TestObject(id: 3)

        sut.add(object1)
        sut.add(object2!)
        sut.add(object3)

        var capturedIds: [Int] = []

        sut.forEach { object in
            capturedIds.append(object.id)

            // Deallocate object2 during iteration
            if object.id == 1 {
                object2 = nil
            }
        }

        XCTAssertEqual(capturedIds, [1, 3], "Should capture all object IDs")
    }
}
