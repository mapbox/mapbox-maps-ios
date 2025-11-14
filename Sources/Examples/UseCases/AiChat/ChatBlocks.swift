import SwiftUI

struct ChatBlock: Identifiable {
    struct Message {
        var content: String
        var isUser: Bool
    }
    enum Content {
        case message(Message)
        case mapCards([Pin])
        case waiter

        var isWaiter: Bool {
            switch self {
            case .waiter:
                return true
            default:
                return false
            }
        }
    }
    var id = UUID()
    var content: Content
}

@available(iOS 17.0, *)
struct ChatBlockView: View {
    var block: ChatBlock

    var body: some View {
        switch block.content {
        case .mapCards(let mapCards):
            MapCardsView(cards: mapCards)
        case .message(let message):
            ChatBubble(message: message)
        case .waiter:
            WaiterView()
        }
    }
}

struct WaiterView: View {
    @State private var animationPhase = 0

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.gray.opacity(0.6))
                    .frame(width: 8, height: 8)
                    .scaleEffect(animationPhase == index ? 1.3 : 1.0)
                    .animation(
                        .easeInOut(duration: 0.6)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.2),
                        value: animationPhase
                    )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
        .onAppear {
            animationPhase = 1
        }
    }
}

struct ChatBubble: View {
    let message: ChatBlock.Message

    @State var selectedPin: UUID?

    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
            }

            VStack(alignment: message.isUser ? .trailing : .leading) {
                Text(message.content)
                    .padding(.horizontal, message.isUser ? 16 : 0)
                    .padding(.vertical, message.isUser ? 10 : 0)
                    .background(message.isUser ? Color(.systemGray5) : Color.clear)
                    .foregroundColor(.primary)
                    .cornerRadius(message.isUser ? 20 : 0)
                    .frame(maxWidth: 280, alignment: message.isUser ? .trailing : .leading)
            }

            if !message.isUser {
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }
}

@available(iOS 17.0, *)
struct MapCardsView: View {
    var cards: [Pin]
    @Environment(ChatModel.self) private var model

    // Compute if the selected pin belongs to this card set
    private var localSelectedId: UUID? {
        guard let selectedId = model.selectedPinId else { return nil }
        return cards.contains(where: { $0.id == selectedId }) ? selectedId : nil
    }

    var body: some View {
        VStack {
            Spacer()
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .top, spacing: 12) {
                    ForEach(cards) { pin in
                        PinCardView(pin: pin, isSelected: model.selectedPinId == pin.id)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollPosition(
                id: Binding(
                    get: { localSelectedId },
                    set: { newValue in
                        // Only update if the new value belongs to this card set
                        if let newValue = newValue, cards.contains(where: { $0.id == newValue }) {
                            model.selectedPinId = newValue
                        }
                    }
                )
            )
            .scrollTargetBehavior(.viewAligned)
            .contentMargins(.horizontal, 12, for: .scrollContent)
        }
    }
}

extension Message {
    func toBlocks() -> [ChatBlock] {
        var result = [ChatBlock(content: .message(.init(content: content, isUser: isUser)))]
        if let mapResponse {
            result.append(ChatBlock(content: .mapCards(mapResponse.pins)))
        }

        return result
    }
}

struct PinCardView: View {
    let pin: Pin
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(pin.name)
                .font(.system(size: 15, weight: .semibold))
                .lineLimit(2)
                .foregroundColor(.primary)

            if let rating = pin.rating {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text(rating)
                        .foregroundColor(.secondary)
                    Text("· $$\(Text("$$").foregroundColor(.gray))")

                }
                .font(.system(size: 13))
            }

            if let image = pin.image {
                Image(ImageResource(name: image, bundle: .main))
                    .resizable()
                    .frame(width: 200, height: 112)

                    .clipped()
            }

            if let details = pin.details {
                Text(details)
            }

            if !pin.tags.isEmpty {
                FlowLayout(spacing: 6) {
                    ForEach(pin.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.system(size: 11))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.primary)
                            .cornerRadius(12)
                    }
                }
            }
        }
        .padding(12)
        .frame(width: 300)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isSelected ? Color.primary.opacity(0.9) : Color.gray.opacity(0.4), lineWidth: 1
                )
                .padding(.all, 1)
        )
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(
        in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()
    ) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(
                at: CGPoint(
                    x: bounds.minX + result.frames[index].minX,
                    y: bounds.minY + result.frames[index].minY), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var frames: [CGRect] = []
        var size: CGSize = .zero

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                frames.append(
                    CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }

            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}
