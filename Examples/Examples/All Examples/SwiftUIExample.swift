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
    /// For example, with `styleURL`, you might say
    private var styleURL = StyleURL.streets

    /// This is the builder-style method for setting `styleURL`.
    /// It returns an updated `SwiftUIMapView` value that
    /// has the specified `styleURL`. This approach allows you
    /// to chain these customizers — a common pattern in SwiftUI.
    func styleURL(_ styleURL: StyleURL) -> Self {
        var updated = self
        updated.styleURL = styleURL
        return updated
    }

    /// Here's a property and builder method for annotations
    private var annotations = [Annotation]()

    func annotations(_ annotations: [Annotation]) -> Self {
        var updated = self
        updated.annotations = annotations
        return updated
    }

    /// Unlike `styleURL`, there's no good default value for `resourceOptions`
    /// because it's the value that contains your Mapbox access token. For that reason,
    /// it's declared here as a `let` and is a required parameter in the initializer.
    private let resourceOptions: ResourceOptions

    init(resourceOptions: ResourceOptions, camera: Binding<Camera>) {
        self.resourceOptions = resourceOptions
        self._camera = camera
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
    /// with the current settings of `SwiftUIMapView` (in this example, just the `camera` and `styleURL`).
    func makeUIView(context: UIViewRepresentableContext<SwiftUIMapView>) -> MapView {
        let mapView = MapView(with: .zero, resourceOptions: resourceOptions)
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
        mapView.cameraManager.setCamera(centerCoordinate: camera.center,
                                        zoom: camera.zoom,
                                        animated: false)
        /// Since changing the style causes annotations to be removed from the map
        /// we only call the setter if the value has changed.
        if mapView.style.styleURL != styleURL {
            mapView.style.styleURL = styleURL
        }

        /// The coordinator needs to manager annotations because
        /// they need to be applied *after* `.mapLoadingFinished`
        context.coordinator.annotations = annotations
    }
}

/// Here's our custom `Coordinator` implementation.
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
    /// when we make the coordinator observe the `.cameraDidChange`
    /// event
    weak var mapView: MapView? {
        didSet {
            /// The coordinator observes the `.cameraDidChange` event, and
            /// whenever the camera changes, it updates the camera binding
            mapView?.on(.cameraDidChange, handler: notify(for:))

            /// The coordinator also observes the `.mapLoadingFinished` event
            /// so that it can sync annotations whenever the map reloads
            mapView?.on(.mapLoadingFinished, handler: notify(for:))
        }
    }

    init(camera: Binding<Camera>) {
        _camera = camera
    }

    func notify(for event: Event) {
        guard let typedEvent = MapEvents.EventKind(rawValue: event.type),
              let mapView = mapView else {
            return
        }
        switch typedEvent {
        /// As the camera changes, we update the binding. SwiftUI
        /// will propagate this change to any other UI elements connected
        /// to the same binding.
        case .cameraDidChange:
            camera.center = mapView.centerCoordinate
            camera.zoom = mapView.zoom

        /// When the map reloads, we need to re-sync the annotations
        case .mapLoadingFinished:
            initialMapLoadComplete = true
            syncAnnotations()

        default:
            break
        }
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

        let oldAnnotationIds = Set(mapView.annotationManager.annotations.values.map(\.identifier))
        let newAnnotationIds = Set(annotationsByIdentifier.values.map(\.identifier))

        let idsForAnnotationsToRemove = oldAnnotationIds.subtracting(newAnnotationIds)
        let annotationsToRemove = idsForAnnotationsToRemove.compactMap { mapView.annotationManager.annotations[$0] }
        if !annotationsToRemove.isEmpty {
            mapView.annotationManager.removeAnnotations(annotationsToRemove)
        }

        let idsForAnnotationsToAdd = newAnnotationIds.subtracting(oldAnnotationIds)
        let annotationsToAdd = idsForAnnotationsToAdd.compactMap { annotationsByIdentifier[$0] }
        if !annotationsToAdd.isEmpty {
            mapView.annotationManager.addAnnotations(annotationsToAdd)
        }
    }
}

/// Here's an example usage of `SwiftUIMapView`
internal struct ContentView: View {

    /// For demonstration purposes, this view has its own state for the camera and style URL.
    /// In your app, these values could be constants defined directly in `body` or could come
    /// from a model object.
    @State private var camera = Camera(center: CLLocationCoordinate2D(latitude: 40, longitude: -75), zoom: 14)
    @State private var styleURL = StyleURL.streets

    /// Each time you create an annotation, it is assigned a UUID. For this reason, it's not a great
    /// idea to actually create annotations inside of `body` which may be called repeatedly
    @State private var annotations = [
        PointAnnotation(coordinate: CLLocationCoordinate2D(latitude: 40, longitude: -75)),
        PointAnnotation(coordinate: CLLocationCoordinate2D(latitude: 40, longitude: -75.001)),
        PointAnnotation(coordinate: CLLocationCoordinate2D(latitude: 40, longitude: -74.999))]

    public var body: some View {
        VStack {
            SwiftUIMapView(
                resourceOptions: ResourceOptions(accessToken: AccountManager.shared.accessToken!),

                /// Here, we pass the camera state variable into `SwiftUIMapView` as a binding
                camera: $camera)

                /// Here's an example usage of the builder method to set `styleURL`.
                /// Note that in this case, we just need the current value, so we write
                /// `styleURL`, not `$styleURL`
                .styleURL(styleURL)

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
            ///     - Map sends the `.cameraDidChange` event, which is observed by the coordinator
            ///     - The coordinator updates the value of the zoom on the `camera` binding
            ///     - SwiftUI updates the Slider accordingly
            Slider(value: $camera.zoom, in: 0...20)

            /// The picker is bound to `styleURL`.
            Picker(selection: $styleURL, label: Text("Map Style")) {
                Text("Streets").tag(StyleURL.streets)
                Text("Dark").tag(StyleURL.dark)
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
        let hostingViewController = UIHostingController(rootView: ContentView())
        addChild(hostingViewController)
        hostingViewController.view.frame = view.frame
        view.addSubview(hostingViewController.view)
        hostingViewController.didMove(toParent: self)
    }
}
