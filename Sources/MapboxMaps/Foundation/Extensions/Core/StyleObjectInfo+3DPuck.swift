import Foundation
@_implementationOnly import MapboxCoreMaps_Private

internal extension StyleObjectInfo {
    var is3DPuckLayer: Bool { type == "model" && id == Puck3D.layerID }
}
