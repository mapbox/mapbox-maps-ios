import Foundation

public struct RenderFrameFinishedPayload: Decodable {
    public let renderMode: RenderMode
    public let needsRepaint: Bool
    public let placementChanged: Bool
}

public enum RenderMode: String, Decodable {
    case partial
    case full
}
