protocol PuckRenderer: AnyObject {
    associatedtype Configuration: Equatable
    var state: PuckRendererState<Configuration>? { get set }
}
