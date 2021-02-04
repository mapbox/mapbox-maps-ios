import UIKit
import MapboxMaps
import Turf
import SwiftUI

/// Example of how a SwiftUI map view can be used within a typical `ContentView`.
public struct ContentView: View {

    public var body: some View {
        SwiftUIMapView(resourceOptions: ResourceOptions(accessToken: AccountManager.shared.accessToken!))
            .styleURL(.dark)
            .zoomLevel(14.0)
            .centerCoordinate(CLLocationCoordinate2D(latitude: 20.6905, longitude: -88.2024))
            .on(.mapLoadingFinished) { ( mapView ) in
                let pointAnnotation = PointAnnotation(coordinate: mapView.centerCoordinate)
                mapView.annotationManager.addAnnotation(pointAnnotation)
            }
    }
}

/// To render a `MapView` as a SwiftUI view, configure a new
/// struct that implements the required `UIViewRepresentable` protocol.
public struct SwiftUIMapView: UIViewRepresentable {

    let resourceOptions: ResourceOptions
    internal let observerConcrete: ObserverConcrete // Manages the observation of map events
    internal let mapView: MapView

    init(resourceOptions: ResourceOptions) {
        self.resourceOptions = resourceOptions
        self.mapView = MapView(with: .zero, resourceOptions: resourceOptions)
        self.observerConcrete = ObserverConcrete(mapView: self.mapView)

        // Subscribe to map events
        let events = MapEvents.EventKind.allCases.map { $0.rawValue }
        try? mapView.__map.subscribe(for: observerConcrete, events: events)
    }

    // MARK: - UIViewRepresentable required methods
    public func makeUIView(context: UIViewRepresentableContext<SwiftUIMapView>) -> MapboxMaps.MapView {
        return mapView
    }

    public func updateUIView(_ uiView: MapView, context: Context) {
        // Unimplemented
    }

    // MARK: - Setting basic map properties
    public func styleURL(_ newValue: StyleURL) -> SwiftUIMapView {
        mapView.style.styleURL = newValue
        return self
    }

    public func zoomLevel(_ newValue: CGFloat) -> SwiftUIMapView {
        mapView.cameraManager.setCamera(zoom: newValue)
        return self
    }

    public func centerCoordinate(_ newValue: CLLocationCoordinate2D) -> SwiftUIMapView {
        mapView.cameraManager.setCamera(centerCoordinate: newValue)
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
        internal let mapView: MapView

        init(mapView: MapView) {
            self.mapView = mapView
        }

        /// Map of event types to subscribed event handlers.
        internal var eventHandlers: [String: [(MapboxMaps.MapView) -> Void]] = [:]

        /// Notify the correct handler when the event occurs.
        public func notify(for event: MapboxCoreMaps.Event) {
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
