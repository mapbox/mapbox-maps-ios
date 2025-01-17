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
///
/// - Note: `ForEvery` is similar to SwiftUI `ForEach`, but works with ``MapContent``.
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

    init(data: Data, content: @escaping (Data.Element) -> Content) where Data.Element: Identifiable, ID == Data.Element.ID {
        self.init(data: data, id: \.id, content: content)
    }

    func forEach(handler: (ID, Content) -> Void) {
        for item in data {
            handler(item[keyPath: id], content(item))
        }
    }
}

extension ForEvery: MapContent, PrimitiveMapContent where Content: MapContent {
    /// Creates instance that identified data by given key path.
    ///
    /// It’s important that the id of a data element doesn’t change, unless the data element has been replaced with a new data element that has a new identity.
    /// If two elements with the same id are passed, the behavior not guaranteed.
    public init(_ data: Data, id: KeyPath<Data.Element, ID>, @MapContentBuilder content: @escaping (Data.Element) -> Content) {
        self.init(data: data, id: id, content: content)
    }

    /// Creates instance that uses identifiable data.
    public init(_ data: Data, @MapContentBuilder content: @escaping (Data.Element) -> Content) where Data.Element: Identifiable, Data.Element.ID == ID {
        self.init(data: data, content: content)
    }

    func visit(_ node: MapContentNode) {
        node.updateChildren(with: self)
    }
}
