import XCTest
@testable import MapboxMaps

// swiftlint:disable orphaned_doc_comment
class MigrationGuideIntegrationTests: IntegrationTestCase {

    var view: UIView?

    private var testRect = CGRect(origin: .zero, size: CGSize(width: 100, height: 100))

    override func setUpWithError() throws {
        try super.setUpWithError()
        try guardForMetalDevice()

        ResourceOptionsManager.default.resourceOptions.accessToken = self.accessToken
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()

        view?.removeFromSuperview()
        view = nil
        ResourceOptionsManager.destroyDefault()
    }

    func geoJSONURL(from name: String) -> URL? {
        guard let path = Bundle.mapboxMapsTests.path(forResource: name, ofType: "geojson") else {
            XCTFail("Fixture \(name) not found.")
            return nil
        }
        return URL(fileURLWithPath: path)
    }

    func testBasicMapViewController() throws {

        let expectation = self.expectation(description: "load map view")

        //-->
        class BasicMapViewController: UIViewController {
            var mapView: MapView!
            var accessToken: String!
            var completion: (() -> Void)?

            override func viewDidLoad() {
                super.viewDidLoad()

                ResourceOptionsManager.default.resourceOptions.accessToken = self.accessToken

                mapView = MapView(frame: view.bounds)
                view.addSubview(mapView)
                completion?()
            }
        }
        //<--

        let vc = BasicMapViewController(nibName: nil, bundle: nil)
        vc.accessToken = accessToken
        vc.completion = {
            expectation.fulfill()
        }

        rootViewController?.view.addSubview(vc.view)
        view = vc.view

        wait(for: [expectation], timeout: 5)
    }

    func testMapLoadingEventsLifecycle() throws {
        let expectation = self.expectation(description: "Map events")
        expectation.expectedFulfillmentCount = 6
        expectation.assertForOverFulfill = false

        //-->
        class BasicMapViewController: UIViewController {
            var mapView: MapView!
            var accessToken: String!
            var handler: (() -> Void)?

            override func viewDidLoad() {
                super.viewDidLoad()

                ResourceOptionsManager.default.resourceOptions.accessToken = self.accessToken

                mapView = MapView(frame: view.bounds)
                view.addSubview(mapView)

                /**
                 The closure is called when style data has been loaded. This is called
                 multiple times. Use the event data to determine what kind of style data
                 has been loaded.

                 When the type is `style` this event most closely matches
                 `-[MGLMapViewDelegate mapView:didFinishLoadingStyle:]` in SDK versions
                 prior to v10.
                 */
                mapView.mapboxMap.onEvery(event: .styleDataLoaded) { [weak self] (event) in
                    guard let handler = self?.handler else {
                        return
                    }

                    print("The map has finished loading style data of type = \(event.payload.type)")
                    handler()
                }

                /**
                 The closure is called during the initialization of the map view and
                 after any `styleDataLoaded` events; it is called when the requested
                 style has been fully loaded, including the style, specified sprite and
                 source metadata.

                 This event is the last opportunity to modify the layout or appearance
                 of the current style before the map view is displayed to the user.
                 Adding a layer at this time to the map may result in the layer being
                 presented BEFORE the rest of the map has finished rendering.

                 Changes to sources or layers of the current style do not cause this
                 event to be emitted.
                 */
                mapView.mapboxMap.onNext(event: .styleLoaded) { (event) in
                    print("The map has finished loading style ... Event = \(event)")
                    self.handler?()
                }

                /**
                 The closure is called whenever the map finishes loading and the map has
                 rendered all visible tiles, either after the initial load OR after a
                 style change has forced a reload.

                 This is an ideal time to add any runtime styling or annotations to the
                 map and ensures that these layers would only be shown after the map has
                 been fully rendered.
                 */
                mapView.mapboxMap.onNext(event: .mapLoaded) { (event) in
                    print("The map has finished loading... Event = \(event)")
                    self.handler?()
                }

                /**
                 The closure is called whenever the map view is entering an idle state,
                 and no more drawing will be necessary until new data is loaded or there
                 is some interaction with the map.

                 - All currently requested tiles have been rendered
                 - All fade/transition animations have completed
                 */
                mapView.mapboxMap.onNext(event: .mapIdle) { (event) in
                    print("The map is idle... Event = \(event)")
                    self.handler?()
                }

                /**
                 The closure is called whenever the map has failed to load. This could
                 be because of a variety of reasons, including a network connection
                 failure or a failure to fetch the style from the server.

                 You can use the associated error message to notify the user that map
                 data is unavailable.
                 */
                mapView.mapboxMap.onNext(event: .mapLoadingError) { (event) in
                    print("The map failed to load.. \(event.payload.error)")
                }
            }
        }
        //<--

        let vc = BasicMapViewController(nibName: nil, bundle: nil)
        vc.accessToken = accessToken
        vc.handler = {
            expectation.fulfill()
        }

        rootViewController?.view.addSubview(vc.view)
        view = vc.view

        wait(for: [expectation], timeout: 5)
    }

