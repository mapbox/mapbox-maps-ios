import XCTest
import MapboxMaps

class MigrationGuideIntegrationTests: IntegrationTestCase {

    func testBasicMapViewController() throws {

        let expectation = self.expectation(description: "load map view")

        //-->
        CredentialsManager.default.accessToken = accessToken

        class BasicMapViewController: UIViewController {
            var mapView: MapView!
            var completion: (() -> Void)?

            override func viewDidLoad() {
                super.viewDidLoad()

                mapView = MapView(frame: view.bounds)
                view.addSubview(mapView)
                completion?()
            }
        }
        //<--

        let vc = BasicMapViewController(nibName: nil, bundle: nil)
        vc.completion = {
            expectation.fulfill()
        }

        rootViewController?.view.addSubview(vc.view)

        wait(for: [expectation], timeout: 5)
    }

    func testMapLoadingEventsLifecycle() throws {
        let expectation = self.expectation(description: "Map events")
        expectation.expectedFulfillmentCount = 4
        expectation.assertForOverFulfill = false

        //-->
        CredentialsManager.default.accessToken = accessToken

        class BasicMapViewController: UIViewController {

            var mapView: MapView!
            var handler: ((Event) -> Void)?

            override func viewDidLoad() {
                super.viewDidLoad()
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
                mapView.on(.styleDataLoaded) { [weak self] (event) in
                    guard let data = event.data as? [String: Any],
                          let type = data["type"],
                          let handler = self?.handler else {
                        return
                    }

                    print("The map has finished loading style data of type = \(type)")
                    handler(event)
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
                mapView.on(.styleLoaded) { [weak self] (event) in
                    print("The map has finished loading style ... Event = \(event)")
                    self?.handler?(event)
                }

                /**
                 The closure is called whenever the map finishes loading and the map has
                 rendered all visible tiles, either after the initial load OR after a
                 style change has forced a reload.

                 This is an ideal time to add any runtime styling or annotations to the
                 map and ensures that these layers would only be shown after the map has
                 been fully rendered.
                 */
                mapView.on(.mapLoaded) { [weak self] (event) in
                    print("The map has finished loading... Event = \(event)")
                    self?.handler?(event)
                }

                /**
                 The closure is called whenever the map view is entering an idle state,
                 and no more drawing will be necessary until new data is loaded or there
                 is some interaction with the map.

                 - All currently requested tiles have been rendered
                 - All fade/transition animations have completed
                 */
                mapView.on(.mapIdle) { [weak self] (event) in
                    print("The map is idle... Event = \(event)")
                    self?.handler?(event)
                }

                /**
                 The closure is called whenever the map has failed to load. This could
                 be because of a variety of reasons, including a network connection
                 failure or a failure to fetch the style from the server.

                 You can use the associated error message to notify the user that map
                 data is unavailable.
                 */
                mapView.on(.mapLoadingError) { (event) in
                    guard let data = event.data as? [String: Any],
                          let type = data["type"],
                          let message = data["message"] else {
                        return
                    }

                    print("The map failed to load.. \(type) = \(message)")
                }
            }
        }
        //<--

        let vc = BasicMapViewController(nibName: nil, bundle: nil)
        vc.handler = { _ in
            expectation.fulfill()
        }

        rootViewController?.view.addSubview(vc.view)

        wait(for: [expectation], timeout: 5)

    }

    func testMapViewConfiguration() throws {

        let mapView = MapView(frame: .zero)
        let someBounds = CoordinateBounds()

        //-->
        mapView.update { (mapOptions) in
            // Configure map to show a scale bar
            mapOptions.ornaments.scaleBarVisibility = .visible

            // Configure map to disable pitch gestures
            mapOptions.gestures.pitchEnabled = false

            // Configure map to restrict panning to a set of coordinate bounds
            mapOptions.camera.restrictedCoordinateBounds = someBounds
        }
        //<--
    }

    func testAppDelegateConfig() throws {

        //-->
        class AppDelegate: UIResponder, UIApplicationDelegate {

            var window: UIWindow?
            let customHTTPService = CustomHttpService()

            func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
                try! HttpServiceFactory.setUserDefinedForCustom(customHTTPService)
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
                    .get : "GET",
                    .head : "HEAD",
                    .post : "POST"
                ]

                urlRequest.httpMethod          = methodMap[request.method]!
                urlRequest.httpBody            = request.body
                urlRequest.allHTTPHeaderFields = request.headers

                let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in

                    // `HttpResponse` takes an `MBXExpected` type. This is very similar to Swift's
                    // `Result` type. APIs using `MBXExpected` are prone to future changes.
                    let expected: MBXExpected<HttpResponseData, HttpRequestError>

                    if let error = error {
                        // Map NSURLError to HttpRequestErrorType
                        let requestError = HttpRequestError(type: .otherError, message: error.localizedDescription)
                        expected = MBXExpected(error: requestError)
                    }
                    else if let response = response as? HTTPURLResponse,
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
                        expected = MBXExpected(value: responseData)
                    }
                    else {
                        // Error
                        let requestError = HttpRequestError(type: .otherError, message: "Invalid response")
                        expected = MBXExpected(error: requestError)
                    }

                    let response = HttpResponse(request: request, result: expected as! MBXExpected<AnyObject, AnyObject>)
                    callback(response)
                }

                task.resume()

                // Handle used to cancel requests
                return UInt64(task.taskIdentifier)
            }
        //<--

            func setMaxRequestsPerHostForMax(_ max: UInt8) {
                fatalError("TODO")
            }

            func cancelRequest(forId id: UInt64, callback: @escaping ResultCallback) {
                fatalError("TODO")
            }

            func supportsKeepCompression() -> Bool {
                return false
            }

            func download(for options: DownloadOptions, callback: @escaping DownloadStatusCallback) -> UInt64 {
                fatalError("TODO")
            }
        }

        let application = UIApplication()
        let appDelegate = AppDelegate()

        _ = appDelegate.application(application, didFinishLaunchingWithOptions: nil)
    }
}
