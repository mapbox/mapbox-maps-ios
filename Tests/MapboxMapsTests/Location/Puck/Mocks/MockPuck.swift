@testable import MapboxMaps

final class Mock2DPuckRenderer: PuckRenderer {
    @Stubbed var state: PuckRendererState<Puck2DConfiguration>?
}

final class Mock3DPuckRenderer: PuckRenderer {
    @Stubbed var state: PuckRendererState<Puck3DConfiguration>?
}
