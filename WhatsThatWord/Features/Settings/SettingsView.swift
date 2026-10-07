import SwiftData
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var settings: AppSettings
    @Query(sort: \VocabularyEntry.dateAdded) private var words: [VocabularyEntry]
    @State private var exportPayload: ExportPayload?

    var body: some View {
        NavigationStack {
            List {
                Section("Preferences") {
                    Picker("Appearance", selection: $settings.appearance) {
                        Text("System").tag("system")
                        Text("Light").tag("light")
                        Text("Dark").tag("dark")
                    }
                    Toggle("Notifications", isOn: $settings.notificationsEnabled)
                    Toggle("Daily word", isOn: $settings.dailyWordEnabled)
                    Toggle("Review reminders", isOn: $settings.reviewReminders)
                }

                Section("Learning") {
                    Text("Review when a word is due. Mastered words stay out of the queue unless you bring them back.")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.secondaryInk)
                    Button("Replay onboarding") {
                        settings.hasOnboarded = false
                    }
                }

                Section("Data") {
                    Button("Export as JSON") { exportPayload = .json(words) }
                    Button("Export as CSV") { exportPayload = .csv(words) }
                    Button("Export as plain text") { exportPayload = .text(words) }
                    ShareLink("Share a backup", item: exportDocument)
                }

                Section("About") {
                    LabeledContent("App", value: "What's That Word?")
                    LabeledContent("Privacy", value: "Words stay on this device.")
                    Text("A personal notebook for words you didn’t know — and how people actually use them.")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.secondaryInk)
                }
            }
            .scrollContentBackground(.hidden)
            .paperBackground()
            .navigationTitle("Settings")
            .sheet(item: $exportPayload) { payload in
                ShareSheet(items: [payload.body])
            }
        }
    }

    private var exportDocument: String {
        ExportPayload.json(words).body
    }
}

struct ExportPayload: Identifiable {
    let id = UUID()
    let body: String

    static func json(_ words: [VocabularyEntry]) -> ExportPayload {
        let rows = words.map {
            [
                "term": $0.term,
                "definition": $0.analysis.definitionSimple,
                "notes": $0.userNote,
                "status": $0.status.title,
                "dateAdded": ISO8601DateFormatter().string(from: $0.dateAdded)
            ]
        }
        let data = (try? JSONSerialization.data(withJSONObject: rows, options: .prettyPrinted)) ?? Data()
        return ExportPayload(body: String(data: data, encoding: .utf8) ?? "[]")
    }

    static func csv(_ words: [VocabularyEntry]) -> ExportPayload {
        var lines = ["Word,Definition,Notes,Status,Date added"]
        for word in words {
            let def = word.analysis.definitionSimple.replacingOccurrences(of: "\"", with: "\"\"")
            let note = word.userNote.replacingOccurrences(of: "\"", with: "\"\"")
            lines.append("\"\(word.term)\",\"\(def)\",\"\(note)\",\(word.status.title),\(word.dateAdded.formatted(date: .abbreviated, time: .omitted))")
        }
        return ExportPayload(body: lines.joined(separator: "\n"))
    }

    static func text(_ words: [VocabularyEntry]) -> ExportPayload {
        let body = words.map { word in
            "\(word.term)\n\(word.analysis.definitionSimple)\n\(word.userNote)\n\(word.status.title)\n"
        }.joined(separator: "\n")
        return ExportPayload(body: body)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
