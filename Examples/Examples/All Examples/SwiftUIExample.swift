import UIKit
import MapboxMaps
import Turf
import SwiftUI

/// Example of how a SwiftUI map view can be used within a typical `ContentView`.
public struct ContentView: View {

    public var body: some View {

        SwiftUIMapView(resourceOptions: ResourceOptions(accessToken: AccountManager.shared.accessToken!))
            .zoomLevel(18.0)
            .centerCoordinate(CLLocationCoordinate2D(latitude: 20.6905, longitude: -88.2024))
            .zoomLevel(14.0)
            .styleURL(.dark)
            .on(.mapLoadingFinished) { ( mapView ) in
                let pointAnnotation = PointAnnotation(coordinate: mapView.centerCoordinate)
                mapView.annotationManager.addAnnotation(pointAnnotation)
            }
    }
}

/// Create a view model that is an `ObservableObject`
/// so the map will be able to re-rendeer when map
/// properties change.
public class MapViewModel: ObservableObject {
    @Published var centerCoordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    @Published var zoomLevel = CGFloat.zero
    @Published var styleURL = StyleURL.streets
}

/// To render a `MapView` as a SwiftUI view, configure a new
/// struct that implements the required `UIViewRepresentable` protocol.
public struct SwiftUIMapView: UIViewRepresentable {

    let resourceOptions: ResourceOptions
    @State internal var observerConcrete = ObserverConcrete() // Manages the observation of map events
    @ObservedObject internal var mapViewModel: MapViewModel

    init(resourceOptions: ResourceOptions) {
        self.resourceOptions = resourceOptions
        self.mapViewModel = MapViewModel()
    }

    // MARK: - UIViewRepresentable required methods
    public func makeUIView(context: UIViewRepresentableContext<SwiftUIMapView>) -> MapboxMaps.MapView {
        let mapView = MapView(with: .zero, resourceOptions: resourceOptions)

        // Subscribe to map events
        observerConcrete.mapView = mapView
        let events = MapEvents.EventKind.allCases.map { $0.rawValue }
        try? mapView.__map.subscribe(for: observerConcrete, events: events)

        return mapView
    }

    public func updateUIView(_ uiView: MapView, context: Context) {
        uiView.cameraManager.setCamera(centerCoordinate: mapViewModel.centerCoordinate,
                                       zoom: mapViewModel.zoomLevel,
                                       animated: false)
        uiView.style.styleURL = mapViewModel.styleURL
    }

    // MARK: - Setting basic map properties

    public func centerCoordinate(_ newValue: CLLocationCoordinate2D) -> SwiftUIMapView {
        self.mapViewModel.centerCoordinate = newValue
        return self
    }

    public func zoomLevel(_ newValue: CGFloat) -> SwiftUIMapView {
        self.mapViewModel.zoomLevel = newValue
        return self
    }

    public func styleURL(_ newValue: StyleURL) -> SwiftUIMapView {
        self.mapViewModel.styleURL = newValue
        return self
    }

    // MARK: - Responding to events
    // Allows the SwiftUI map view to respond to map events coming from the internal `MapView`.
    public func on(_ eventType: MapEvents.EventKind, handler: @escaping (MapboxMaps.MapView) -> Void) -> SwiftUIMapView {
        var handlers: [(MapboxMaps.MapView) -> Void] = observerConcrete.eventHandlers[eventType.rawValue] ?? []
        handlers.append(handler)
        observerConcrete.eventHandlers[eventType.rawValue] = handlers
        return self
    }

    /// The nested class responsible for listening to map events.
    class ObserverConcrete: Observer {
        public var peer: MBXPeerWrapper?
        public var mapView: MapView?

        init() { }

        /// Map of event types to subscribed event handlers.
        internal var eventHandlers: [String: [(MapboxMaps.MapView) -> Void]] = [:]

        /// Notify the correct handler when the event occurs.
        public func notify(for event: MapboxCoreMaps.Event) {
            guard let mapView = mapView else { return }
            let handlers = eventHandlers[event.type]
            handlers?.forEach({ (handler) in
                handler(mapView)
            })
        }
    }
}

/// Since the target of this example application is a UIKit-based app,
/// for the purposes of this particular example we're embedding a
/// `UIHostingController` in order to render the SwiftUI view
/// within this example's view controller.
@objc(SwiftUIExample)
public class SwiftUIExample: UIViewController, ExampleProtocol {

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupHostingController()
    }

    internal func setupHostingController() {
        let childView = UIHostingController(rootView: ContentView())
        addChild(childView)
        childView.view.frame = self.view.frame
        view.addSubview(childView.view)
        childView.didMove(toParent: self)
    }
}
