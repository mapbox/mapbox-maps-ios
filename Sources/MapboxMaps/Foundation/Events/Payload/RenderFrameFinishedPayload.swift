import Foundation

public struct RenderFrameFinishedPayload {
    public let renderMode: RenderMode
    public let needsRepaint: Bool
    public let placementChanged: Bool
}

extension RenderFrameFinishedPayload: Decodable {
    enum CodingKeys: String, CodingKey {
        case renderMode = "render-mode"
        case needsRepaint = "needs-repaint"
        case placementChanged = "placement-changed"
    }
}

public enum RenderMode: String, Decodable {
    case partial, full
}
