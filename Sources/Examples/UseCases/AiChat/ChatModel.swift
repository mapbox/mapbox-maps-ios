import Foundation

struct ChatSection: Identifiable {
    var id = UUID()
    var blocks = [ChatBlock]()
    var map: MapResponse? = nil
}

@available(iOS 17.0, *)
@Observable class ChatModel {
    var demo: Demo
    init(demo: Demo) {
        self.demo = demo
        if let firstMessage = demo.flow.first {
            self.inputText = firstMessage.content
        }
    }

    var sections = [ChatSection]()
    var step = 0
    var inputText = ""
    var lastMessageId: UUID?
    var isWaiting = false

    var selectedPinId: UUID?

    func mapResponse(forPinId pinId: UUID) -> MapResponse? {
        for section in sections {
            if let map = section.map, map.pins.contains(where: { $0.id == pinId }) {
                return map
            }
        }
        return nil
    }

    // Get the MapResponse for a specific section
    func mapResponse(forSectionId sectionId: UUID) -> MapResponse? {
        return sections.first(where: { $0.id == sectionId })?.map
    }

    func sendMessage() {
        emulateNextMessage()

        simulateWaiting {
            self.emulateNextMessage()
            self.prefillNextUserMessage()
        }
    }

    private func simulateWaiting(completion: @escaping () -> Void) {
        isWaiting = true

        if sections.isEmpty {
            sections.append(ChatSection())
        }
        let waiterBlock = ChatBlock(content: .waiter)
        sections[sections.endIndex - 1].blocks.append(waiterBlock)
        lastMessageId = waiterBlock.id

        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            await MainActor.run {
                if let lastSection = sections.last,
                    let waiterIndex = lastSection.blocks.firstIndex(where: { $0.content.isWaiter })
                {
                    sections[sections.endIndex - 1].blocks.remove(at: waiterIndex)
                }

                completion()
                isWaiting = false
            }
        }
    }

    private func emulateNextMessage() {
        guard let message = safeGet(idx: step) else { return }

        if sections.isEmpty {
            sections.append(ChatSection())
        }

        if let map = message.mapResponse {
            if !sections.last!.blocks.isEmpty && sections.last!.map == nil
                && message.mapResponse != nil
            {
                sections.append(ChatSection())
            }
            sections[sections.endIndex - 1].map = map
        }

        sections[sections.endIndex - 1].blocks.append(contentsOf: message.toBlocks())
        lastMessageId = sections.last?.blocks.last?.id
        step += 1
    }

    private func prefillNextUserMessage() {
        inputText = safeGet(idx: step)?.content ?? ""
    }

    private func safeGet(idx: Int) -> Message? {
        demo.flow.count > idx ? demo.flow[idx] : nil
    }
}
