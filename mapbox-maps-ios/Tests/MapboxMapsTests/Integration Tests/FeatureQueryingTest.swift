import XCTest
@testable import MapboxMaps

internal class FeatureQueryingTest: MapViewIntegrationTestCase {

    // MARK: - Test querying a rendered map for features.

    /*
     The purpose of this test is to ensure features are returned when querying
     a default style. It does this zooming into an area with dense features,
     and querying the center of the map to ensure there is a populated array of
     features returned.
     */

    // Seattle's Pike Place Market
    let centerCoordinate = CLLocationCoordinate2D(latitude: 47.609519,
                                                  longitude: -122.341647)

    internal func testQueryAtPoint() {
        mapView.mapboxMap.styleURI = .streets

        let featureQueryExpectation = XCTestExpectation(description: "Wait for features to be queried and at least one feature to be returned with a layer.")

        didFinishLoadingStyle = { mapView in

            mapView.mapboxMap.setCamera(to: CameraOptions(center: self.centerCoordinate,
                                    zoom: 15.0))
        }

        mapView.mapboxMap.onMapLoaded.observeNext { [weak self] _ in
            guard let mapView = self?.mapView else { return }

            // Given
            let centerPoint = mapView.center

            // When
            mapView.mapboxMap.queryRenderedFeatures(with: centerPoint) { result in
                switch result {
                case .success(let features):
                    if let firstFeature = features.first,
                       firstFeature.layers.count > 0 {
                        featureQueryExpectation.fulfill()
                    } else {
                        XCTFail("No features found")
                    }
                case .failure:
                    XCTFail("Feature querying failed")
                }
            }
        }.store(in: &cancelables)

        wait(for: [featureQueryExpectation], timeout: 5.0)
    }

    internal func testQueryInRectWithFilter() {
        mapView.mapboxMap.styleURI = .streets

        let featureQueryExpectation = XCTestExpectation(description: "Wait for features to be queried.")

        didFinishLoadingStyle = { mapView in
            mapView.mapboxMap.setCamera(to: CameraOptions(center: self.centerCoordinate,
                                    zoom: 15.0))
        }

        didBecomeIdle = { mapView in
            // Given
            let queryRect = CGRect(x: mapView.center.x - 25,
                                   y: mapView.center.y - 25,
                                   width: 50,
                                   height: 50)

            // When
            mapView.mapboxMap.queryRenderedFeatures(with: queryRect) { unfilteredFeatures in
                let filter = Exp(.eq) {
                    "$type"
                    "Point"
                }

                let options = RenderedQueryOptions(layerIds: nil, filter: filter)
                mapView.mapboxMap.queryRenderedFeatures(with: queryRect, options: options) { filteredFeatures in
                    if case .success(let unfilteredFeatures) = unfilteredFeatures,
                       case .success(let filteredFeatures) = filteredFeatures {

                        let expectedFilteredFeatures = unfilteredFeatures.filter { queriedFeature in
                            if case .point = queriedFeature.queriedFeature.feature.geometry {
                                return true
                            } else {
                                return false
                            }
                        }

                        // Then
                        if expectedFilteredFeatures.count == filteredFeatures.count {
                            featureQueryExpectation.fulfill()
                        } else {
                            XCTFail("Expected \(expectedFilteredFeatures.count) features, got \(filteredFeatures.count) instead.")
                        }
                    } else {
                        XCTFail("Feature querying failed.")
                    }
                }
            }
        }

        wait(for: [featureQueryExpectation], timeout: 5.0)
    }

    internal func testQueryForGeometry() {
        mapView.mapboxMap.styleURI = .streets

        let featureQueryExpectation = XCTestExpectation(description: "Wait for features to be queried.")

        didFinishLoadingStyle = { mapView in

            mapView.mapboxMap.setCamera(to: CameraOptions(center: self.centerCoordinate,
                                    zoom: 15.0))
        }

        mapView.mapboxMap.onMapLoaded.observeNext { [weak self] _ in
            guard let mapView = self?.mapView else { return }

            // Given
            let coordinates = [
                CLLocationCoordinate2D(latitude: 43.58039085560784, longitude: -101.337890625),
                CLLocationCoordinate2D(latitude: 36.87962060502676, longitude: -108.544921875),
                CLLocationCoordinate2D(latitude: 37.09023980307208, longitude: -97.119140625),
                CLLocationCoordinate2D(latitude: 43.58039085560784, longitude: -101.337890625)
            ]
                .map { mapView.mapboxMap.point(for: $0) }

            // When
            mapView.mapboxMap.queryRenderedFeatures(with: coordinates) { result in
                switch result {
                case .success(let features):
                    if features.count > 0 {
                        featureQueryExpectation.fulfill()
                    } else {
                        XCTFail("No features found")
                    }
                case .failure:
                    XCTFail("Feature querying failed")
                }
            }
        }.store(in: &cancelables)

        wait(for: [featureQueryExpectation], timeout: 5.0)
    }

