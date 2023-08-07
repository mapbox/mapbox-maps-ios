/// A structure that computes map content from an underlying collection of identified data.
@_spi(Experimental)
public struct ForEvery<Data: RandomAccessCollection, ID: Hashable, Content: MapContent>: MapContent {
    /// The collection of underlying identified data that is used to create views dynamically.
    var data: Data
    var idGenerator: (Data.Element) -> ID
    var content: (Data.Element) -> Content

    @available(iOS 13.0, *)
    public init(_ data: Data, content: @escaping (Data.Element) -> Content) where Data.Element: Identifiable, Data.Element.ID == ID {
        self.init(data, id: \.id, content: content)
    }

    public init(_ data: Data, id: KeyPath<Data.Element, ID>, content: @escaping (Data.Element) -> Content) where ID: Hashable {
        self.data = data
        self.content = content
        idGenerator = { $0[keyPath: id] }
    }

    public func _visit(_ visitor: _MapContentVisitor) {
        for item in data {
            let id = idGenerator(item)
            visitor.push(id)
            content(item)._visit(visitor)
            visitor.pop()
        }
    }
}
