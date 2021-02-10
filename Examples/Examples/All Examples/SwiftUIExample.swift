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
    func makeCoordinator() -> Coordinator {
        Coordinator(camera: $camera)
    }

    /// After SwiftUI creates the coordinator, it creates the underlying `UIView`, in this case a `MapView`.
    /// This method should create the `MapView`, and make sure that it is configured to be in sync
    /// with the current settings of `SwiftUIMapView` (in this example, just the `camera` and `styleURL`).
    func makeUIView(context: UIViewRepresentableContext<SwiftUIMapView>) -> MapView {
        let mapView = MapView(with: .zero, resourceOptions: resourceOptions)
        updateUIView(mapView, context: context)

        /// Additionally, this is your opportunity to connect the coordinator to the map view. In this example
        /// the coordinator is given a reference to the map view and is configured to observe the `.cameraDidChange`
        /// event. Whenever the camera changes, the coordinator will be able to update the camera binding
        /// that was provided to it when it was initialized.
        context.coordinator.mapView = mapView
        mapView.on(.cameraDidChange, handler: context.coordinator.notify(for:))

        return mapView
    }

    /// If your `SwiftUIMapView` is reconfigured externally, SwiftUI will invoke `updateUIView(_:context:)`
    /// to give you an opportunity to re-sync the state of the underlying map view.
    func updateUIView(_ mapView: MapView, context: Context) {
        mapView.cameraManager.setCamera(centerCoordinate: camera.center,
                                        zoom: camera.zoom,
                                        animated: false)
        mapView.style.styleURL = styleURL
    }

    /// Here's our custom `Coordinator` implementation.
    class Coordinator {
        @Binding var camera: Camera

        /// This `mapView` property needs to be weak because
        /// the map view takes a strong reference to the coordiantor
        /// when we make the coordinator observe the `.cameraDidChange`
        /// event
        weak var mapView: MapView?

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
            default:
                break
            }
        }
    }
}

/// Here's an example usasge of `SwiftUIMapView`
internal struct ContentView: View {

    /// For demonstration purposes, this view has its own state for the camera and style URL.
    /// In your app, these values could be constants defined directly in `body` or could come
    /// from a model object.
    @State var camera = Camera(center: CLLocationCoordinate2D(latitude: 40, longitude: -75), zoom: 14)
    @State var styleURL = StyleURL.streets

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
