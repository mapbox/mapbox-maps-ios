import CoreLocation
import MapboxCoreMaps
import UIKit

final class PuckManager {
    private var renderer: PuckRenderer? {
        didSet {
            oldValue?.state = nil
            if renderer == nil { stop() }
        }
    }

    private var state: PuckRendererState? {
        didSet {
            render(newState: state, oldState: oldValue)
        }
    }

    private let onPuckRenderState: Signal<PuckRendererState>
    private let make2DRenderer: () -> PuckRenderer
    private let make3DRenderer: () -> PuckRenderer
    private var cancellables = Set<AnyCancelable>()

    init(
        onPuckRenderState: Signal<PuckRendererState>,
        make2DRenderer: @escaping () -> PuckRenderer,
        make3DRenderer: @escaping () -> PuckRenderer
    ) {
        self.onPuckRenderState = onPuckRenderState
        self.make2DRenderer = make2DRenderer
        self.make3DRenderer = make3DRenderer
    }

    func start() {
        guard cancellables.isEmpty else { return }

        onPuckRenderState
            .skipRepeats()
            .observe { [weak self] newState in self?.state = newState }
            .store(in: &cancellables)
    }

    func stop() {
        cancellables.removeAll()
    }

    private func render(newState: PuckRendererState?, oldState: PuckRendererState?) {
        switch (newState?.locationOptions.puckType, oldState?.locationOptions.puckType) {
        case (.puck2D, .puck3D), (.puck3D, .puck2D), (_, .none), (.none, _):
            renderer = makeRenderer(with: newState)
        case (.puck2D, .puck2D), (.puck3D, .puck3D):
            break
        }

        renderer?.state = newState
    }

    private func makeRenderer(with options: PuckRendererState?) -> PuckRenderer? {
        switch options?.locationOptions.puckType {
        case .puck2D:
            return make2DRenderer()
        case .puck3D:
            return make3DRenderer()
        case .none:
            return nil
        }
    }
}
