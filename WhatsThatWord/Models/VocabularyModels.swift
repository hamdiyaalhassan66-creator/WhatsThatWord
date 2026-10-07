import Foundation
import SwiftData

enum EntryKind: String, Codable, CaseIterable, Identifiable {
    case word
    case phrase
    case idiom
    case slang

    var id: String { rawValue }

    var title: String {
        switch self {
        case .word: "Word"
        case .phrase: "Phrase"
        case .idiom: "Idiom"
        case .slang: "Slang"
        }
    }
}

enum Difficulty: String, Codable, CaseIterable, Identifiable {
    case beginner
    case intermediate
    case advanced

    var id: String { rawValue }

    var title: String {
        switch self {
        case .beginner: "Beginner"
        case .intermediate: "Intermediate"
        case .advanced: "Advanced"
        }
    }
}

enum LearningStatus: String, Codable, CaseIterable, Identifiable {
    case new
    case learning
    case familiar
    case mastered

    var id: String { rawValue }

    var title: String {
        switch self {
        case .new: "New"
        case .learning: "Learning"
        case .familiar: "Familiar"
        case .mastered: "Mastered"
        }
    }

    var symbol: String {
        switch self {
        case .new: "sparkle"
        case .learning: "book"
        case .familiar: "hand.thumbsup"
        case .mastered: "checkmark.circle"
        }
    }
}

enum WordSource: String, Codable, CaseIterable, Identifiable {
    case manual = "Manually added"
    case imported = "Imported"
    case discovered = "Discovered"
    case book = "Book"
    case movie = "Movie"
    case podcast = "Podcast"
    case conversation = "Conversation"
    case article = "Article"
    case social = "Social media"
    case work = "Work"
    case other = "Other"

    var id: String { rawValue }
}

enum SortOrder: String, CaseIterable, Identifiable {
    case recentlyAdded
    case alphabetical
    case recentlyReviewed
    case difficulty
    case mastery

    var id: String { rawValue }

    var title: String {
        switch self {
        case .recentlyAdded: "Recently added"
        case .alphabetical: "Alphabetical"
        case .recentlyReviewed: "Recently reviewed"
        case .difficulty: "Difficulty"
        case .mastery: "Mastery"
        }
    }
}

struct ConversationTurn: Codable, Hashable, Identifiable {
    var id: UUID
    var speaker: String
    var line: String

    init(id: UUID = UUID(), speaker: String, line: String) {
        self.id = id
        self.speaker = speaker
        self.line = line
    }
}

struct ConversationExample: Codable, Hashable, Identifiable {
    var id: UUID
    var tone: String
    var turns: [ConversationTurn]
    var whyItWorks: String

    init(id: UUID = UUID(), tone: String, turns: [ConversationTurn], whyItWorks: String) {
        self.id = id
        self.tone = tone
        self.turns = turns
        self.whyItWorks = whyItWorks
    }
}

struct UsageRegister: Codable, Hashable, Identifiable {
    var id: UUID
    var register: String
    var example: String

    init(id: UUID = UUID(), register: String, example: String) {
        self.id = id
        self.register = register
        self.example = example
    }
}

struct RelatedWord: Codable, Hashable, Identifiable {
    var id: UUID
    var term: String
    var gloss: String

    init(id: UUID = UUID(), term: String, gloss: String) {
        self.id = id
        self.term = term
        self.gloss = gloss
    }
}

/// Structured analysis produced by a local catalog today, and by an AI service later.
struct WordAnalysis: Codable, Hashable {
    var pronunciation: String
    var phoneticSpelling: String
    var partOfSpeech: String
    var difficulty: Difficulty
    var definitionSimple: String
    var definitionDetailed: String
    var literalMeaning: String?
    var intendedMeaning: String?
    var synonymsSimple: [String]
    var synonymsIntermediate: [String]
    var synonymsAdvanced: [String]
    var antonymsSimple: [String]
    var antonymsIntermediate: [String]
    var antonymsAdvanced: [String]
    var examples: [String]
    var usageRegisters: [UsageRegister]
    var conversations: [ConversationExample]
    var whenToUse: [String]
    var whenNotToUse: [String]
    var everydayScenario: String
    var tone: String
    var frequency: String
    var origin: String
    var relatedWords: [RelatedWord]
    var isFallback: Bool

