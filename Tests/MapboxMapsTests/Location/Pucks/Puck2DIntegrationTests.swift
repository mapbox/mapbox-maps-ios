import XCTest
@testable import MapboxMaps

class Puck2DIntegrationTests: MapViewIntegrationTestCase {
    var resourceOptions: ResourceOptions!

    override func setUpWithError() throws {
        try super.setUpWithError()
        resourceOptions = try ResourceOptions(accessToken: mapboxAccessToken())
    }

    func testAddingPrecisePuck2D() throws {
        let style = try XCTUnwrap(self.style)
        style.uri = .streets

        let createPuckExpectation = XCTestExpectation(description: "Create a precise Puck2D.")
        let styleContainsPuckExpectation = XCTestExpectation(description: "Style contains puck layer.")

        didFinishLoadingStyle = { _ in
            let puck = Puck2D(puckStyle: .precise,
                              puckBearingSource: .heading,
                              style: style,
                              configuration: Puck2DConfiguration())
            do {
                try puck.createPreciseLocationIndicatorLayer(location: Location(with: CLLocation(latitude: 1, longitude: 1)))
                createPuckExpectation.fulfill()
            } catch {
                XCTFail("Failed to create a precise location indicator layer.")
            }

            let puckExists = style.layerExists(withId: "puck")
            if puckExists {
                styleContainsPuckExpectation.fulfill()
            }
        }
        wait(for: [styleContainsPuckExpectation, createPuckExpectation], timeout: 5)
    }

    func testAddingApproximatePuck2D() throws {
        let style = try XCTUnwrap(self.style)
        style.uri = .streets

        let createPuckExpectation = XCTestExpectation(description: "Create an approximate Puck2D.")
        let styleContainsPuckExpectation = XCTestExpectation(description: "style contains puck layer.")

        didFinishLoadingStyle = { _ in
            let puck = Puck2D(puckStyle: .approximate,
                              puckBearingSource: .heading,
                              style: style,
                              configuration: Puck2DConfiguration())
            do {
                try puck.createApproximateLocationIndicatorLayer(location: Location(with: CLLocation(latitude: 1, longitude: 1)))
                createPuckExpectation.fulfill()
            } catch {
                XCTFail("Failed to create an approximate location indicator layer.")
            }

            let puckExists = style.layerExists(withId: "approximate-puck")
            if puckExists {
                styleContainsPuckExpectation.fulfill()
            }
        }
        wait(for: [createPuckExpectation, styleContainsPuckExpectation], timeout: 5)
    }
    func testRemovePuck2D() throws {
        let style = try XCTUnwrap(self.style)
        style.uri = .streets

        let createPuckExpectation = XCTestExpectation(description: "Create a precise Puck2D.")
        let removePuckExpectation = XCTestExpectation(description: "Remove a precise Puck2D.")

        didFinishLoadingStyle = { _ in
            let puck = Puck2D(puckStyle: .precise,
                              puckBearingSource: .heading,
                              style: style,
                              configuration: Puck2DConfiguration())

            do {
                try puck.createPreciseLocationIndicatorLayer(location: Location(with: CLLocation(latitude: 1, longitude: 1)))
                createPuckExpectation.fulfill()
            } catch {
                XCTFail("Failed to create a precise location indicator layer.")
            }

            puck.removePuck()
            let puckExists = style.layerExists(withId: "puck")
            if !puckExists {
                removePuckExpectation.fulfill()
            }
        }

        wait(for: [removePuckExpectation, createPuckExpectation], timeout: 5)
    }

    func testUpdateToPrecisePuck() throws {
        let style = try XCTUnwrap(self.style)
        style.uri = .streets

        let location = Location(with: CLLocation(latitude: 1, longitude: 1))
        let addedPrecisePuckExpectation = XCTestExpectation(description: "Style contains precise puck layer.")
        let removedPrecisePuckExpectation = XCTestExpectation(description: "Style does not contain precise puck layer.")
        let addedApproximatePuckExpectation = XCTestExpectation(description: "Style contains approximate puck layer.")

        didFinishLoadingStyle = { _ in
            let puck = Puck2D(puckStyle: .precise,
                              puckBearingSource: .heading,
                              style: style,
                              configuration: Puck2DConfiguration())
            do {
                try puck.createPreciseLocationIndicatorLayer(location: location)
            } catch {
                XCTFail("Failed to create a precise location indicator layer.")
            }

            if style.layerExists(withId: "puck") {
                addedPrecisePuckExpectation.fulfill()
            }

            puck.updateStyle(puckStyle: .approximate, location: location)

            if !style.layerExists(withId: "puck") {
                removedPrecisePuckExpectation.fulfill()
            }

            if style.layerExists(withId: "approximate-puck") {
                addedApproximatePuckExpectation.fulfill()
            }
        }
        wait(for: [addedPrecisePuckExpectation, removedPrecisePuckExpectation, addedApproximatePuckExpectation], timeout: 5)
    }

    func testAccuracyRadiusIsHidden() throws {
        let style = try XCTUnwrap(self.style)
        style.uri = .streets

        let location = Location(with: CLLocation(latitude: 1, longitude: 1))
        let accuracyRingIsHiddenExpectation = XCTestExpectation(description: "Layer does not contain an accuracy ring")

        didFinishLoadingStyle = { _ in
            let puck = Puck2D(puckStyle: .precise,
                              puckBearingSource: .heading,
                              style: style,
                              configuration: Puck2DConfiguration())
            do {
                try puck.createPreciseLocationIndicatorLayer(location: location)
                let layer = try style.layer(withId: "puck") as LocationIndicatorLayer
                XCTAssertNil(layer.accuracyRadius)
            } catch {
                XCTFail("Failed to create a precise location indicator layer.")
            }

            accuracyRingIsHiddenExpectation.fulfill()
        }
        wait(for: [accuracyRingIsHiddenExpectation], timeout: 5)
    }

    func testAccuracyRadiusIsShown() throws {
        let style = try XCTUnwrap(self.style)
        style.uri = .streets

        let location = Location(with: CLLocation(latitude: 1, longitude: 1))
        let accuracyRingIsVisibleExpectation = XCTestExpectation(description: "Layer contains an accuracy ring")

        didFinishLoadingStyle = { _ in
            let puck = Puck2D(puckStyle: .precise,
                              puckBearingSource: .heading,
                              style: style,
                              configuration: Puck2DConfiguration(showsAccuracyRing: true))
            do {
                try puck.createPreciseLocationIndicatorLayer(location: location)
                let layer = try style.layer(withId: "puck") as LocationIndicatorLayer
                XCTAssertNotNil(layer.accuracyRadius)
            } catch {
                XCTFail("Failed to create a precise location indicator layer.")
            }

            accuracyRingIsVisibleExpectation.fulfill()
        }
        wait(for: [accuracyRingIsVisibleExpectation], timeout: 5)
    }

    func testLayerPersistence() throws {
        let style = try XCTUnwrap(self.style)

        mapView?.mapboxMap.onNext(.mapLoaded, handler: { _ in
            let puck = Puck2D(puckStyle: .approximate,
                              puckBearingSource: .heading,
                              style: style,
                              configuration: Puck2DConfiguration())
            do {
                try puck.createPreciseLocationIndicatorLayer(location: Location(with: CLLocation(latitude: 1, longitude: 1)))
            } catch {
                XCTFail("Failed to create an precise location indicator layer.")
            }
            let isPersistent = try! style.isPersistentLayer(id: "puck")
            XCTAssertTrue(isPersistent, "The puck layer should be a persistent layer.")
        })
    }
}
