/// A structure that computes map content from an underlying collection of identified data.
@_spi(Experimental)
public struct ForEvery<Data: RandomAccessCollection, ID: Hashable>: MapContent {
    /// The collection of underlying identified data that is used to create views dynamically.
    var data: Data
    var idGenerator: (Data.Element) -> ID
    var content: (Data.Element) -> MapContent

    @available(iOS 13.0, *)
    public init(_ data: Data, @MapContentBuilder content: @escaping (Data.Element) -> MapContent) where Data.Element: Identifiable, Data.Element.ID == ID {
        self.init(data, id: \.id, content: content)
    }

    public init(_ data: Data, id: KeyPath<Data.Element, ID>, @MapContentBuilder content: @escaping (Data.Element) -> MapContent) {
        self.data = data
        self.content = content
        idGenerator = { $0[keyPath: id] }
    }

    func _visit(_ visitor: MapContentVisitor) {
        for item in data {
            let id = idGenerator(item)
            visitor.push(id)
            content(item).visit(visitor)
            visitor.pop()
        }
    }
}

extension ForEvery: PrimitiveMapContent {}
