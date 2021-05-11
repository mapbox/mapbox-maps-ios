import UIKit
import MapboxMaps
import Turf
import SwiftUI

internal struct Camera {
    var center: CLLocationCoordinate2D
    var zoom: CGFloat
}

/// `SwiftUIMapView` is a SwiftUI wrapper around UIKit-based `MapView`.
/// It works by conforming to the `UIViewRepresentable` protocol. When
/// your app uses `SwiftUIMapView`, SwiftUI creates and manages a
/// single instance of `MapView` behind the scenes so that if your map
/// configuration changes, the underlying map view doesn't need to be recreated.
@available(iOS 13.0, *)
internal struct SwiftUIMapView: UIViewRepresentable {

    /// Bindings should be used for map values that can
    /// change as a result of user interaction. They allow
    /// other UI elements to stay in sync as the user interacts
    /// with the map. Here, we add a `camera` binding
    /// that represents a subset of the available camera functionality.
    /// Your app could customize this to your use case. In this example
    /// the binding is set via `init(resourceOptions:camera:)`
    @Binding private var camera: Camera

    /// Map attributes that can only be configured programmatically
    /// can simply be exposed as a private var paired with a
    /// builder-style method. When you use `SwiftUIMapView`, you
    /// have the option to customize it by calling the builder method.
    /// For example, with `styleURI`, you might say
    private var styleURI = StyleURI.streets

    /// This is the builder-style method for setting `styleURI`.
    /// It returns an updated `SwiftUIMapView` value that
    /// has the specified `styleURI`. This approach allows you
    /// to chain these customizers — a common pattern in SwiftUI.
    func styleURI(_ styleURI: StyleURI) -> Self {
        var updated = self
        updated.styleURI = styleURI
        return updated
    }

    /// Here's a property and builder method for annotations
    private var annotations = [Annotation]()

    func annotations(_ annotations: [Annotation]) -> Self {
        var updated = self
        updated.annotations = annotations
        return updated
    }

    /// Unlike `styleURI`, there's no good default value for `mapInitOptions`
    /// because it's the value that contains your Mapbox access token. For that reason,
    /// it's declared here as a `let` and is a required parameter in the initializer.
    private let mapInitOptions: MapInitOptions

    init(mapInitOptions: MapInitOptions, camera: Binding<Camera>) {
        self.mapInitOptions = mapInitOptions
        _camera = camera
    }

    /// The first time SwiftUI needs to render this view, it starts by invoking `makeCoordinator()`.
    /// SwiftUI holds on to the value you return just like it holds on to the `MapView`. This gives you a
    /// place to direct callbacks from the MapView (delegates, observer callbacks, etc). You need to
    /// use the coordinator for this and not this struct because this struct can be recreated many times
    /// as your map configurations change externally. Fortunately, even as this struct is recreated,
    /// the coordinator and the map view will only be created once.
    func makeCoordinator() -> SwiftUIMapViewCoordinator {
        SwiftUIMapViewCoordinator(camera: $camera)
    }

    /// After SwiftUI creates the coordinator, it creates the underlying `UIView`, in this case a `MapView`.
    /// This method should create the `MapView`, and make sure that it is configured to be in sync
    /// with the current settings of `SwiftUIMapView` (in this example, just the `camera` and `styleURI`).
    func makeUIView(context: UIViewRepresentableContext<SwiftUIMapView>) -> MapView {
        let mapView = MapView(frame: .zero, mapInitOptions: mapInitOptions)
        updateUIView(mapView, context: context)

        /// Additionally, this is your opportunity to connect the coordinator to the map view. In this example
        /// the coordinator is given a reference to the map view. It uses the reference to set up the necessary
        /// observations so that it can respond to map events.
        context.coordinator.mapView = mapView

        return mapView
    }

    /// If your `SwiftUIMapView` is reconfigured externally, SwiftUI will invoke `updateUIView(_:context:)`
    /// to give you an opportunity to re-sync the state of the underlying map view.
    func updateUIView(_ mapView: MapView, context: Context) {
        mapView.camera.setCamera(to: CameraOptions(center: camera.center, zoom: camera.zoom))
        /// Since changing the style causes annotations to be removed from the map
        /// we only call the setter if the value has changed.
        if mapView.style.uri != styleURI {
            mapView.style.uri = styleURI
        }

        /// The coordinator needs to manager annotations because
        /// they need to be applied *after* `.mapLoaded`
        context.coordinator.annotations = annotations
    }
}

/// Here's our custom `Coordinator` implementation.
@available(iOS 13.0, *)
internal class SwiftUIMapViewCoordinator {
    /// It holds a binding to the camera
    @Binding private var camera: Camera

    /// It also has a setter for annotations. When the annotations
    /// are set, it synchronizes them to the map
    var annotations = [Annotation]() {
        didSet {
            syncAnnotations()
        }
    }

    /// This `mapView` property needs to be weak because
    /// the map view takes a strong reference to the coordinator
    /// when we make the coordinator observe the `.cameraChanged`
    /// event
    weak var mapView: MapView? {
        didSet {
            /// The coordinator observes the `.cameraChanged` event, and
            /// whenever the camera changes, it updates the camera binding
            mapView?.mapboxMap.on(.cameraChanged, handler: notify(for:))

            /// The coordinator also observes the `.mapLoaded` event
            /// so that it can sync annotations whenever the map reloads
            mapView?.mapboxMap.on(.mapLoaded, handler: notify(for:))
        }
    }

    init(camera: Binding<Camera>) {
        _camera = camera
    }

