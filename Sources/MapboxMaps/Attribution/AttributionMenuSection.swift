import Foundation
import UIKit

indirect enum AttributionMenuElement {
    case section(AttributionMenuSection)
    case item(AttributionMenuItem)
}

internal struct AttributionMenuSection {
    var title: String
    var actionTitle: String?
    var subtitle: String?
    var category: AttributionMenuItem.Category
    var elements: [AttributionMenuElement]

    init(title: String, actionTitle: String? = nil, subtitle: String? = nil, category: AttributionMenuItem.Category, elements: [AttributionMenuElement]) {
        self.title = title
        self.actionTitle = actionTitle
        self.subtitle = subtitle
        self.category = category
        self.elements = elements
    }

    mutating func filter(_ filter: (AttributionMenuItem) -> Bool) {
        elements = elements.compactMap { element in
            switch element {
            case .item(let item):
                return filter(item) ? .item(item) : nil
            case .section(var section):
                section.filter(filter)
                return .section(section)
            }
        }
    }
}
