protocol PrimitiveMapContent {
    func visit(_ node: MapContentNode)
}

extension PrimitiveMapContent {
    /// :nodoc:
    public var body: Never { fatalError("shouldn't be called") }
}

extension Never: MapStyleContent {
   public var body: Never { fatalError("shouldn't be called") }
}

extension Never: MapContent {
   public var content: Never { fatalError("shouldn't be called") }
}
