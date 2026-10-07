import SwiftData
import SwiftUI

struct AddWordSheet: View {
    var onSaved: (VocabularyEntry) -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var text = ""
    @State private var note = ""
    @State private var source: WordSource = .manual
    @State private var isSaving = false
    @State private var errorMessage: String?
    @State private var suggestion: String?
    @FocusState private var focused: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Type a word or phrase…")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.secondaryInk)

                    TextField("ubiquitous, nonchalant, “read between the lines”", text: $text, axis: .vertical)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .lineLimit(1...6)
                        .padding(14)
                        .background(AppTheme.paper, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .focused($focused)

                    if let suggestion {
                        Button {
                            text = suggestion
                        } label: {
                            HStack {
                                Text("Save this word")
                                    .font(.subheadline.weight(.semibold))
                                Text(suggestion)
                                    .font(.subheadline)
                                    .foregroundStyle(AppTheme.secondaryInk)
                                Spacer()
                            }
                            .padding(14)
                            .elevatedCard()
                        }
                        .buttonStyle(.plain)
                    }

                    Picker("Where did you find this?", selection: $source) {
                        ForEach(WordSource.allCases) { item in
                            Text(item.rawValue).tag(item)
                        }
                    }
                    .pickerStyle(.navigationLink)

                    TextField("Why did you save this word?", text: $note, axis: .vertical)
                        .lineLimit(2...5)
                        .padding(14)
                        .background(AppTheme.noteWash, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                    if let errorMessage {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(errorMessage)
                                .foregroundStyle(.red)
                            HStack {
                                Button("Try again") { Task { await save(allowFailure: false) } }
                                Button("Save without analysis") { Task { await save(allowFailure: true) } }
                            }
                        }
                    }
                }
                .padding(20)
            }
            .paperBackground()
            .navigationTitle("Add something new")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Paste") {
                        if let clip = UIPasteboard.general.string {
                            text = clip
                            resolveSuggestion()
                        }
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                Button {
                    Task { await save(allowFailure: false) }
                } label: {
                    Group {
                        if isSaving {
                            ProgressView()
                        } else {
                            Text("Save word")
                        }
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .foregroundStyle(.white)
                    .background(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? AppTheme.tertiaryInk : AppTheme.accent, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSaving)
                .padding(20)
                .pressable()
            }
            .onAppear { focused = true }
            .onChange(of: text) { _, _ in
                resolveSuggestion()
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    private func resolveSuggestion() {
        let extracted = WordExtractor.extractTerm(from: text)
        if extracted.sentence.isEmpty {
            suggestion = nil
        } else {
            suggestion = extracted.term
        }
    }

    private func save(allowFailure: Bool) async {
        isSaving = true
        errorMessage = nil
        let store = VocabularyStore(modelContext: modelContext)
        do {
            let entry: VocabularyEntry
            if allowFailure {
                entry = try store.saveWithoutAnalysis(raw: text)
            } else {
                entry = try await store.add(raw: text, source: source, note: note)
            }
            isSaving = false
            dismiss()
            onSaved(entry)
        } catch {
            isSaving = false
            errorMessage = "Couldn't analyze this word."
        }
    }
}
