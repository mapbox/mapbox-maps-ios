import SwiftUI

struct SearchView: View {
    @Binding var searchText: String
    @State private var searchResults: [Examples.Category] = []

    // Lazy search index - built on first access, non-blocking
    private static let searchIndex = SearchIndex()

    var body: some View {
        NavigationStack {
            List {
                ForEach(searchResults, id: \.title) { category in
                    if !category.examples.isEmpty {
                        Section {
                            ForEach(category.examples, id: \.title) { example in
                                ExampleLink(example.title, note: example.description, destination: AnyView(example.destination()))
                            }
                        } header: { Text(category.title) }
                    }
                }
            }
            .navigationTitle("Search")
            .scrollDismissesKeyboard(.interactively)
            .task(id: searchText) {
                await updateSearchResults(for: searchText)
            }
            .onAppear {
                Task {
                    await updateSearchResults(for: searchText)
                }
            }
        }
    }

    @MainActor
    private func updateSearchResults(for query: String) async {
        if query.isEmpty {
            searchResults = await Self.searchIndex.allCategories()
            return
        }

        // Use pre-computed search index for maximum performance
        searchResults = await Self.searchIndex.search(query: query.lowercased())
    }
}

// High-performance search index with lazy, non-blocking initialization
private actor SearchIndex {
    private var allCategories: [Examples.Category]?
    private var searchableItems: [SearchableItem]?

    init() {
        // Empty initializer - indexing happens on first access
    }

    // Non-blocking index building
    func ensureIndexed() async {
        guard allCategories == nil || searchableItems == nil else { return }

        // Build index on background
        await buildIndex()
    }

    private func buildIndex() async {
        let allExamples: [(String, [Example])] = [
            ("UIKit", Examples.all.flatMap { $0.examples }),
            ("SwiftUI", SwiftUIExamples.all.flatMap { $0.examples }),
            ("Use Cases", UseCases.all.flatMap { $0.examples })
        ]

        // Store original categories
        let categories = allExamples.map { Examples.Category(title: $0.0, examples: $0.1) }

        // Pre-compute all search data
        var items: [SearchableItem] = []
        for (categoryIndex, (_, examples)) in allExamples.enumerated() {
            for (exampleIndex, example) in examples.enumerated() {
                let searchData = SearchData(
                    lowercaseTitle: example.title.lowercased(),
                    lowercaseDescription: example.description.lowercased(),
                    titleWords: example.title.lowercased().components(separatedBy: .whitespacesAndNewlines),
                    descriptionWords: example.description.lowercased().components(separatedBy: .whitespacesAndNewlines)
                )
                items.append(SearchableItem(categoryIndex: categoryIndex, exampleIndex: exampleIndex, searchData: searchData))
            }
        }

        allCategories = categories
        searchableItems = items
    }

    func allCategories() async -> [Examples.Category] {
        await ensureIndexed()
        return allCategories ?? []
    }

    func search(query: String) async -> [Examples.Category] {
        await ensureIndexed()

        guard let searchableItems = searchableItems,
              let allCategories = allCategories else {
            return []
        }

        let matchingItems = searchableItems.filter { item in
            let searchData = item.searchData

            // Fast exact match
            if searchData.lowercaseTitle == query { return true }

            // Fast prefix matches
            if searchData.lowercaseTitle.hasPrefix(query) { return true }

            // Word prefix matches
            if searchData.titleWords.contains(where: { $0.hasPrefix(query) }) {
                return true
            }

            if searchData.descriptionWords.contains(where: { $0.hasPrefix(query) }) {
                return true
            }

            // Substring matches
            return searchData.lowercaseTitle.contains(query) || searchData.lowercaseDescription.contains(query)
        }

        // Group results back into categories
        var categoryResults: [String: [Example]] = [:]

        for item in matchingItems {
            let categoryTitle = allCategories[item.categoryIndex].title
            let example = allCategories[item.categoryIndex].examples[item.exampleIndex]

            if categoryResults[categoryTitle] == nil {
                categoryResults[categoryTitle] = []
            }
            categoryResults[categoryTitle]?.append(example)
        }

        return categoryResults.map { Examples.Category(title: $0.key, examples: $0.value) }
    }
}

private struct SearchableItem {
    let categoryIndex: Int
    let exampleIndex: Int
    let searchData: SearchData
}

private struct SearchData {
    let lowercaseTitle: String
    let lowercaseDescription: String
    let titleWords: [String]
    let descriptionWords: [String]
}
