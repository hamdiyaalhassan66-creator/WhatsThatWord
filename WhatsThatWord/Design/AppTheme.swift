import SwiftUI

enum AppTheme {
    static let accent = Color("AccentColor")

    static let paper = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.11, green: 0.10, blue: 0.09, alpha: 1)
            : UIColor(red: 0.969, green: 0.957, blue: 0.937, alpha: 1)
    })

    static let elevated = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.165, green: 0.153, blue: 0.141, alpha: 1)
            : UIColor.white
    })

    static let ink = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.96, green: 0.94, blue: 0.90, alpha: 1)
            : UIColor(red: 0.145, green: 0.125, blue: 0.106, alpha: 1)
    })

    static let secondaryInk = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.72, green: 0.68, blue: 0.63, alpha: 1)
            : UIColor(red: 0.42, green: 0.38, blue: 0.34, alpha: 1)
    })

    static let tertiaryInk = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.52, green: 0.49, blue: 0.45, alpha: 1)
            : UIColor(red: 0.58, green: 0.54, blue: 0.50, alpha: 1)
    })

    static let noteWash = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.22, green: 0.19, blue: 0.14, alpha: 1)
            : UIColor(red: 0.98, green: 0.94, blue: 0.86, alpha: 1)
    })

    static let hairline = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.08)
            : UIColor.black.withAlphaComponent(0.08)
    })
}

enum Motion {
    static let quick = Animation.spring(response: 0.32, dampingFraction: 1.0)
    static let sheet = Animation.spring(response: 0.38, dampingFraction: 0.86)
    static let card = Animation.spring(response: 0.42, dampingFraction: 0.92)
}

extension View {
    func paperBackground() -> some View {
        background(AppTheme.paper.ignoresSafeArea())
    }

    func elevatedCard() -> some View {
        background(AppTheme.elevated, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(AppTheme.hairline, lineWidth: 1)
            )
    }

    func pressable() -> some View {
        buttonStyle(PressableButtonStyle())
    }
}

struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.86 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

enum Haptics {
    static func save() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
}
