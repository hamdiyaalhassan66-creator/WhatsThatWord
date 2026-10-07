import SwiftData
import SwiftUI

#Preview("Onboarding") {
    OnboardingView()
        .environmentObject(AppSettings())
}

#Preview("Word detail") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: VocabularyEntry.self, configurations: config)
    let analysis = WordCatalog.analysis(for: "ubiquitous")!
    let entry = VocabularyEntry(
        term: "Ubiquitous",
        kind: .word,
        analysis: analysis,
        userNote: "I heard this in a podcast today.",
        originalSentence: "Technology has become ubiquitous in modern life.",
        source: .podcast,
        status: .learning,
        isFavorite: true
    )
    container.mainContext.insert(entry)
    return NavigationStack {
        WordDetailView(entry: entry)
    }
    .modelContainer(container)
}