    func notify(for event: Event) -> Bool {
        guard let typedEvent = MapEvents.EventKind(rawValue: event.type),
              let mapView = mapView else {
            return true
        }
        switch typedEvent {
        /// As the camera changes, we update the binding. SwiftUI
        /// will propagate this change to any other UI elements connected
        /// to the same binding.
        case .cameraChanged:
            camera.center = mapView.cameraState.center
            camera.zoom = mapView.cameraState.zoom

        /// When the map reloads, we need to re-sync the annotations
        case .mapLoaded:
            initialMapLoadComplete = true
            syncAnnotations()

        default:
            break
        }
        return true
    }

    /// Only sync annotations once the map's initial load is complete
    private var initialMapLoadComplete = false

    /// To sync annotations, we use the annotations' identifiers to determine which
    /// annotations need to be added and which ones need to be removed.
    private func syncAnnotations() {
        guard let mapView = mapView, initialMapLoadComplete else {
            return
        }
        let annotationsByIdentifier = Dictionary(uniqueKeysWithValues: annotations.map { ($0.identifier, $0) })

        let oldAnnotationIds = Set(mapView.annotations.annotations.values.map(\.identifier))
        let newAnnotationIds = Set(annotationsByIdentifier.values.map(\.identifier))

        let idsForAnnotationsToRemove = oldAnnotationIds.subtracting(newAnnotationIds)
        let annotationsToRemove = idsForAnnotationsToRemove.compactMap { mapView.annotations.annotations[$0] }
        if !annotationsToRemove.isEmpty {
            mapView.annotations.removeAnnotations(annotationsToRemove)
        }

        let idsForAnnotationsToAdd = newAnnotationIds.subtracting(oldAnnotationIds)
        let annotationsToAdd = idsForAnnotationsToAdd.compactMap { annotationsByIdentifier[$0] }
        if !annotationsToAdd.isEmpty {
            mapView.annotations.addAnnotations(annotationsToAdd)
        }
    }
}

/// Here's an example usage of `SwiftUIMapView`
@available(iOS 13.0, *)
internal struct ContentView: View {

    /// For demonstration purposes, this view has its own state for the camera and style URL.
    /// In your app, these values could be constants defined directly in `body` or could come
    /// from a model object.
    @State private var camera = Camera(center: CLLocationCoordinate2D(latitude: 40, longitude: -75), zoom: 14)
    @State private var styleURI = StyleURI.streets

    /// Each time you create an annotation, it is assigned a UUID. For this reason, it's not a great
    /// idea to actually create annotations inside of `body` which may be called repeatedly
    @State private var annotations = [
        PointAnnotation(coordinate: CLLocationCoordinate2D(latitude: 40, longitude: -75)),
        PointAnnotation(coordinate: CLLocationCoordinate2D(latitude: 40, longitude: -75.001)),
        PointAnnotation(coordinate: CLLocationCoordinate2D(latitude: 40, longitude: -74.999))
    ]

    public var body: some View {
        VStack {
            SwiftUIMapView(
                mapInitOptions: MapInitOptions(),

                /// Here, we pass the camera state variable into `SwiftUIMapView` as a binding
                camera: $camera)

                /// Here's an example usage of the builder method to set `styleURI`.
                /// Note that in this case, we just need the current value, so we write
                /// `styleURI`, not `$styleURI`
                .styleURI(styleURI)

                /// Since these methods use the builder pattern, we can chain them together
                .annotations(annotations)

            /// We configure the slider to bind to the camera's zoom. Adjusting the slider with
            /// change the zoom on the map, and changing the zoom by interacting with the map
            /// will change the slider. Here's the data flow:
            ///
            /// Slider to Map:
            ///     - User interacts with the slider
            ///     - Slider updates the camera binding's zoom value
            ///     - SwiftUI invokes `updateUIView(_:context:)` on `SwiftUIMapView`
            ///     - `SwiftUIMapView` reads the updated camera zoom value and sets it on the underlying `MapView`
            ///
            /// Map to Slider:
            ///     - User interacts with the map, adjusting the zoom
            ///     - Map sends the `.cameraChanged` event, which is observed by the coordinator
            ///     - The coordinator updates the value of the zoom on the `camera` binding
            ///     - SwiftUI updates the Slider accordingly
            Slider(value: $camera.zoom, in: 0...20)

            /// The picker is bound to `styleURI`.
            Picker(selection: $styleURI, label: Text("Map Style")) {
                Text("Streets").tag(StyleURI.streets)
                Text("Dark").tag(StyleURI.dark)
            }.pickerStyle(SegmentedPickerStyle())
        }
    }
}

/// The rest of this example is just some boilerplate to present the ContentView and show the example
@objc(SwiftUIExample)
internal class SwiftUIExample: UIViewController, ExampleProtocol {

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupHostingController()
    }

    internal func setupHostingController() {
        if #available(iOS 13.0, *) {
            let hostingViewController = UIHostingController(rootView: ContentView())
            addChild(hostingViewController)
            hostingViewController.view.frame = view.frame
            view.addSubview(hostingViewController.view)
            hostingViewController.didMove(toParent: self)
        } else {
            // Fallback on earlier versions
            let label = UILabel()
            label.text = "This example runs on iOS 13+"
            label.font = UIFont.systemFont(ofSize: 20)
            label.textColor = .white
            label.sizeToFit()
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            NSLayoutConstraint.activate([
                view.centerXAnchor.constraint(equalTo: label.centerXAnchor),
                view.centerYAnchor.constraint(equalTo: label.centerYAnchor)
            ])
        }
    }
}
