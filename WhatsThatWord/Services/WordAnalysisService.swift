import Foundation

protocol WordAnalysisServing: Sendable {
    func analyze(term: String, surroundingText: String?) async throws -> WordAnalysis
}

enum AnalysisError: LocalizedError {
    case failed

    var errorDescription: String? {
        "Couldn't analyze this word."
    }
}

/// Local, replaceable analysis layer. Swap this type for a network AI client later.
struct LocalWordAnalysisService: WordAnalysisServing {
    func analyze(term: String, surroundingText: String?) async throws -> WordAnalysis {
        try await Task.sleep(nanoseconds: 280_000_000)
        let cleaned = term.trimmingCharacters(in: .whitespacesAndNewlines)
        if let match = WordCatalog.analysis(for: cleaned) {
            return match
        }
        return WordCatalog.fallback(for: cleaned, surroundingText: surroundingText)
    }
}

enum WordExtractor {
    static let stopwords: Set<String> = [
        "the", "a", "an", "and", "or", "but", "if", "in", "on", "at", "to", "for",
        "of", "with", "by", "from", "as", "is", "are", "was", "were", "be", "been",
        "it", "this", "that", "these", "those", "i", "you", "he", "she", "we", "they",
        "her", "his", "their", "our", "my", "your", "not", "didn't", "dont", "don't",
        "like", "seem", "seems", "made", "make", "did", "does", "have", "has", "had"
    ]

    static func extractTerm(from raw: String) -> (term: String, sentence: String) {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.split(whereSeparator: \.isWhitespace).count <= 4 {
            return (trimmed, "")
        }

        let lowered = trimmed.lowercased()
        if let known = WordCatalog.allTerms.first(where: { lowered.contains($0.lowercased()) }) {
            return (known, trimmed)
        }

        let tokens = trimmed
            .split { !$0.isLetter && $0 != "'" && $0 != "-" }
            .map(String.init)
            .filter { $0.count > 3 && !stopwords.contains($0.lowercased()) }

        let pick = tokens.max(by: { $0.count < $1.count }) ?? trimmed
        return (pick, trimmed)
    }
}
