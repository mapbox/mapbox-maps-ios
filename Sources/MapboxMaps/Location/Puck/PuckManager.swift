import CoreLocation
import MapboxCoreMaps
import UIKit

final class PuckManager<Renderer2D: PuckRenderer, Renderer3D: PuckRenderer>
where Renderer2D.Configuration == Puck2DConfiguration, Renderer3D.Configuration == Puck3DConfiguration {
    var locationOptions: LocationOptions {
        get { locationOptionsSubject.value }
        set {
            locationOptionsSubject.value = newValue
            subscribeOnUpdates()
        }
    }

    private var renderer2D: Renderer2D?
    private var renderer3D: Renderer3D?

    private let make2DRenderer: () -> Renderer2D
    private let make3DRenderer: () -> Renderer3D

    private let onPuckRender: Signal<PuckRenderingData>
    private let locationOptionsSubject: CurrentValueSignalSubject<LocationOptions>
    private var cancellables = Set<AnyCancelable>()

    init(
        locationOptionsSubject: CurrentValueSignalSubject<LocationOptions>,
        onPuckRender: Signal<PuckRenderingData>,
        make2DRenderer: @escaping () -> Renderer2D,
        make3DRenderer: @escaping () -> Renderer3D
    ) {
        self.locationOptionsSubject = locationOptionsSubject
        self.onPuckRender = onPuckRender
        self.make2DRenderer = make2DRenderer
        self.make3DRenderer = make3DRenderer
    }

    private func subscribeOnUpdates() {
        guard cancellables.isEmpty else { return }

        Signal.combineLatest(
            onPuckRender.skipRepeats(),
            locationOptionsSubject.signal.skipRepeats()
        )
        .observe { [weak self] (data, locationOptions) in
            self?.startRendering(data: data, locationOptions: locationOptions)
        }
        .store(in: &cancellables)
    }

    private func startRendering(
        data: PuckRenderingData,
        locationOptions: LocationOptions
    ) {
        switch locationOptions.puckType {
        case .none:
            stopRendering()
            cancellables.removeAll()

        case let .puck2D(configuration):
            if renderer3D != nil {
                stopRendering()
            }

            if renderer2D == nil {
                renderer2D = make2DRenderer()
            }

            renderer2D?.state = PuckRendererState(
                data: data,
                bearingEnabled: locationOptions.puckBearingEnabled,
                bearingType: locationOptions.puckBearing,
                configuration: configuration
            )

        case let .puck3D(configuration):
            if renderer2D != nil {
                stopRendering()
            }

            if renderer3D == nil {
                renderer3D = make3DRenderer()
            }

            renderer3D?.state = PuckRendererState(
                data: data,
                bearingEnabled: locationOptions.puckBearingEnabled,
                bearingType: locationOptions.puckBearing,
                configuration: configuration
            )
        }
    }

    private func stopRendering() {
        renderer2D?.state = nil
        renderer2D = nil
        renderer3D?.state = nil
        renderer3D = nil
    }
}
