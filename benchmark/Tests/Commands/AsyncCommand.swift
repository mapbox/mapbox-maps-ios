import Foundation
import MapboxMaps

class Context {
    var cancellables: Set<AnyCancelable> = []
    var mapView: MapView!
}

protocol AsyncCommand {
    func execute(context: Context) async throws
    func cleanup(context: Context)
}

extension AsyncCommand {
    func cleanup(context: Context) { }
}
