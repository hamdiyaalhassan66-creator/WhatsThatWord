import SwiftData
import SwiftUI

struct LibraryView: View {
    @Binding var showAdd: Bool
    @Query(sort: \VocabularyEntry.dateAdded, order: .reverse) private var words: [VocabularyEntry]
    @Environment(\.modelContext) private var modelContext
    @State private var search = ""
    @State private var status: LearningStatus?
    @State private var difficulty: Difficulty?
    @State private var kind: EntryKind?
    @State private var source: WordSource?
    @State private var dateBucket: DateBucket = .any
    @State private var sort: SortOrder = .recentlyAdded
    @State private var favoritesOnly = false
    @State private var undoEntry: VocabularyEntry?
    @State private var showFilters = false

    var body: some View {
        NavigationStack {
            Group {
                if filtered.isEmpty {
                    if words.isEmpty {
                        EmptyState(
                            symbol: "text.book.closed",
                            title: "Your vocabulary starts here.",
                            message: "Save a word whenever you come across one you don't know.",
                            actionTitle: "Add your first word",
                            action: { showAdd = true }
                        )
                    } else {
                        EmptyState(
                            symbol: "magnifyingglass",
                            title: "No words found.",
                            message: "Try searching another word or phrase."
                        )
                    }
                } else {
                    List {
                        ForEach(filtered, id: \.entryID) { word in
                            NavigationLink {
                                WordDetailView(entry: word)
                            } label: {
                                WordListItem(entry: word)
                            }
                            .listRowBackground(AppTheme.paper)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    undoEntry = word
                                    VocabularyStore(modelContext: modelContext).delete(word)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    word.isFavorite.toggle()
                                    try? modelContext.save()
                                } label: {
                                    Label(word.isFavorite ? "Unbookmark" : "Favorite", systemImage: "bookmark")
                                }
                                .tint(AppTheme.accent)
                                Button {
                                    word.status = .familiar
                                    try? modelContext.save()
                                } label: {
                                    Label("Mark learned", systemImage: "checkmark")
                                }
                                .tint(.green)
                            }
                            .contextMenu {
                                Button {
                                    word.isFavorite.toggle()
                                    try? modelContext.save()
                                } label: {
                                    Label(word.isFavorite ? "Remove bookmark" : "Bookmark", systemImage: "bookmark")
                                }
                                Button(role: .destructive) {
                                    VocabularyStore(modelContext: modelContext).delete(word)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .paperBackground()
            .navigationTitle("My words")
            .searchable(text: $search, placement: .navigationBarDrawer(displayMode: .always), prompt: "Word, meaning, or synonym")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showFilters = true
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                    .accessibilityLabel("Filter and sort")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAdd = true } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add word")
                }
            }
            .sheet(isPresented: $showFilters) {
                FilterSheet(
                    status: $status,
                    difficulty: $difficulty,
                    kind: $kind,
                    source: $source,
                    dateBucket: $dateBucket,
                    sort: $sort,
                    favoritesOnly: $favoritesOnly
                )
            }
            .overlay(alignment: .bottom) {
                if undoEntry != nil {
                    // Swipe-delete already happened; keep copy light.
                    ConfirmationToast(message: "Deleted. That’s gone from this device.")
                        .padding(.bottom, 16)
                }
            }
        }
    }

    private var filtered: [VocabularyEntry] {
        var result = words
        let q = search.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !q.isEmpty {
            result = result.filter { $0.searchBlob.contains(q) }
        }
        if let status { result = result.filter { $0.status == status } }
        if let difficulty { result = result.filter { $0.analysis.difficulty == difficulty } }
        if let kind { result = result.filter { $0.kind == kind } }
        if let source { result = result.filter { $0.source == source } }
        if favoritesOnly { result = result.filter(\.isFavorite) }
        result = result.filter { dateBucket.contains($0.dateAdded) }

        switch sort {
        case .recentlyAdded:
            result.sort { $0.dateAdded > $1.dateAdded }
        case .alphabetical:
            result.sort { $0.term.localizedCaseInsensitiveCompare($1.term) == .orderedAscending }
        case .recentlyReviewed:
            result.sort { ($0.lastReviewed ?? .distantPast) > ($1.lastReviewed ?? .distantPast) }
        case .difficulty:
            result.sort { rank($0.analysis.difficulty) > rank($1.analysis.difficulty) }
        case .mastery:
            result.sort { $0.masteryLevel > $1.masteryLevel }
        }
        return result
    }

    private func rank(_ difficulty: Difficulty) -> Int {
        switch difficulty {
        case .beginner: 0
        case .intermediate: 1
        case .advanced: 2
        }
    }
}

enum DateBucket: String, CaseIterable, Identifiable {
    case any = "Any time"
    case today = "Today"
    case week = "This week"
    case month = "This month"
    case older = "Older"

    var id: String { rawValue }

    func contains(_ date: Date) -> Bool {
        let cal = Calendar.current
        switch self {
        case .any: return true
        case .today: return cal.isDateInToday(date)
        case .week: return date >= cal.date(byAdding: .day, value: -7, to: .now) ?? date
        case .month: return date >= cal.date(byAdding: .month, value: -1, to: .now) ?? date
        case .older: return date < cal.date(byAdding: .month, value: -1, to: .now) ?? date
        }
    }
}

struct FilterSheet: View {
    @Binding var status: LearningStatus?
    @Binding var difficulty: Difficulty?
    @Binding var kind: EntryKind?
    @Binding var source: WordSource?
    @Binding var dateBucket: DateBucket
    @Binding var sort: SortOrder
    @Binding var favoritesOnly: Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Picker("Sort", selection: $sort) {
                    ForEach(SortOrder.allCases) { item in
                        Text(item.title).tag(item)
                    }
                }
                Toggle("Bookmarks only", isOn: $favoritesOnly)
                Picker("Status", selection: $status) {
                    Text("All").tag(Optional<LearningStatus>.none)
                    ForEach(LearningStatus.allCases) { item in
                        Text(item.title).tag(Optional(item))
                    }
                }
                Picker("Difficulty", selection: $difficulty) {
                    Text("All").tag(Optional<Difficulty>.none)
                    ForEach(Difficulty.allCases) { item in
                        Text(item.title).tag(Optional(item))
                    }
                }
                Picker("Type", selection: $kind) {
                    Text("All").tag(Optional<EntryKind>.none)
                    ForEach(EntryKind.allCases) { item in
                        Text(item.title).tag(Optional(item))
                    }
                }
                Picker("Source", selection: $source) {
                    Text("All").tag(Optional<WordSource>.none)
                    ForEach(WordSource.allCases) { item in
                        Text(item.rawValue).tag(Optional(item))
                    }
                }
                Picker("Date", selection: $dateBucket) {
                    ForEach(DateBucket.allCases) { item in
                        Text(item.rawValue).tag(item)
                    }
                }
                Button("Clear filters") {
                    status = nil
                    difficulty = nil
                    kind = nil
                    source = nil
                    dateBucket = .any
                    favoritesOnly = false
                    sort = .recentlyAdded
                }
            }
            .navigationTitle("Filter & sort")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
