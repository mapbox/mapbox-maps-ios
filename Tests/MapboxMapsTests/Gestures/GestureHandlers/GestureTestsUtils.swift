import UIKit

extension UIGestureRecognizer {
    struct RecognizerType: OptionSet {
        let rawValue: Int
        static let longPress = RecognizerType(rawValue: 1 << 1)
        static let swipe = RecognizerType(rawValue: 1 << 2)
        static let tap = RecognizerType(rawValue: 1 << 3)
        static let screenEdge = RecognizerType(rawValue: 1 << 4)
        static let rotation = RecognizerType(rawValue: 1 << 5)
        static let pan = RecognizerType(rawValue: 1 << 6)
    }
    static func interruptingRecognizers(_ type: RecognizerType) -> Set<UIGestureRecognizer> {
        var result = Set<UIGestureRecognizer>()
        if type.contains(.longPress) { result.insert(UILongPressGestureRecognizer()) }
        if type.contains(.swipe) { result.insert(UISwipeGestureRecognizer()) }
        if type.contains(.tap) { result.insert(UITapGestureRecognizer()) }
#if !swift(>=5.9) && os(visionOS)
        if type.contains(.screenEdge) { result.insert(UIScreenEdgePanGestureRecognizer()) }
#endif
        if type.contains(.rotation) { result.insert(UIRotationGestureRecognizer()) }
        if type.contains(.pan) { result.insert(UIPanGestureRecognizer()) }
        return result
    }
}
