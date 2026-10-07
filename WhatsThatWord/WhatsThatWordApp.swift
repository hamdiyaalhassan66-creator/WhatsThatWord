import SwiftData
import SwiftUI

@main
struct WhatsThatWordApp: App {
    @StateObject private var settings = AppSettings()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(settings)
                .preferredColorScheme(settings.colorScheme)
                .tint(AppTheme.accent)
        }
        .modelContainer(for: VocabularyEntry.self)
    }
}

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var settings: AppSettings
    @State private var didSeed = false

    var body: some View {
        Group {
            if settings.hasOnboarded {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .onAppear {
            guard didSeed == false else { return }
            VocabularyStore(modelContext: modelContext).seedIfNeeded()
            didSeed = true
        }
    }
}
