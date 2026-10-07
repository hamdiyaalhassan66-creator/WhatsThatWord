import SwiftData
import SwiftUI

struct HomeView: View {
    @Binding var showAdd: Bool
    @Binding var openedEntryID: UUID?
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var settings: AppSettings
    @Query(sort: \VocabularyEntry.dateAdded, order: .reverse) private var words: [VocabularyEntry]
    @State private var skippedDaily = false
    @State private var path = NavigationPath()

    private var learnedCount: Int {
        words.filter { $0.status == .familiar || $0.status == .mastered }.count
    }

    private var reviewQueue: [VocabularyEntry] {
        words.filter(\.needsReview)
    }

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    header
                    ProgressCard(saved: words.count, learned: learnedCount, streak: settings.streak)
                    reviewSection
                    recentSection
                    if settings.dailyWordEnabled { dailySection }
                }
                .padding(20)
                .padding(.bottom, 80)
            }
            .paperBackground()
            .navigationTitle("Your vocabulary")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAdd = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.body.weight(.semibold))
                    }
                    .accessibilityLabel("Add word")
                }
            }
            .overlay(alignment: .bottomTrailing) {
                Button {
                    showAdd = true
                } label: {
                    Label("Add word", systemImage: "plus")
                        .font(.headline)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .foregroundStyle(.white)
                        .background(AppTheme.accent, in: Capsule())
                        .shadow(color: AppTheme.accent.opacity(0.28), radius: 12, y: 6)
                }
                .padding(20)
                .pressable()
                .accessibilityLabel("Add word")
            }
            .navigationDestination(for: UUID.self) { id in
                if let entry = words.first(where: { $0.entryID == id }) {
                    WordDetailView(entry: entry)
                }
            }
            .onChange(of: openedEntryID) { _, newValue in
                if let newValue {
                    path.append(newValue)
                    openedEntryID = nil
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(greeting)
                .font(.title2.weight(.semibold))
                .foregroundStyle(AppTheme.ink)
            Text("Keep collecting words worth remembering.")
                .font(.body)
                .foregroundStyle(AppTheme.secondaryInk)
        }
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: .now)
        if hour < 12 { return "Good morning." }
        if hour < 18 { return "Good afternoon." }
        return "Good evening."
    }

    @ViewBuilder
    private var reviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Review")
                .font(.title3.weight(.semibold))
            if reviewQueue.isEmpty {
                Text("You're all caught up.")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.secondaryInk)
            } else {
                Text("\(reviewQueue.count) words are ready for review")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.secondaryInk)
                NavigationLink {
                    ReviewSessionView(queue: reviewQueue)
                } label: {
                    Text("Start review")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .foregroundStyle(.white)
                        .background(AppTheme.accent, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .pressable()

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(Array(reviewQueue.prefix(6)), id: \.entryID) { word in
                            NavigationLink(value: word.entryID) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(word.term)
                                        .font(.headline)
                                        .foregroundStyle(AppTheme.ink)
                                    Text(word.analysis.definitionSimple)
                                        .font(.caption)
                                        .foregroundStyle(AppTheme.secondaryInk)
                                        .lineLimit(2)
                                }
                                .padding(14)
                                .frame(width: 180, alignment: .leading)
                                .elevatedCard()
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recently added")
                .font(.title3.weight(.semibold))
            if words.isEmpty {
                EmptyState(
                    symbol: "text.book.closed",
                    title: "Your vocabulary starts here.",
                    message: "Save a word whenever you come across one you don't know.",
                    actionTitle: "Add your first word",
                    action: { showAdd = true }
                )
            } else {
                ForEach(Array(words.prefix(5)), id: \.entryID) { word in
                    NavigationLink(value: word.entryID) {
                        WordListItem(entry: word)
                    }
                    .buttonStyle(.plain)
                    if word.entryID != words.prefix(5).last?.entryID {
                        Divider().opacity(0.5)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var dailySection: some View {
        let daily = WordCatalog.wordOfTheDay
        VStack(alignment: .leading, spacing: 12) {
            Text("Word of the day")
                .font(.title3.weight(.semibold))
            VStack(alignment: .leading, spacing: 10) {
                Text("Ephemeral")
                    .font(.title.weight(.bold))
                    .tracking(-0.5)
                Text("\(daily.partOfSpeech) · \(daily.difficulty.title)")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.secondaryInk)
                Text(daily.definitionSimple)
                    .font(.body)
                    .foregroundStyle(AppTheme.ink)
                    .lineSpacing(5)
                if skippedDaily {
                    Text("Skipped for today.")
                        .font(.caption)
                        .foregroundStyle(AppTheme.tertiaryInk)
                } else {
                    HStack {
                        Button("Save") {
                            Task {
                                _ = try? await VocabularyStore(modelContext: modelContext).add(raw: "ephemeral", source: .discovered, note: "")
                                Haptics.save()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(AppTheme.accent)
                        Button("Skip") { skippedDaily = true }
                            .buttonStyle(.bordered)
                    }
                    .padding(.top, 4)
                }
            }
            .padding(18)
            .elevatedCard()
        }
    }
}
