import Foundation

struct AttributionMenuContent {
    var title: String
    var sections: [AttributionMenuSection]
    var open: (URL) -> Void

    var allItems: [AttributionMenuItem] { sections.flatMap(\.items) }

    /// Also drops sections left empty.
    mutating func filter(_ isIncluded: (AttributionMenuItem) -> Bool) {
        sections = sections.compactMap { section in
            var section = section
            section.items = section.items.filter(isIncluded)
            return section.items.isEmpty ? nil : section
        }
    }
}

struct AttributionMenuSection: Hashable {
    var title: String?
    var items: [AttributionMenuItem]
}