    internal func testQueryRenderedSource() {
        mapView.mapboxMap.styleURI = .streets

        let featureQueryExpectation = XCTestExpectation(description: "Wait for source features to be queried.")

        didFinishLoadingStyle = { mapView in

            mapView.mapboxMap.setCamera(to: CameraOptions(center: self.centerCoordinate,
                                                          zoom: 15.0))
        }

        mapView.mapboxMap.onMapLoaded.observeNext { [weak self] _ in
            guard let mapView = self?.mapView else { return }

            // Given
            let sourceIDs = mapView.mapboxMap.allSourceIdentifiers
            guard let sourceID = sourceIDs.first else {
                XCTFail("No sources in Style")
                return
            }

            // When
            mapView.mapboxMap.querySourceFeatures(for: sourceID.id, options: SourceQueryOptions(sourceLayerIds: ["landuse"], filter: ["==", "type", "commercial_area"])) { result in
                switch result {
                case .success(let features):
                    if features.count > 0 {
                        featureQueryExpectation.fulfill()
                    } else {
                        XCTFail("No source features found")
                    }
                case .failure:
                    XCTFail("Source feature querying failed")
                }
            }
        }.store(in: &cancelables)

        wait(for: [featureQueryExpectation], timeout: 5.0)
    }

    internal func testGeoJsonClusterFunctions() {
        mapView.mapboxMap.styleURI = .streets
        let clusterSourceID = "cluster-source"
        let geoJSONClusterLeavesExpection = XCTestExpectation(description: "Return 4 features as leaves of the cluster.")
        geoJSONClusterLeavesExpection.assertForOverFulfill = true
        let geoJSONClusterZoomExpansionLevelExpection = XCTestExpectation(description: "Return 6 as the expansion zoom level.")
        geoJSONClusterZoomExpansionLevelExpection.assertForOverFulfill = true
        let geoJSONClusterChildrenExpectation = XCTestExpectation(description: "Return 2 features and 1 cluster as children of the cluster.")
        geoJSONClusterChildrenExpectation.assertForOverFulfill = true

        let features = [
            Feature(geometry: Point(CLLocationCoordinate2D(latitude: 0, longitude: 0))),
            Feature(geometry: Point(CLLocationCoordinate2D(latitude: 1, longitude: 0))),
            Feature(geometry: Point(CLLocationCoordinate2D(latitude: 2, longitude: 0))),
            Feature(geometry: Point(CLLocationCoordinate2D(latitude: 0, longitude: 1))),
            Feature(geometry: Point(CLLocationCoordinate2D(latitude: 1, longitude: 1))),
            Feature(geometry: Point(CLLocationCoordinate2D(latitude: 2, longitude: 1))),
            Feature(geometry: Point(CLLocationCoordinate2D(latitude: 0, longitude: 2))),
            Feature(geometry: Point(CLLocationCoordinate2D(latitude: 1, longitude: 2))),
            Feature(geometry: Point(CLLocationCoordinate2D(latitude: 2, longitude: 2))),
            Feature(geometry: Point(CLLocationCoordinate2D(latitude: 0, longitude: 0)))
        ]

        var geoJSONClusterSource = GeoJSONSource(id: clusterSourceID)
        geoJSONClusterSource.data = .featureCollection(FeatureCollection(features: features))
        geoJSONClusterSource.cluster = true

        let geoJSONLayer = CircleLayer(id: "cluster-layer", source: clusterSourceID)

        didFinishLoadingStyle = { mapView in

            mapView.mapboxMap.setCamera(to: CameraOptions(center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
                                                          zoom: 5.0))

            do {
                try mapView.mapboxMap.addSource(geoJSONClusterSource)
                try mapView.mapboxMap.addLayer(geoJSONLayer)
            } catch {
                XCTFail("Failed to add cluster source and layer.")
            }
        }
        mapView.mapboxMap.onMapLoaded.observeNext { [weak self] _ in
            guard let mapView = self?.mapView else { return }
            mapView.mapboxMap.querySourceFeatures(for: clusterSourceID, options: SourceQueryOptions(sourceLayerIds: [clusterSourceID], filter: ["has", "point_count"])) { result
                in
                if case .success(let returnedClusters) = result,
                let firstClusterFeature = returnedClusters.first?.queriedFeature.feature {
                    mapView.mapboxMap.getGeoJsonClusterLeaves(forSourceId: clusterSourceID, feature: firstClusterFeature) { result in
                        switch result {
                        case .success(let leaves):
                            XCTAssertEqual(leaves.features?.count, 4)
                            geoJSONClusterLeavesExpection.fulfill()
                        case .failure(let error):
                            XCTFail("Failed to return correct number of cluster leaves: \(error)")
                        }
                    }

                    mapView.mapboxMap.getGeoJsonClusterExpansionZoom(forSourceId: clusterSourceID, feature: firstClusterFeature) { result in
                        switch result {
                        case .success(let expansionZoomLevel):
                            XCTAssertEqual(expansionZoomLevel.value as? Int, 6)
                            geoJSONClusterZoomExpansionLevelExpection.fulfill()
                        case .failure(let error):
                            XCTFail("Failed to return correct zoom expansion level: \(error)")
                        }
                    }

                    mapView.mapboxMap.getGeoJsonClusterChildren(forSourceId: clusterSourceID, feature: firstClusterFeature) { result in
                        switch result {
                        case .success(let children):
                            XCTAssertEqual(children.features?.count, 3)
                            geoJSONClusterChildrenExpectation.fulfill()
                        case .failure(let error):
                            XCTFail("Failed to return correct number of cluster children: \(error)")
                        }
                    }
                } else {
                    XCTFail("Failed to return any features from a cluster.")
                }
            }
        }.store(in: &cancelables)
        wait(for: [geoJSONClusterLeavesExpection, geoJSONClusterZoomExpansionLevelExpection, geoJSONClusterChildrenExpectation], timeout: 5.0)
    }
}
