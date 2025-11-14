import SwiftUI

@available(iOS 17.0, *)
struct ChatDemoView: View {
    @State var model: ChatModel
    @FocusState private var isInputFocused: Bool

    init(model: ChatModel) {
        self.model = model
    }

    init() {
        self.init(model: ChatModel(demo: .dateNightRestaurants))
    }

    var body: some View {
        Group {
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 8, pinnedViews: .sectionHeaders) {
                            ForEach(model.sections) { section in
                                Section {
                                    ForEach(section.blocks) { block in
                                        ChatBlockView(block: block)
                                    }
                                } header: {
                                    if let map = section.map {
                                        ChatMapView(response: map, sectionId: section.id)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .onChange(of: model.lastMessageId) { _, _ in
                        if let lastMessageId = model.lastMessageId {
                            withAnimation {
                                proxy.scrollTo(lastMessageId, anchor: .bottom)
                            }
                        }
                    }
                    .onChange(of: model.selectedPinId) { _, _ in
                        if let selectedPinId = model.selectedPinId {
                            withAnimation {
                                proxy.scrollTo(selectedPinId, anchor: .bottom)
                            }
                        }
                    }
                }
                .environment(model)

                HStack(spacing: 12) {
                    TextField("Message", text: $model.inputText, axis: .vertical)
                        .textFieldStyle(.plain)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color(.systemGray6))
                        .cornerRadius(20)
                        .lineLimit(1...6)
                        .focused($isInputFocused)
                        .onSubmit {
                            model.sendMessage()
                        }

                    Button(action: { model.sendMessage() }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(
                                model.inputText.isEmpty || model.isWaiting ? .gray : .blue)
                    }
                    .disabled(model.inputText.isEmpty || model.isWaiting)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemBackground))
            }
        }

    }
}