    func testMapViewConfiguration() throws {

        let mapView = MapView(frame: .zero)

        //-->
        let restrictedBounds = CoordinateBounds(southwest: CLLocationCoordinate2D(latitude: 10, longitude: 10),
                                                northeast: CLLocationCoordinate2D(latitude: 11, longitude: 11))
        let cameraBoundsOptions = CameraBoundsOptions(bounds: restrictedBounds)

        // Configure map to show a scale bar
        mapView.ornaments.options.scaleBar.visibility = .visible
        try mapView.mapboxMap.setCameraBounds(with: cameraBoundsOptions)
        //<--
    }

    func testAppDelegateConfig() throws {
        //-->
        //import UIKit
        //import MapboxMaps
        //
        //@UIApplicationMain
        class AppDelegate: UIResponder, UIApplicationDelegate {

            var window: UIWindow?
            let customHTTPService = CustomHttpService()

            func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
                // commenting this out for testing purposes to avoid
                // interfering with global state that may impact other
                // tests
                //
                // HttpServiceFactory.setUserDefinedForCustom(customHTTPService)
                return true
            }
        }
        //<--

        //-->
        class CustomHttpService: HttpServiceInterface {
            // MARK: - HttpServiceInterface protocol conformance

            func request(for request: HttpRequest, callback: @escaping HttpResponseCallback) -> UInt64 {
                // Make an API request
                var urlRequest = URLRequest(url: URL(string: request.url)!)

                let methodMap: [HttpMethod: String] = [
                    .get: "GET",
                    .head: "HEAD",
                    .post: "POST"
                ]

                urlRequest.httpMethod          = methodMap[request.method]!
                urlRequest.httpBody            = request.body
                urlRequest.allHTTPHeaderFields = request.headers

                let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in

                    // `HttpResponse` takes an `Expected` type. This is very similar to Swift's
                    // `Result` type. APIs using `Expected` are prone to future changes.
                    let result: Result<HttpResponseData, HttpRequestError>

                    if let error = error {
                        // Map NSURLError to HttpRequestErrorType
                        let requestError = HttpRequestError(type: .otherError, message: error.localizedDescription)
                        result = .failure(requestError)
                    } else if let response = response as? HTTPURLResponse,
                            let data = data {

                        // Keys are expected to be lowercase
                        var headers: [String: String] = [:]
                        for (key, value) in response.allHeaderFields {
                            guard let key = key as? String,
                                  let value = value as? String else {
                                continue
                            }

                            headers[key.lowercased()] = value
                        }

                        let responseData = HttpResponseData(headers: headers, code: Int64(response.statusCode), data: data)
                        result = .success(responseData)
                    } else {
                        // Error
                        let requestError = HttpRequestError(type: .otherError, message: "Invalid response")
                        result = .failure(requestError)
                    }

                    let response = HttpResponse(request: request, result: result)
                    callback(response)
                }

