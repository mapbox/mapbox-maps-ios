import XCTest
import MapboxMaps

@available(iOS 13.0, *)
class GeoJSONUpdateIntegrationTests: MapViewIntegrationTestCase {
    static let sourceId = "source"
    static let dataId = "geojson_id"
    static let initialDataId = "add_geojson_source"

    var initialFeatures: [Feature]!
    var parameter: TestParameters! {
        didSet {
            guard let parameter else { return }
            operationalFeatures = .random(size: parameter.operationalFeatureSize, isInitial: parameter.command != .add)
        }
    }
    var sourceLoadedToken: Cancelable?
    private var operationalFeatures: [Feature]!

    override func setUpWithError() throws {
        try super.setUpWithError()

        initialFeatures = .random(size: parameter.initialFeatureSize)

        mapView.mapboxMap.styleURI = .streets

        let sourceAddedExpectation = expectation(description: "Wait for source to be added")

        didFinishLoadingStyle = { [weak self] mapView in
            guard let self else { return }

            var source = GeoJSONSource(id: Self.sourceId)
            source.data = .featureCollection(.init(features: self.initialFeatures))
            try! mapView.mapboxMap.addSource(source, dataId: Self.initialDataId)

            self.sourceLoadedToken = mapView.mapboxMap.onSourceDataLoaded.observe { [weak self] event in
                guard event.sourceId == Self.sourceId, event.dataId == Self.initialDataId else {
                    return
                }
                sourceAddedExpectation.fulfill()
                self?.sourceLoadedToken = nil
            }
        }

        wait(for: [sourceAddedExpectation], timeout: 10)
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()

        initialFeatures = nil
        parameter = nil
        operationalFeatures = nil
        self.sourceLoadedToken = nil
    }

    func benchmarkGeoJSONUpdate() {
        let updateExpectation = self.expectation(description: "Wait for GeoJSON to be updated")

        mapView.mapboxMap.onSourceDataLoaded.observe { event in
            guard event.sourceId == Self.sourceId, event.dataId == Self.dataId else {
                return
            }

            updateExpectation.fulfill()
        }.store(in: &cancelables)

        switch parameter.updateType {
        case .partial:
            performPartialGeoJSONUpdate(operationalFeatures)
        case .full:
            performFullGeoJSONUpdate(operationalFeatures)
        }

        wait(for: [updateExpectation], timeout: 10)
    }

    func measureOnceIgnoringWarmUpIteration(_ block: () -> Void) {
        var warmUpIgnored = false
        let options = XCTMeasureOptions()
        options.iterationCount = 1

        measure(options: options) {
            guard warmUpIgnored else {
                warmUpIgnored = true
                return
            }

            block()
        }
    }

    struct TestParameters {
        // swiftlint:disable:next nesting
        enum UpdateType: String {
            case full, partial
        }
        // swiftlint:disable:next nesting
        enum Command: String, CaseIterable {
            case add, update, remove
        }

        private static let formatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.groupingSeparator = "_"
            formatter.groupingSize = 3
            formatter.usesGroupingSeparator = true
            formatter.locale = .init(identifier: "en_US_POSIX")
            return formatter
        }()
        let initialFeatureSize: Int
        let operationalFeatureSize: Int
        let command: Command
        let updateType: UpdateType

        var testName: String {
            return "test" +
            updateType.rawValue.capitalized +
            command.rawValue.capitalized +
            "Initial\(Self.formatter.string(for: initialFeatureSize)!)" +
            "Operational\(Self.formatter.string(for: operationalFeatureSize)!)"
        }
    }
    static let parameters: [TestParameters] = {
        let initialFeatureSizes: [Int] = [100, 1_000, 10_000, 50_000, 100_000]
        let operationalFeatureSizes: [Int] = [1, 100, 1_000, 10_000, 50_000, 100_000]

        let iterations = 1
        return (0..<iterations).flatMap { _ in
            TestParameters.Command.allCases.flatMap { (command: TestParameters.Command) -> [TestParameters] in
                initialFeatureSizes.flatMap { initialSize in
                    operationalFeatureSizes.compactMap { (operationalSize: Int) -> [TestParameters]? in
                        guard initialSize >= operationalSize || command == .add else { return nil }
                        let updateTypes: [TestParameters.UpdateType]
                        switch command {
                        case .add:
                            updateTypes = [.full, .partial]
                        case .update, .remove:
                            updateTypes = [.partial]
                        }
                        return updateTypes.map { updateType in
                            return TestParameters(initialFeatureSize: initialSize,
                                                  operationalFeatureSize: operationalSize,
                                                  command: command,
                                                  updateType: updateType)
                        }
                    }.flatMap { $0 }
                }
            }
        }
    }()

    override class var defaultTestSuite: XCTestSuite {
        let newTestSuite = XCTestSuite(forTestCaseClass: self)

        guard let method = class_getInstanceMethod(self, #selector(executeTest)) else {
            fatalError()
        }

        let existingImpl = method_getImplementation(method)
        for parameter in parameters {
            // Add a method for this test, but using the same implementation
            let testSelector = Selector(parameter.testName)
            class_addMethod(self, testSelector, existingImpl, "v@:f")

            let test = GeoJSONUpdateIntegrationTests(selector: testSelector)
            test.parameter = parameter
            newTestSuite.addTest(test)
        }

        return newTestSuite
    }

    @objc private func executeTest() {
        measureOnceIgnoringWarmUpIteration {
            benchmarkGeoJSONUpdate()
        }
    }

    func performPartialGeoJSONUpdate(_ features: [Feature]) {
        switch parameter.command {
        case .add:
            mapView.mapboxMap.addGeoJSONSourceFeatures(forSourceId: Self.sourceId,
                                                       features: features,
                                                       dataId: Self.dataId)
        case .update:
            mapView.mapboxMap.updateGeoJSONSourceFeatures(forSourceId: Self.sourceId,
                                                          features: features,
                                                          dataId: Self.dataId)
        case .remove:
            let featureIds = features.compactMap { (feature: Feature) -> String? in
                guard case .string(let id) = feature.identifier else {
                    return nil
                }

                return id
            }
            mapView.mapboxMap.removeGeoJSONSourceFeatures(forSourceId: Self.sourceId,
                                                          featureIds: featureIds,
                                                          dataId: Self.dataId)
        }
    }

    func performFullGeoJSONUpdate(_ features: [Feature]) {
        let fullList = initialFeatures + features

        mapView.mapboxMap.updateGeoJSONSource(withId: Self.sourceId,
                                              geoJSON: .featureCollection(.init(features: fullList)),
                                              dataId: Self.dataId)
    }
}

extension Array where Element == Feature {
    static func random(size: Int, isInitial: Bool = true) -> [Feature] {
        return (0..<size)
            .map { index in
                let coordinate = CLLocationCoordinate2D(
                    latitude: 0.01 * Double(index),
                    longitude: 0.01 * Double(index))
                let geometry = Point(coordinate).geometry
                var feature = Feature(geometry: geometry)
                feature.identifier = .string(isInitial ? "Base_FEATURE_\(index)" : "FEATURE_\(index)")
                return feature
            }
            .shuffled()
    }
}
