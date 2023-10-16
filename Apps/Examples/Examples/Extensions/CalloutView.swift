import SwiftUI
import MapboxMaps

@available(iOS 14.0, *)
extension View {
    func callout(anchor: ViewAnnotationAnchor, color: Color, tailSize: Double = 8.0) -> some View {
        modifier(CalloutViewModifier(anchor: anchor, color: color, tailSize: tailSize))
    }
}

@available(iOS 14.0, *)
struct CalloutViewModifier: ViewModifier {
    var anchor: ViewAnnotationAnchor
    var color: Color
    var tailSize: Double

    func body(content: Content) -> some View {
        content
            .padding(tailSize)
            .background(
                CalloutShape(anchor: anchor,
                             tailSize: tailSize,
                             cornerRadius: tailSize)
                .fill(color)
                .shadow(radius: 1.4, y: 0.7))
    }
}

@available(iOS 14.0, *)
struct CalloutShape: Shape {
    var anchor: ViewAnnotationAnchor
    var tailSize: CGFloat
    var cornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath.calloutPath(size: rect.size, tailSize: tailSize, cornerRadius: cornerRadius, anchor: anchor)
        return Path(path.cgPath)
    }
}

extension UIBezierPath {
    static func calloutPath(size: CGSize, tailSize: CGFloat, cornerRadius: CGFloat, anchor: ViewAnnotationAnchor) -> UIBezierPath {
        let rect = CGRect(origin: .init(x: 0, y: 0), size: size)
        let bubbleRect = rect.insetBy(dx: tailSize, dy: tailSize)

        let path = UIBezierPath(roundedRect: bubbleRect,
                                cornerRadius: cornerRadius)

        let tailPath = UIBezierPath()
        let p = tailSize
        let h = size.height
        let w = size.width
        let r = cornerRadius
        let tailPoints: [CGPoint]
        switch anchor {
        case .topLeft:
            tailPoints = [CGPoint(x: 0, y: 0), CGPoint(x: (p + r), y: p), CGPoint(x: p, y: (p + r))]
        case .top:
            tailPoints = [CGPoint(x: w / 2, y: 0), CGPoint(x: w / 2 - p, y: p), CGPoint(x: w / 2 + p, y: p)]
        case .topRight:
            tailPoints = [CGPoint(x: w, y: 0), CGPoint(x: w - p, y: (p + r)), CGPoint(x: w - 3 * p, y: p)]
        case .bottomLeft:
            tailPoints = [CGPoint(x: 0, y: h), CGPoint(x: p, y: h - (p + r)), CGPoint(x: (p + r), y: h - p)]
        case .bottom:
            tailPoints = [CGPoint(x: w / 2, y: h), CGPoint(x: w / 2 - p, y: h - p), CGPoint(x: w / 2 + p, y: h - p)]
        case .bottomRight:
            tailPoints = [CGPoint(x: w, y: h), CGPoint(x: w - (p + r), y: h - p), CGPoint(x: w - p, y: h - (p + r))]
        case .left:
            tailPoints = [CGPoint(x: 0, y: h / 2), CGPoint(x: p, y: h / 2 - p), CGPoint(x: p, y: h / 2 + p)]
        case .right:
            tailPoints = [CGPoint(x: w, y: h / 2), CGPoint(x: w - p, y: h / 2 - p), CGPoint(x: w - p, y: h / 2 + p)]
        default:
            tailPoints = []
        }

        for (i, point) in tailPoints.enumerated() {
            if i == 0 {
                tailPath.move(to: point)
            } else {
                tailPath.addLine(to: point)
            }
        }
        tailPath.close()
        path.append(tailPath)
        return path
    }
}