                task.resume()

                // Handle used to cancel requests
                return UInt64(task.taskIdentifier)
            }
        //<--

            func setMaxRequestsPerHostForMax(_ max: UInt8) {
                fatalError()
            }

            func cancelRequest(forId id: UInt64, callback: @escaping ResultCallback) {
                fatalError()
            }

            func supportsKeepCompression() -> Bool {
                return false
            }

            func download(for options: DownloadOptions, callback: @escaping DownloadStatusCallback) -> UInt64 {
                fatalError()
            }

            func setInterceptorForInterceptor(_ interceptor: HttpServiceInterceptorInterface?) {
                fatalError()
            }
        }

        let appDelegate = AppDelegate()

        _ = appDelegate.application(UIApplication.shared, didFinishLaunchingWithOptions: nil)
    }

    func testSettingCamera() {
        let frame = testRect

        /*
         ### Set the map’s camera

         The camera manager can be configured with an initial camera view.
         To set the map’s camera, first create a `CameraOptions`
         object, then direct the map to use it via the `MapInitOptions`.
         `CameraOptions` parameters are optional, so only the required properties
         need to be set.
         */

        //-->
        // Set the center coordinate of the map to Honolulu, Hawaii
        let centerCoordinate = CLLocationCoordinate2D(latitude: 21.3069,
                                                      longitude: -157.8583)
        // Create a camera
        let camera = CameraOptions(center: centerCoordinate,
                                   zoom: 14)

        let options = MapInitOptions(cameraOptions: camera)
        let mapView = MapView(frame: frame, mapInitOptions: options)
        //<--

        do {
            /*
             ### Fit the camera to a given shape

             In the Maps SDK v10, the approach to fitting the camera to a given shape
             like that of pre-v10 versions.

             In v10, call `camera(for:)` functions on the `MapboxMap` to create: a
             camera for a given geometry, a camera that fits a set of rectangular
             coordinate bounds or a camera based off of a collection of coordinates.
             Then, call `ease(to:)` on `MapView.camera` to visibly transition
             to the new camera.

             Below is an example of setting the camera to a set of coordinates:
             */

            //-->
            let coordinates = [
                CLLocationCoordinate2DMake(24, -89),
                CLLocationCoordinate2DMake(24, -88),
                CLLocationCoordinate2DMake(26, -88),
                CLLocationCoordinate2DMake(26, -89),
                CLLocationCoordinate2DMake(24, -89)
            ]
            let camera = mapView.mapboxMap.camera(for: coordinates,
                                                  padding: .zero,
                                                  bearing: nil,
                                                  pitch: nil)
            mapView.camera.ease(to: camera, duration: 10.0)
            //<--
        }
    }

    func testMapCameraOptions() throws {
        let mapView = MapView(frame: .zero)

        //-->
        let sw = CLLocationCoordinate2DMake(-12, -46)
        let ne = CLLocationCoordinate2DMake(2, 43)
        let restrictedBounds = CoordinateBounds(southwest: sw, northeast: ne)
        try mapView.mapboxMap.setCameraBounds(with: CameraBoundsOptions(bounds: restrictedBounds,
                                                                        maxZoom: 15.0,
                                                                        minZoom: 8.0))
        //<--
    }

    func testGeoJSONSource() {
        //-->
        var myGeoJSONSource = GeoJSONSource()
        myGeoJSONSource.maxzoom = 14
        //<--

        let someTurfFeature = Feature(geometry: Point(CLLocationCoordinate2D(latitude: 0, longitude: 0)))
        let someTurfFeatureCollection = FeatureCollection(features: [someTurfFeature])
        let someGeoJSONDocumentURL = geoJSONURL(from: "polygon")!

        //-->
        // Setting the `data` property with a url pointing to a GeoJSON document
        myGeoJSONSource.data = .url(someGeoJSONDocumentURL)

        // Setting a Turf feature to the `data` property
        myGeoJSONSource.data = .featureCollection(someTurfFeatureCollection)
        //<--
    }

    func testAddGeoJSONSource() {
        var myGeoJSONSource = GeoJSONSource()
        myGeoJSONSource.maxzoom = 14
        myGeoJSONSource.data = .url(geoJSONURL(from: "polygon")!)

        let mapView = MapView(frame: testRect)
        let expectation = self.expectation(description: "Source was added")
        mapView.mapboxMap.onNext(event: .styleLoaded) { _ in
            do {
                //-->
                try mapView.mapboxMap.style.addSource(myGeoJSONSource, id: "my-geojson-source")
                //<--

                /*
                 As mentioned earlier, all `Layer`s are also Swift structs. The
                 following code sets up a background layer and sets its background
                 color to red:
                 */

                //-->
                var myBackgroundLayer = BackgroundLayer(id: "my-background-layer")
                myBackgroundLayer.backgroundColor = .constant(StyleColor(.red))
                //<--

                /*
                Once a layer is created, add it to the map:
                */
                //-->
                try mapView.mapboxMap.style.addLayer(myBackgroundLayer)
                //<--

                expectation.fulfill()
            } catch {
                XCTFail("Failed to add source: \(error)")
            }
        }

        wait(for: [expectation], timeout: 5.0)
    }

    func testExpression() throws {
        let mapView = MapView(frame: testRect)
        let expectation = self.expectation(description: "layer updated")
        mapView.mapboxMap.onNext(event: .styleLoaded) { _ in
            do {

                //-->
                let expressionString =
                    """
                    [
                        "interpolate",
                        ["linear"],
                        ["zoom"],
                        0,
                        "hsl(0, 79%, 53%)",
                        14,
                        "hsl(233, 80%, 47%)"
                    ]
                    """

                if let expressionData = expressionString.data(using: .utf8) {
                    let expJSONObject = try JSONSerialization.jsonObject(with: expressionData, options: [])

                    try mapView.mapboxMap.style.setLayerProperty(for: "land",
                                                                 property: "background-color",
                                                                 value: expJSONObject)
                }
                //<--
                expectation.fulfill()
            } catch {
                XCTFail("Failed with \(error)")
            }
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func testEnableLocation() {
        let mapView = MapView(frame: testRect)
        //-->
        mapView.location.options.puckType = .puck2D()
        //<--

        let customLocationProvider = MockLocationProvider()
        //-->
        mapView.location.overrideLocationProvider(with: customLocationProvider)
        //<--
    }

    func testAdd3DTerrain() {
        let mapView = MapView(frame: testRect)
        let expectation = self.expectation(description: "Source was added")
        mapView.mapboxMap.onNext(event: .styleLoaded) { _ in
            do {
                //-->
                // Add terrain
                var demSource = RasterDemSource()
                demSource.url = "mapbox://mapbox.mapbox-terrain-dem-v1"
                demSource.tileSize = 512
                demSource.maxzoom = 14.0
                try mapView.mapboxMap.style.addSource(demSource, id: "mapbox-dem")

                var terrain = Terrain(sourceId: "mapbox-dem")
                terrain.exaggeration = .constant(1.5)

                // Add sky layer
                try mapView.mapboxMap.style.setTerrain(terrain)

                var skyLayer = SkyLayer(id: "sky-layer")
                skyLayer.skyType = .constant(.atmosphere)
                skyLayer.skyAtmosphereSun = .constant([0.0, 0.0])
                skyLayer.skyAtmosphereSunIntensity = .constant(15.0)

                try mapView.mapboxMap.style.addLayer(skyLayer)
                //<--

                expectation.fulfill()
            } catch {
                XCTFail("Failed to add source: \(error)")
            }
        }

        wait(for: [expectation], timeout: 5.0)
    }
}
