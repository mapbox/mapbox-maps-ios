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
    @_documentation(visibility: public)
@_spi(Experimental)
@available(iOS 13.0, *)
public struct ForEvery<Content, Data: RandomAccessCollection, ID: Hashable> {
    /// The collection of underlying identified data that is used to create views dynamically.
    var data: Data
    var id: KeyPath<Data.Element, ID>
    var content: (Data.Element) -> Content

    init(data: Data, id: KeyPath<Data.Element, ID>, content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.content = content
        self.id = id
    }

    @available(iOS 13.0, *)
    init(data: Data, content: @escaping (Data.Element) -> Content) where Data.Element: Identifiable, ID == Data.Element.ID {
        self.init(data: data, id: \.id, content: content)
    }

    func forEach(handler: (ID, Content) -> Void) {
        for item in data {
            handler(item[keyPath: id], content(item))
        }
    }
}

@available(iOS 13.0, *)
extension ForEvery: MapContent, PrimitiveMapContent where Content: MapContent {
    /// Creates instance that identified data by given key path.
    @_documentation(visibility: public)
    public init(_ data: Data, id: KeyPath<Data.Element, ID>, @MapContentBuilder content: @escaping (Data.Element) -> Content) {
        self.init(data: data, id: id, content: content)
    }

    /// Creates instance that uses identifiable data.
    @_documentation(visibility: public)
    @available(iOS 13.0, *)
    public init(_ data: Data, @MapContentBuilder content: @escaping (Data.Element) -> Content) where Data.Element: Identifiable, Data.Element.ID == ID {
        self.init(data: data, content: content)
    }

    func visit(_ node: MapContentNode) {
        node.updateChildren(with: self)
    }
}
