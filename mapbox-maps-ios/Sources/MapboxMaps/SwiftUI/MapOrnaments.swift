protocol OrnamentsManaging: AnyObject {
    var options: OrnamentOptions { get set }
}

extension OrnamentsManager: OrnamentsManaging {}
