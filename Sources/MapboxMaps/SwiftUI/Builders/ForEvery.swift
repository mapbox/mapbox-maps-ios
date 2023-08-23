/// A structure that creates map content from an underlying collection of identified data.
///
/// Use `ForEvery` to create ``MapContent`` such as annotations from the identified data.
///
/// ```swift
/// private struct Place: Identifiable {
///     let name: String
///     let coordinate: CLLocationCoordinate
///     var id: String { name }
/// }
///
/// private let places = [
///     Place(name: "Castle", coordinate: CLLocationCoordinate2D(...)),
///     Place(name: "Lake", coordinate: CLLocationCoordinate2D(...))
/// ]
///
/// var body: some View {
///     Map {
///       ForEvery(places) { place in
///         ViewAnnotation(place.coordinate) {
///             Image(named: place.name)
///         }
///       }
///     }
/// }
/// ```
///
/// - Note: `ForEvery` is similar to SwiftUI `ForEach`, but works with ``MapContent``.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
@_spi(Experimental)
public struct ForEvery<Data: RandomAccessCollection, ID: Hashable>: MapContent {
    /// The collection of underlying identified data that is used to create views dynamically.
    var data: Data
    var idGenerator: (Data.Element) -> ID
    var content: (Data.Element) -> MapContent

    /// Creates instance that uses identifiable data.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    @available(iOS 13.0, *)
    public init(_ data: Data, @MapContentBuilder content: @escaping (Data.Element) -> MapContent) where Data.Element: Identifiable, Data.Element.ID == ID {
        self.init(data, id: \.id, content: content)
    }

    /// Creates instance that identified data by given key path.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
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
