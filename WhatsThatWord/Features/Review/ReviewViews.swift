import SwiftData
import SwiftUI

struct ReviewHubView: View {
    @Query(sort: \VocabularyEntry.dateAdded, order: .reverse) private var words: [VocabularyEntry]

    private var queue: [VocabularyEntry] { words.filter(\.needsReview) }

    var body: some View {
        NavigationStack {
            Group {
                if queue.isEmpty {
                    EmptyState(
                        symbol: "checkmark.circle",
                        title: "You're all caught up.",
                        message: "Come back when you're ready for another review."
                    )
                } else {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("\(queue.count) words are ready.")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(AppTheme.ink)
                        Text("One word at a time. No points. Just see if it still lives in your head.")
                            .font(.body)
                            .foregroundStyle(AppTheme.secondaryInk)
                            .lineSpacing(5)
                        NavigationLink {
                            ReviewSessionView(queue: queue)
                        } label: {
                            Text("Start review")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .foregroundStyle(.white)
                                .background(AppTheme.accent, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                        .pressable()
                        Spacer()
                    }
                    .padding(24)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .paperBackground()
            .navigationTitle("Review")
        }
    }
}

struct ReviewSessionView: View {
    let queue: [VocabularyEntry]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var settings: AppSettings
    @State private var index = 0
    @State private var revealed = false
    @State private var offset: CGFloat = 0

    private var store: VocabularyStore { VocabularyStore(modelContext: modelContext) }

    var body: some View {
        VStack(spacing: 0) {
            progress
            if index >= queue.count {
                finished
            } else {
                card(queue[index])
                    .offset(x: offset)
                    .gesture(drag)
            }
        }
        .paperBackground()
        .navigationTitle("Review")
        .navigationBarTitleDisplayMode(.inline)
        .animation(Motion.card, value: index)
        .animation(Motion.quick, value: revealed)
    }

    private var progress: some View {
        ProgressView(value: Double(min(index, queue.count)), total: Double(max(queue.count, 1)))
            .tint(AppTheme.accent)
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .accessibilityLabel("Review progress")
    }

    private func card(_ entry: VocabularyEntry) -> some View {
        VStack(alignment: .leading, spacing: 22) {
            Spacer()
            Text(entry.term)
                .font(.system(size: 36, weight: .bold))
                .tracking(-0.8)
                .foregroundStyle(AppTheme.ink)
            Text("Do you remember what this means?")
                .font(.title3)
                .foregroundStyle(AppTheme.secondaryInk)

            if revealed {
                VStack(alignment: .leading, spacing: 12) {
                    Text(entry.analysis.definitionSimple)
                        .font(.title3)
                        .lineSpacing(5)
                    if let example = entry.analysis.examples.first {
                        Text("“\(example)”")
                            .italic()
                            .foregroundStyle(AppTheme.secondaryInk)
                    }
                    if let syn = entry.analysis.synonymsSimple.first {
                        Text("Nearby: \(syn)")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.tertiaryInk)
                    }
                    if let convo = entry.analysis.conversations.first?.turns.last?.line {
                        Text("In conversation: “\(convo)”")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.secondaryInk)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }

            Spacer()

            VStack(spacing: 10) {
                if revealed == false {
                    reviewButton("I know it", filled: true) {
                        store.recordReview(entry, outcome: .knows)
                        advance()
                    }
                    reviewButton("I'm still learning", filled: false) {
                        store.recordReview(entry, outcome: .learning)
                        advance()
                    }
                    reviewButton("I forgot", filled: false) {
                        withAnimation(Motion.quick) { revealed = true }
                        store.recordReview(entry, outcome: .forgot)
                    }
                } else {
                    reviewButton("Continue", filled: true) {
                        advance()
                    }
                }
            }
        }
        .padding(24)
    }

    private var finished: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "checkmark.circle")
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(AppTheme.accent)
            Text("That’s enough for now.")
                .font(.title.weight(.semibold))
            Text("Come back when a few more words are ready.")
                .foregroundStyle(AppTheme.secondaryInk)
            Button("Done") { dismiss() }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.accent)
            Spacer()
        }
        .onAppear { settings.markReviewedToday() }
    }

    private func reviewButton(_ title: String, filled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .foregroundStyle(filled ? Color.white : AppTheme.ink)
                .background {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(filled ? AppTheme.accent : AppTheme.elevated)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(filled ? Color.clear : AppTheme.hairline)
                        )
                }
        }
        .pressable()
    }

    private func advance() {
        revealed = false
        offset = 0
        index += 1
        if index >= queue.count {
            settings.markReviewedToday()
        }
    }

    private var drag: some Gesture {
        DragGesture()
            .onChanged { value in
                offset = value.translation.width
            }
            .onEnded { value in
                if value.translation.width < -80, index < queue.count {
                    store.recordReview(queue[index], outcome: .knows)
                    advance()
                } else if value.translation.width > 80 {
                    withAnimation(Motion.quick) { revealed = true }
                    offset = 0
                } else {
                    withAnimation(Motion.quick) { offset = 0 }
                }
            }
    }
}
