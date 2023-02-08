import XCTest
import MapboxMaps

final class MapViewSubclassingTests: XCTestCase {

    var orientationProvider: MockInterfaceOrientationProvider!
    var attributionURLOpener: MockAttributionURLOpener!
    var applicationStateProvider: MockApplicationStateProvider!
    var preferredContentSizeCategoryProvider: MockPreferredContentSizeCategoryProvider!

    override func setUp() {
        super.setUp()

        orientationProvider = MockInterfaceOrientationProvider()
        attributionURLOpener = MockAttributionURLOpener()
        applicationStateProvider = MockApplicationStateProvider()
        preferredContentSizeCategoryProvider = MockPreferredContentSizeCategoryProvider()
    }

    override func tearDown() {
        orientationProvider = nil
        attributionURLOpener = nil
        applicationStateProvider = nil
        preferredContentSizeCategoryProvider = nil
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
                urlOpener: attributionURLOpener,
                applicationStateProvider: applicationStateProvider,
                preferredContentSizeCategoryProvider: preferredContentSizeCategoryProvider)
        }

        _ = MapViewSubclass(
            frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)),
            mapInitOptions: MapInitOptions(),
            orientationProvider: orientationProvider,
            urlOpener: attributionURLOpener,
            applicationStateProvider: applicationStateProvider,
            preferredContentSizeCategoryProvider: preferredContentSizeCategoryProvider)
    }
}

private final class MapViewSubclass: MapView {

    override init(frame: CGRect, mapInitOptions: MapInitOptions = MapInitOptions()) {
        super.init(frame: frame, mapInitOptions: mapInitOptions)
    }

    @available(iOS 13.0, *)
    override init(frame: CGRect, mapInitOptions: MapInitOptions = MapInitOptions(), urlOpener: AttributionURLOpener) {
        super.init(frame: frame, mapInitOptions: mapInitOptions, urlOpener: urlOpener)
    }

    override init(frame: CGRect,
                  mapInitOptions: MapInitOptions = MapInitOptions(),
                  orientationProvider: InterfaceOrientationProvider,
                  urlOpener: AttributionURLOpener,
                  applicationStateProvider: ApplicationStateProvider,
                  preferredContentSizeCategoryProvider: PreferredContentSizeCategoryProvider) {
        super.init(frame: frame,
                   mapInitOptions: mapInitOptions,
                   orientationProvider: orientationProvider,
                   urlOpener: urlOpener,
                   applicationStateProvider: applicationStateProvider,
                   preferredContentSizeCategoryProvider: preferredContentSizeCategoryProvider)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
