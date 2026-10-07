import Foundation
import SwiftData
import SwiftUI

@MainActor
final class VocabularyStore {
    let modelContext: ModelContext
    let analyzer: WordAnalysisServing

    init(modelContext: ModelContext, analyzer: WordAnalysisServing = LocalWordAnalysisService()) {
        self.modelContext = modelContext
        self.analyzer = analyzer
    }

    func seedIfNeeded() {
        let defaults = UserDefaults.standard
        guard defaults.bool(forKey: "didSeedSampleLibrary") == false else { return }

        let samples: [(String, LearningStatus, Bool, TimeInterval, String, WordSource)] = [
            ("ubiquitous", .learning, true, -2, "I heard this in a podcast today.", .podcast),
            ("nonchalant", .new, false, -0.3, "", .article),
            ("serendipity", .familiar, false, -6, "", .book),
            ("juxtaposition", .learning, false, -4, "From a design essay.", .article),
            ("ambiguous", .mastered, false, -20, "", .work),
            ("meticulous", .familiar, true, -8, "", .conversation),
            ("ineffable", .new, false, -1, "", .book),
            ("read between the lines", .learning, false, -3, "", .conversation),
            ("a blessing in disguise", .familiar, false, -12, "", .movie)
        ]

        for (term, status, favorite, daysAgo, note, source) in samples {
            guard let analysis = WordCatalog.analysis(for: term) else { continue }
            let entry = VocabularyEntry(
                term: displayTerm(term),
                kind: kind(for: term),
                analysis: analysis,
                userNote: note,
                originalSentence: analysis.examples.first ?? "",
                source: source,
                status: status,
                isFavorite: favorite,
                dateAdded: Date().addingTimeInterval(daysAgo * 86_400),
                lastReviewed: status == .new ? nil : Date().addingTimeInterval((daysAgo - 1) * 86_400),
                reviewCount: status == .new ? 0 : Int.random(in: 1...6),
                masteryLevel: status == .mastered ? 4 : status == .familiar ? 3 : status == .learning ? 1 : 0
            )
            modelContext.insert(entry)
        }
        try? modelContext.save()
        defaults.set(true, forKey: "didSeedSampleLibrary")
    }

    func add(raw: String, source: WordSource, note: String) async throws -> VocabularyEntry {
        let extracted = WordExtractor.extractTerm(from: raw)
        if let existing = find(term: extracted.term) {
            return existing
        }

        let kind = kind(for: extracted.term)
        let analysis = try await analyzer.analyze(term: extracted.term, surroundingText: extracted.sentence.isEmpty ? nil : extracted.sentence)
        let entry = VocabularyEntry(
            term: displayTerm(extracted.term),
            kind: kind,
            analysis: analysis,
            userNote: note,
            originalSentence: extracted.sentence,
            source: source,
            status: .new
        )
        modelContext.insert(entry)
        try modelContext.save()
        Haptics.save()
        return entry
    }

    func saveWithoutAnalysis(raw: String) throws -> VocabularyEntry {
        let extracted = WordExtractor.extractTerm(from: raw)
        let entry = VocabularyEntry(
            term: displayTerm(extracted.term),
            kind: kind(for: extracted.term),
            analysis: WordCatalog.fallback(for: extracted.term, surroundingText: extracted.sentence),
            originalSentence: extracted.sentence,
            analysisFailed: true
        )
        modelContext.insert(entry)
        try modelContext.save()
        return entry
    }

    func retryAnalysis(_ entry: VocabularyEntry) async throws {
        let analysis = try await analyzer.analyze(term: entry.term, surroundingText: entry.originalSentence.isEmpty ? nil : entry.originalSentence)
        entry.analysis = analysis
        entry.analysisFailed = analysis.isFallback
        try modelContext.save()
    }

    func delete(_ entry: VocabularyEntry) {
        modelContext.delete(entry)
        try? modelContext.save()
    }

    func recordReview(_ entry: VocabularyEntry, outcome: ReviewOutcome) {
        entry.reviewCount += 1
        entry.lastReviewed = .now
        switch outcome {
        case .knows:
            if entry.status == .new { entry.status = .learning }
            else if entry.status == .learning { entry.status = .familiar }
            else if entry.status == .familiar { entry.status = .mastered }
            entry.masteryLevel = min(4, entry.masteryLevel + 1)
            Haptics.success()
        case .learning:
            entry.status = .learning
            Haptics.light()
        case .forgot:
            entry.status = .learning
            entry.masteryLevel = max(0, entry.masteryLevel - 1)
            Haptics.warning()
        }
        try? modelContext.save()
    }

    func find(term: String) -> VocabularyEntry? {
        let key = term.lowercased()
        let all = (try? modelContext.fetch(FetchDescriptor<VocabularyEntry>())) ?? []
        return all.first { $0.term.lowercased() == key }
    }

    private func displayTerm(_ term: String) -> String {
        if term.contains(" ") { return term.lowercased() }
        return term.lowercased().capitalized
    }

    private func kind(for term: String) -> EntryKind {
        let key = term.lowercased()
        if key == "a blessing in disguise" { return .idiom }
        if key.contains(" ") { return .phrase }
        return .word
    }
}

enum ReviewOutcome {
    case knows, learning, forgot
}

@MainActor
final class AppSettings: ObservableObject {
    @AppStorage("hasOnboarded") var hasOnboarded = false
    @AppStorage("appearance") var appearance = "system"
    @AppStorage("dailyWordEnabled") var dailyWordEnabled = true
    @AppStorage("reviewReminders") var reviewReminders = true
    @AppStorage("notificationsEnabled") var notificationsEnabled = false
    @AppStorage("streak") var streak = 7
    @AppStorage("lastReviewDay") var lastReviewDay = ""

    var colorScheme: ColorScheme? {
        switch appearance {
        case "light": .light
        case "dark": .dark
        default: nil
        }
    }

    func markReviewedToday() {
        let today = ISO8601DateFormatter().string(from: Calendar.current.startOfDay(for: .now))
        if lastReviewDay != today {
            streak += 1
            lastReviewDay = today
        }
    }
}
