import SwiftData
import SwiftUI

struct WordDetailView: View {
    @Bindable var entry: VocabularyEntry
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var speech = SpeechService()
    @State private var showDelete = false
    @State private var showRelated: RelatedWord?
    @State private var showNoteEditor = false
    @State private var toast: String?

    private var analysis: WordAnalysis { entry.analysis }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                header
                if entry.analysisFailed || analysis.isFallback {
                    analysisError
                }
                meaning
                usage
                conversations
                whenToUse
                synonyms
                antonyms
                personalNote
                sourceBlock
                related
                details
                statusPicker
            }
            .padding(20)
            .padding(.bottom, 40)
        }
        .paperBackground()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    entry.isFavorite.toggle()
                    Haptics.light()
                    try? modelContext.save()
                } label: {
                    Image(systemName: entry.isFavorite ? "bookmark.fill" : "bookmark")
                        .foregroundStyle(AppTheme.accent)
                }
                .accessibilityLabel(entry.isFavorite ? "Remove bookmark" : "Bookmark")
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("Edit note") { showNoteEditor = true }
                    Picker("Status", selection: $entry.statusRaw) {
                        ForEach(LearningStatus.allCases) { status in
                            Text(status.title).tag(status.rawValue)
                        }
                    }
                    Divider()
                    Button("Delete", role: .destructive) { showDelete = true }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                .accessibilityLabel("More")
            }
        }
        .confirmationDialog("Delete '\(entry.term)'?", isPresented: $showDelete, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                VocabularyStore(modelContext: modelContext).delete(entry)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will remove it from your vocabulary.")
        }
        .sheet(isPresented: $showNoteEditor) {
            NoteEditorSheet(text: $entry.userNote)
        }
        .sheet(item: $showRelated) { related in
            RelatedPreviewSheet(related: related)
                .presentationDetents([.medium])
        }
        .overlay(alignment: .bottom) {
            if let toast {
                ConfirmationToast(message: toast)
                    .padding(.bottom, 24)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .onChange(of: entry.statusRaw) { _, _ in
            Haptics.light()
            try? modelContext.save()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(entry.term)
                .font(.system(size: 34, weight: .bold, design: .default))
                .tracking(-0.8)
                .foregroundStyle(AppTheme.ink)
                .textSelection(.enabled)
            HStack(spacing: 8) {
                Text(analysis.partOfSpeech)
                Text("·")
                DifficultyBadge(difficulty: analysis.difficulty)
                Text("·")
                StatusBadge(status: entry.status)
            }
            .font(.subheadline)
            .foregroundStyle(AppTheme.secondaryInk)

            if !analysis.phoneticSpelling.isEmpty {
                HStack(spacing: 12) {
                    Text(analysis.phoneticSpelling)
                        .font(.body)
                        .foregroundStyle(AppTheme.secondaryInk)
                    if !analysis.pronunciation.isEmpty {
                        Text(analysis.pronunciation)
                            .font(.caption)
                            .foregroundStyle(AppTheme.tertiaryInk)
                    }
                    AudioButton(speech: speech, text: entry.term)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var analysisError: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Couldn't analyze this word.")
                .font(.subheadline.weight(.semibold))
            Text("You can keep it in your notebook and try again when you're ready.")
                .font(.subheadline)
                .foregroundStyle(AppTheme.secondaryInk)
            HStack {
                Button("Try again") {
                    Task {
                        try? await VocabularyStore(modelContext: modelContext).retryAnalysis(entry)
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.accent)
            }
        }
        .padding(16)
        .elevatedCard()
    }

    private var meaning: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Meaning")
                .font(.title3.weight(.semibold))
            Text(analysis.definitionSimple)
                .font(.title3)
                .foregroundStyle(AppTheme.ink)
                .lineSpacing(6)
            if let literal = analysis.literalMeaning, let intended = analysis.intendedMeaning {
                labeled("Literal meaning", literal)
                labeled("Intended meaning", intended)
            }
            if !analysis.definitionDetailed.isEmpty {
                DisclosureGroup("More detail") {
                    Text(analysis.definitionDetailed)
                        .font(.body)
                        .foregroundStyle(AppTheme.secondaryInk)
                        .lineSpacing(6)
                        .padding(.top, 8)
                }
                .tint(AppTheme.accent)
            }
        }
    }

    private var usage: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How people actually use it")
                .font(.title3.weight(.semibold))
            Text("Not just the definition — when a real person would say it.")
                .font(.subheadline)
                .foregroundStyle(AppTheme.secondaryInk)
            if !analysis.everydayScenario.isEmpty {
                Text(analysis.everydayScenario)
                    .font(.body)
                    .foregroundStyle(AppTheme.ink)
                    .lineSpacing(5)
            }
            ForEach(analysis.usageRegisters) { item in
                UsageExample(register: item.register, example: item.example)
            }
        }
    }

    private var conversations: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("In conversation")
                .font(.title3.weight(.semibold))
            if analysis.conversations.isEmpty {
                Text("No conversation examples yet.")
                    .foregroundStyle(AppTheme.secondaryInk)
            } else {
                ForEach(analysis.conversations) { item in
                    ConversationExampleView(example: item)
                }
            }
        }
    }

    private var whenToUse: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("When to use it")
                .font(.title3.weight(.semibold))
            VStack(alignment: .leading, spacing: 8) {
                Text("Use \(entry.term.lowercased()) when something is:")
                    .foregroundStyle(AppTheme.secondaryInk)
                ForEach(analysis.whenToUse, id: \.self) { item in
                    bullet(item, system: "checkmark")
                }
            }
            if !analysis.whenNotToUse.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Don't use it when something is merely:")
                        .foregroundStyle(AppTheme.secondaryInk)
                    ForEach(analysis.whenNotToUse, id: \.self) { item in
                        bullet(item, system: "xmark")
                    }
                }
            }
        }
    }

    private var synonyms: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Synonyms")
                .font(.title3.weight(.semibold))
            Text("Close in spirit — not always a perfect swap.")
                .font(.caption)
                .foregroundStyle(AppTheme.tertiaryInk)
            SynonymGroup(title: "Simple", words: analysis.synonymsSimple, onTap: openRelated)
            SynonymGroup(title: "Intermediate", words: analysis.synonymsIntermediate, onTap: openRelated)
            SynonymGroup(title: "Advanced", words: analysis.synonymsAdvanced, onTap: openRelated)
        }
    }

    private var antonyms: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Antonyms")
                .font(.title3.weight(.semibold))
            SynonymGroup(title: "Simple", words: analysis.antonymsSimple, onTap: openRelated)
            SynonymGroup(title: "Intermediate", words: analysis.antonymsIntermediate, onTap: openRelated)
            SynonymGroup(title: "Advanced", words: analysis.antonymsAdvanced, onTap: openRelated)
        }
    }

    private var personalNote: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("My note")
                    .font(.title3.weight(.semibold))
                Spacer()
                Button(entry.userNote.isEmpty ? "Add note" : "Edit") {
                    showNoteEditor = true
                }
                .font(.subheadline.weight(.medium))
            }
            if entry.userNote.isEmpty {
                Text("Why did you save this word?")
                    .font(.body)
                    .foregroundStyle(AppTheme.tertiaryInk)
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppTheme.noteWash, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            } else {
                Text(entry.userNote)
                    .font(.body)
                    .foregroundStyle(AppTheme.ink)
                    .lineSpacing(5)
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppTheme.noteWash, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
    }

    private var sourceBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Where you found it")
                .font(.title3.weight(.semibold))
            Text(entry.source.rawValue)
                .foregroundStyle(AppTheme.secondaryInk)
            if !entry.originalSentence.isEmpty {
                Text("“\(entry.originalSentence)”")
                    .italic()
                    .foregroundStyle(AppTheme.ink)
                    .lineSpacing(5)
            }
        }
    }

    private var related: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Related words")
                .font(.title3.weight(.semibold))
            ChipRow(words: analysis.relatedWords.map(\.term)) { term in
                if let match = analysis.relatedWords.first(where: { $0.term == term }) {
                    showRelated = match
                }
            }
        }
    }

    private var details: some View {
        ExpandableSection(title: "Details", subtitle: "Tone, origin, frequency") {
            VStack(alignment: .leading, spacing: 12) {
                labeled("Tone", analysis.tone)
                labeled("Frequency", analysis.frequency)
                labeled("Origin", analysis.origin)
                labeled("Type", entry.kind.title)
            }
        }
    }

    private var statusPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Learning status")
                .font(.title3.weight(.semibold))
            Picker("Status", selection: $entry.statusRaw) {
                ForEach(LearningStatus.allCases) { status in
                    Text(status.title).tag(status.rawValue)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private func labeled(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppTheme.tertiaryInk)
            Text(value.isEmpty ? "—" : value)
                .font(.body)
                .foregroundStyle(AppTheme.ink)
        }
    }

    private func bullet(_ text: String, system: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: system)
                .font(.caption.weight(.bold))
                .foregroundStyle(AppTheme.accent)
                .padding(.top, 4)
            Text(text)
                .font(.body)
                .foregroundStyle(AppTheme.ink)
        }
    }

    private func openRelated(_ term: String) {
        showRelated = RelatedWord(term: term, gloss: WordCatalog.analysis(for: term)?.definitionSimple ?? "A nearby word — tap Save later if you want it in your collection.")
    }
}

struct NoteEditorSheet: View {
    @Binding var text: String
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            TextEditor(text: $text)
                .padding()
                .paperBackground()
                .navigationTitle("My note")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Delete", role: .destructive) {
                            text = ""
                            try? modelContext.save()
                            dismiss()
                        }
                        .disabled(text.isEmpty)
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            try? modelContext.save()
                            dismiss()
                        }
                        .fontWeight(.semibold)
                    }
                }
        }
        .presentationDetents([.medium, .large])
    }
}

struct RelatedPreviewSheet: View {
    let related: RelatedWord
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var saved = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text(related.term)
                    .font(.largeTitle.weight(.bold))
                Text(related.gloss)
                    .font(.title3)
                    .foregroundStyle(AppTheme.secondaryInk)
                    .lineSpacing(5)
                Spacer()
                Button(saved ? "Saved" : "Save this word") {
                    Task {
                        _ = try? await VocabularyStore(modelContext: modelContext).add(raw: related.term, source: .discovered, note: "")
                        saved = true
                        Haptics.save()
                    }
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .foregroundStyle(.white)
                .background(AppTheme.accent, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .disabled(saved)
            }
            .padding(24)
            .paperBackground()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}
