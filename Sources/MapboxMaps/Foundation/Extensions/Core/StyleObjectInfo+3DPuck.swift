import Foundation

internal extension StyleObjectInfo {
    var is3DPuckLayer: Bool { type == "model" && id == Puck3DRenderer.layerID }
}
