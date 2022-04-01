import UIKit
import MapboxMaps
import SwiftUI

struct Camera {
    var center: CLLocationCoordinate2D
    var zoom: CGFloat
}

/// `SwiftUIMapView` is a SwiftUI wrapper around UIKit-based `MapView`.
/// It works by conforming to the `UIViewRepresentable` protocol. When
/// your app uses `SwiftUIMapView`, SwiftUI creates and manages a
/// single instance of `MapView` behind the scenes so that if your map
/// configuration changes, the underlying map view doesn't need to be recreated.
@available(iOS 13.0, *)
struct SwiftUIMapView: UIViewRepresentable {

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
    private var annotations = [PointAnnotation]()

    func annotations(_ annotations: [PointAnnotation]) -> Self {
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

        /// Additionally, this is your opportunity to connect the coordinator to the map view. In this example
        /// the coordinator is given a reference to the map view. It uses the reference to set up the necessary
        /// observations so that it can respond to map events. It also creates an annotation manager.
        context.coordinator.mapView = mapView

        updateUIView(mapView, context: context)

        return mapView
    }

    /// If your `SwiftUIMapView` is reconfigured externally, SwiftUI will invoke `updateUIView(_:context:)`
    /// to give you an opportunity to re-sync the state of the underlying map view.
    func updateUIView(_ mapView: MapView, context: Context) {
        /// When setting the camera, we need to temporarily disable the coordinator's observers.
        /// If we didn't do this, the SwiftUI state would be modified during view update, which
        /// causes undefined behavior.
        context.coordinator.performWithoutObservation {
            mapView.mapboxMap.setCamera(to: CameraOptions(center: camera.center, zoom: camera.zoom))
        }
        /// Since setting the style causes some reloading to happen,
        /// we only call the setter if the value has changed.
        if mapView.mapboxMap.style.uri != styleURI {
            mapView.mapboxMap.style.uri = styleURI
        }

        /// The coordinator exposes the annotation manager so that we can sync the annotations
        context.coordinator.pointAnnotationManager.annotations = annotations
    }
}

/// Here's our custom `Coordinator` implementation.
@available(iOS 13.0, *)
final class SwiftUIMapViewCoordinator {
    /// It holds a binding to the camera
    @Binding private var camera: Camera

    /// It exposes the annotation manager
    private(set) var pointAnnotationManager: PointAnnotationManager!

    var mapView: MapView! {
        didSet {
            cancelable?.cancel()
            cancelable = nil

            /// In the following observations, `self` is captured as an unowned reference to avoid a strong
            /// reference cycle from mapView --> mapboxMap --> handler block --> self --> mapView.
            /// In this situation, weak is unnecessary because the subscription will be canceled via the returned
            /// `Cancelable` as soon as `self` is deinitialized.

            /// The coordinator observes the `.cameraChanged` event, and
            /// whenever the camera changes, it updates the camera binding.
            cancelable = mapView.mapboxMap.onEvery(.cameraChanged) { [unowned self] (event) in
                notify(for: event)
            }

            pointAnnotationManager = mapView.annotations.makePointAnnotationManager()
        }
    }

    private var cancelable: Cancelable?

    init(camera: Binding<Camera>) {
        _camera = camera
    }

    deinit {
        cancelable?.cancel()
    }

    private var ignoreNotifications = false

    func performWithoutObservation(_ block: () -> Void) {
        ignoreNotifications = true
        block()
        ignoreNotifications = false
    }

    private func notify(for event: Event) {
        guard !ignoreNotifications else {
            return
        }
        switch MapEvents.EventKind(rawValue: event.type) {
        /// As the camera changes, we update the binding. SwiftUI
        /// will propagate this change to any other UI elements connected
        /// to the same binding.
        case .cameraChanged:
            camera.center = mapView.cameraState.center
            camera.zoom = mapView.cameraState.zoom
        default:
            break
        }
    }
}

/// Here's an example usage of `SwiftUIMapView`
@available(iOS 13.0, *)
struct ContentView: View {

    /// For demonstration purposes, this view has its own state for the camera and style URL.
    /// In your app, these values could be constants defined directly in `body` or could come
    /// from a model object.
    @State private var camera = Camera(center: CLLocationCoordinate2D(latitude: 40, longitude: -75), zoom: 14)
    @State private var styleURI = StyleURI.streets

    private var onAppear: () -> Void

    init(onAppear: @escaping () -> Void) {
        self.onAppear = onAppear
    }

    /// When you create an annotation, you can assign it an ID or allow it to generate its own UUID. Here
    /// we assign IDs explicitly to achieve a consistent result whenever this view is reevaluated.
    private let annotations: [PointAnnotation] = [
        CLLocationCoordinate2D(latitude: 40, longitude: -75),
        CLLocationCoordinate2D(latitude: 40, longitude: -75.001),
        CLLocationCoordinate2D(latitude: 40, longitude: -74.999)]
        .enumerated()
        .map { (idx, coordinate) in
            var annotation = PointAnnotation(id: idx.description, coordinate: coordinate)
            annotation.image = .init(image: UIImage(named: "custom_marker")!, name: "custom_marker")
            return annotation
        }

    var body: some View {
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
        }.onAppear(perform: onAppear)
    }
}

/// The rest of this example is just some boilerplate to present the ContentView and show the example
@objc(SwiftUIExample)
final class SwiftUIExample: UIViewController, ExampleProtocol {

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13.0, *) {
            let contentView = ContentView { [weak self] in
                // The following line is just for testing purposes.
                self?.finish()
            }
            let hostingViewController = UIHostingController(rootView: contentView)
            addChild(hostingViewController)
            hostingViewController.view.frame = view.bounds
            view.addSubview(hostingViewController.view)
            hostingViewController.didMove(toParent: self)
        } else {
            // Fallback on earlier versions
            let label = UILabel()
            label.text = "This example runs on iOS 13+"
            label.font = .systemFont(ofSize: 20)
            label.textColor = .white
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            NSLayoutConstraint.activate([
                view.centerXAnchor.constraint(equalTo: label.centerXAnchor),
                view.centerYAnchor.constraint(equalTo: label.centerYAnchor)
            ])
        }
    }
}