    static let empty = WordAnalysis(
        pronunciation: "",
        phoneticSpelling: "",
        partOfSpeech: "Word",
        difficulty: .intermediate,
        definitionSimple: "Saved. Open this card after analysis finishes.",
        definitionDetailed: "",
        literalMeaning: nil,
        intendedMeaning: nil,
        synonymsSimple: [],
        synonymsIntermediate: [],
        synonymsAdvanced: [],
        antonymsSimple: [],
        antonymsIntermediate: [],
        antonymsAdvanced: [],
        examples: [],
        usageRegisters: [],
        conversations: [],
        whenToUse: [],
        whenNotToUse: [],
        everydayScenario: "",
        tone: "",
        frequency: "",
        origin: "",
        relatedWords: [],
        isFallback: true
    )
}

@Model
final class VocabularyEntry {
    var entryID: UUID
    var term: String
    var kindRaw: String
    var analysisData: Data
    var userNote: String
    var originalSentence: String
    var sourceRaw: String
    var statusRaw: String
    var isFavorite: Bool
    var dateAdded: Date
    var lastReviewed: Date?
    var reviewCount: Int
    var masteryLevel: Int
    var analysisFailed: Bool

    init(
        id: UUID = UUID(),
        term: String,
        kind: EntryKind,
        analysis: WordAnalysis,
        userNote: String = "",
        originalSentence: String = "",
        source: WordSource = .manual,
        status: LearningStatus = .new,
        isFavorite: Bool = false,
        dateAdded: Date = .now,
        lastReviewed: Date? = nil,
        reviewCount: Int = 0,
        masteryLevel: Int = 0,
        analysisFailed: Bool = false
    ) {
        self.entryID = id
        self.term = term
        self.kindRaw = kind.rawValue
        self.analysisData = (try? JSONEncoder().encode(analysis)) ?? Data()
        self.userNote = userNote
        self.originalSentence = originalSentence
        self.sourceRaw = source.rawValue
        self.statusRaw = status.rawValue
        self.isFavorite = isFavorite
        self.dateAdded = dateAdded
        self.lastReviewed = lastReviewed
        self.reviewCount = reviewCount
        self.masteryLevel = masteryLevel
        self.analysisFailed = analysisFailed
    }

    var kind: EntryKind {
        get { EntryKind(rawValue: kindRaw) ?? .word }
        set { kindRaw = newValue.rawValue }
    }

    var status: LearningStatus {
        get { LearningStatus(rawValue: statusRaw) ?? .new }
        set { statusRaw = newValue.rawValue }
    }

    var source: WordSource {
        get { WordSource(rawValue: sourceRaw) ?? .manual }
        set { sourceRaw = newValue.rawValue }
    }

    var analysis: WordAnalysis {
        get { (try? JSONDecoder().decode(WordAnalysis.self, from: analysisData)) ?? .empty }
        set { analysisData = (try? JSONEncoder().encode(newValue)) ?? Data() }
    }

    var searchBlob: String {
        let a = analysis
        return ([
            term,
            a.definitionSimple,
            a.definitionDetailed,
            a.partOfSpeech,
            userNote,
            originalSentence
        ] + a.synonymsSimple + a.synonymsIntermediate + a.synonymsAdvanced)
        .joined(separator: " ")
        .lowercased()
    }

    var needsReview: Bool {
        if status == .mastered { return false }
        guard let lastReviewed else { return true }
        let days: Double = status == .familiar ? 5 : status == .learning ? 1 : 0
        return lastReviewed.addingTimeInterval(days * 86_400) <= .now
    }
}
