import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var settings: AppSettings
    @State private var page = 0
    @State private var selectedInterests: Set<String> = []

    private let interests = [
        "Everyday vocabulary",
        "Professional communication",
        "Academic vocabulary",
        "Writing",
        "Reading",
        "Speaking",
        "Just curious"
    ]

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $page) {
                OnboardPage(
                    symbol: "bookmark.fill",
                    title: "Words worth remembering.",
                    bodyText: "Save unfamiliar words and turn them into words you actually know."
                )
                .tag(0)

                OnboardPage(
                    symbol: "text.bubble.fill",
                    title: "Understand more than the definition.",
                    bodyText: "See synonyms, antonyms, examples, and how people actually say it."
                )
                .tag(1)

                OnboardPage(
                    symbol: "leaf.fill",
                    title: "Build your vocabulary over time.",
                    bodyText: "Review the words you've collected and learn to use them naturally."
                )
                .tag(2)

                interestPage
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            HStack(spacing: 6) {
                ForEach(0..<4, id: \.self) { index in
                    Capsule()
                        .fill(index == page ? AppTheme.accent : AppTheme.hairline)
                        .frame(width: index == page ? 18 : 6, height: 6)
                }
            }
            .padding(.bottom, 20)
            .animation(Motion.quick, value: page)

            Button(page < 3 ? "Continue" : "Get started") {
                if page < 3 {
                    withAnimation(Motion.sheet) { page += 1 }
                } else {
                    settings.hasOnboarded = true
                    Haptics.success()
                }
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .foregroundStyle(.white)
            .background(AppTheme.accent, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(.horizontal, 24)
            .padding(.bottom, 12)
            .pressable()

            if page == 3 {
                Button("Skip for now") {
                    settings.hasOnboarded = true
                }
                .font(.subheadline)
                .foregroundStyle(AppTheme.secondaryInk)
                .padding(.bottom, 20)
            } else {
                Color.clear.frame(height: 44)
            }
        }
        .paperBackground()
    }

    private var interestPage: some View {
        VStack(alignment: .leading, spacing: 16) {
            Spacer(minLength: 40)
            Text("What are you interested in improving?")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(AppTheme.ink)
                .tracking(-0.6)
            Text("Optional. This just helps the app feel like yours.")
                .font(.body)
                .foregroundStyle(AppTheme.secondaryInk)
            FlexibleInterestWrap(items: interests, selected: $selectedInterests)
            Spacer()
        }
        .padding(.horizontal, 28)
    }
}

struct OnboardPage: View {
    let symbol: String
    let title: String
    let bodyText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Spacer()
            Image(systemName: symbol)
                .font(.system(size: 40, weight: .semibold))
                .foregroundStyle(AppTheme.accent)
            Text(title)
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(AppTheme.ink)
                .tracking(-0.8)
                .lineSpacing(2)
            Text(bodyText)
                .font(.title3)
                .foregroundStyle(AppTheme.secondaryInk)
                .lineSpacing(6)
            Spacer()
            Spacer()
        }
        .padding(.horizontal, 28)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct FlexibleInterestWrap: View {
    let items: [String]
    @Binding var selected: Set<String>

    var body: some View {
        ChipWrapLayout {
            ForEach(items, id: \.self) { item in
                let on = selected.contains(item)
                Button {
                    if on { selected.remove(item) } else { selected.insert(item) }
                    Haptics.light()
                } label: {
                    Text(item)
                        .font(.subheadline.weight(.medium))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .foregroundStyle(on ? Color.white : AppTheme.ink)
                        .background(on ? AppTheme.accent : AppTheme.elevated, in: Capsule())
                        .overlay(Capsule().strokeBorder(AppTheme.hairline, lineWidth: on ? 0 : 1))
                }
                .pressable()
            }
        }
    }
}
