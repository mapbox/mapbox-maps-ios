import XCTest
import MapboxMaps

final class MapViewSubclassingTests: XCTestCase {

    var attributionURLOpener: MockAttributionURLOpener!

    override func setUp() {
        super.setUp()

        attributionURLOpener = MockAttributionURLOpener()
    }

    override func tearDown() {
        attributionURLOpener = nil
        super.tearDown()
    }

    func testMapViewIsCreated() {
        // These are just dummies so that `MapViewSubclass` won't get deleted as unused.
        // The real test happens at compile time and checks if
        // each `MapViewSubclass` initializer override a corresponding designated initializer
        _ = MapViewSubclass(
            frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)),
            mapInitOptions: MapInitOptions())

        if #available(iOS 13.0, *) {
            _ = MapViewSubclass(
                frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)),
                mapInitOptions: MapInitOptions(),
                urlOpener: attributionURLOpener)
        }

        _ = MapViewSubclass(
            frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)),
            mapInitOptions: MapInitOptions(),
            urlOpener: attributionURLOpener)
    }
}

private final class MapViewSubclass: MapView {

    override init(frame: CGRect, mapInitOptions: MapInitOptions = MapInitOptions()) {
        super.init(frame: frame, mapInitOptions: mapInitOptions)
    }

    override init(frame: CGRect, mapInitOptions: MapInitOptions = MapInitOptions(), urlOpener: AttributionURLOpener) {
        super.init(frame: frame, mapInitOptions: mapInitOptions, urlOpener: urlOpener)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
