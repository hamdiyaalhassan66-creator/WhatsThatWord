import SwiftUI

struct StatusBadge: View {
    let status: LearningStatus

    var body: some View {
        Label(status.title, systemImage: status.symbol)
            .font(.caption.weight(.medium))
            .foregroundStyle(AppTheme.secondaryInk)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(AppTheme.paper, in: Capsule())
            .accessibilityLabel("Status \(status.title)")
    }
}

struct DifficultyBadge: View {
    let difficulty: Difficulty

    var body: some View {
        Text(difficulty.title)
            .font(.caption.weight(.medium))
            .foregroundStyle(AppTheme.secondaryInk)
            .accessibilityLabel("Difficulty \(difficulty.title)")
    }
}

struct EmptyState: View {
    let symbol: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: symbol)
                .font(.system(size: 36, weight: .light))
                .foregroundStyle(AppTheme.accent)
                .padding(.bottom, 4)
            Text(title)
                .font(.title3.weight(.semibold))
                .foregroundStyle(AppTheme.ink)
            Text(message)
                .font(.body)
                .foregroundStyle(AppTheme.secondaryInk)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.accent)
                    .padding(.top, 8)
            }
        }
        .padding(28)
        .frame(maxWidth: .infinity)
    }
}

struct WordListItem: View {
    let entry: VocabularyEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text(entry.term)
                    .font(.headline)
                    .foregroundStyle(AppTheme.ink)
                Spacer()
                if entry.isFavorite {
                    Image(systemName: "bookmark.fill")
                        .font(.caption)
                        .foregroundStyle(AppTheme.accent)
                        .accessibilityLabel("Favorite")
                }
            }
            Text(entry.analysis.definitionSimple)
                .font(.subheadline)
                .foregroundStyle(AppTheme.secondaryInk)
                .lineLimit(2)
                .lineSpacing(3)
            HStack(spacing: 10) {
                Text(entry.analysis.difficulty.title)
                Text("·")
                Text(entry.status.title)
                Text("·")
                Text(entry.dateAdded, format: .dateTime.month(.abbreviated).day())
            }
            .font(.caption)
            .foregroundStyle(AppTheme.tertiaryInk)
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
    }
}

struct AudioButton: View {
    @ObservedObject var speech: SpeechService
    let text: String

    var body: some View {
        HStack(spacing: 10) {
            Button {
                speech.speak(text)
            } label: {
                Image(systemName: speech.isSpeaking ? "speaker.wave.2.fill" : "speaker.wave.2")
                    .font(.body.weight(.medium))
                    .foregroundStyle(AppTheme.accent)
                    .frame(width: 36, height: 36)
                    .background(AppTheme.accent.opacity(0.12), in: Circle())
                    .scaleEffect(speech.isSpeaking ? 1.06 : 1)
                    .animation(Motion.quick, value: speech.isSpeaking)
            }
            .accessibilityLabel(speech.isSpeaking ? "Stop pronunciation" : "Play pronunciation")

            Button(speech.isSlow ? "Slow" : "Normal") {
                speech.isSlow.toggle()
            }
            .font(.caption.weight(.medium))
            .foregroundStyle(AppTheme.secondaryInk)
            .accessibilityLabel("Pronunciation speed \(speech.isSlow ? "slow" : "normal")")
        }
    }
}

struct ExpandableSection<Content: View>: View {
    let title: String
    var subtitle: String? = nil
    @State private var open = false
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation(Motion.quick) { open.toggle() }
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(AppTheme.ink)
                        if let subtitle {
                            Text(subtitle)
                                .font(.caption)
                                .foregroundStyle(AppTheme.tertiaryInk)
                        }
                    }
                    Spacer()
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(open ? 0 : -90))
                        .foregroundStyle(AppTheme.tertiaryInk)
                }
            }
            .buttonStyle(.plain)
            .accessibilityHint(open ? "Collapse" : "Expand")

            if open {
                content
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

struct SynonymGroup: View {
    let title: String
    let words: [String]
    var onTap: (String) -> Void

    var body: some View {
        if !words.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.tertiaryInk)
                    .textCase(.uppercase)
                    .tracking(0.6)
                ChipRow(words: words, onTap: onTap)
            }
        }
    }
}

struct UsageExample: View {
    let register: String
    let example: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(register)
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppTheme.accent)
            Text("“\(example)”")
                .font(.body)
                .italic()
                .foregroundStyle(AppTheme.ink)
                .lineSpacing(5)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .elevatedCard()
    }
}

struct ConversationExampleView: View {
    let example: ConversationExample

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(example.tone)
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppTheme.accent)
            ForEach(example.turns) { turn in
                VStack(alignment: .leading, spacing: 4) {
                    Text(turn.speaker)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppTheme.ink)
                    Text("“\(turn.line)”")
                        .font(.body)
                        .foregroundStyle(AppTheme.secondaryInk)
                        .lineSpacing(4)
                }
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("Why it works")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.ink)
                Text(example.whyItWorks)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.secondaryInk)
                    .lineSpacing(4)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .elevatedCard()
    }
}

struct ProgressCard: View {
    let saved: Int
    let learned: Int
    let streak: Int

    var body: some View {
        HStack(spacing: 0) {
            metric("\(saved)", "words")
            Divider().frame(height: 36)
            metric("\(learned)", "learned")
            Divider().frame(height: 36)
            metric("\(streak) day", "streak")
        }
        .padding(.vertical, 18)
        .elevatedCard()
        .accessibilityElement(children: .combine)
    }

    private func metric(_ value: String, _ label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.weight(.semibold))
                .foregroundStyle(AppTheme.ink)
            Text(label)
                .font(.caption)
                .foregroundStyle(AppTheme.secondaryInk)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ConfirmationToast: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(AppTheme.ink)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial, in: Capsule())
    }
}
