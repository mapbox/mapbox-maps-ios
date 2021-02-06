import UIKit
import MapboxMaps
import Turf
import SwiftUI

internal struct Camera {
    var center: CLLocationCoordinate2D
    var zoom: CGFloat
}

internal struct SwiftUIMapView: UIViewRepresentable {

    private let resourceOptions: ResourceOptions

    // Use @Bindings for map values that can change as a result of user interaction
    @Binding private var camera: Camera

    init(resourceOptions: ResourceOptions, camera: Binding<Camera>) {
        self.resourceOptions = resourceOptions
        self._camera = camera
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(camera: $camera)
    }

    // MARK: - UIViewRepresentable required methods
    func makeUIView(context: UIViewRepresentableContext<SwiftUIMapView>) -> MapboxMaps.MapView {
        // Create the map and synchronize its initial state
        let mapView = MapView(with: .zero, resourceOptions: resourceOptions)
        updateUIView(mapView, context: context)

        // Configure the coordinator to be able to observe and synchronize camera changes
        context.coordinator.mapView = mapView
        mapView.on(.cameraDidChange, handler: context.coordinator.notify(for:))
        return mapView
    }

    func updateUIView(_ mapView: MapView, context: Context) {
        mapView.cameraManager.setCamera(centerCoordinate: camera.center,
                                        zoom: camera.zoom,
                                        animated: false)
        mapView.style.styleURL = styleURL
    }

    // Use vars for values and setter funcs for map attributes that only change as a result of
    // some other part of the program.
    private var styleURL = StyleURL.streets

    func styleURL(_ styleURL: StyleURL) -> Self {
        var updated = self
        updated.styleURL = styleURL
        return updated
    }

    class Coordinator: Observer {
        var peer: MBXPeerWrapper?

        @Binding var camera: Camera

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
            case .cameraDidChange:
                camera.center = mapView.centerCoordinate
                camera.zoom = mapView.zoom
            default:
                break
            }
        }
    }
}

internal struct ContentView: View {

    @State var camera = Camera(center: CLLocationCoordinate2D(latitude: 40, longitude: -75), zoom: 14)
    @State var styleURL = StyleURL.streets

    public var body: some View {
        VStack {
            SwiftUIMapView(
                resourceOptions: ResourceOptions(accessToken: AccountManager.shared.accessToken!),
                camera: $camera)
                .styleURL(styleURL)
            Slider(value: $camera.zoom, in: 0...20)
            Picker(selection: $styleURL, label: Text("Map Style")) {
                Text("Streets").tag(StyleURL.streets)
                Text("Dark").tag(StyleURL.dark)
            }.pickerStyle(SegmentedPickerStyle())
        }
    }
}

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
