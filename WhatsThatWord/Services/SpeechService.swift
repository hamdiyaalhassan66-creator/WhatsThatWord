import AVFoundation
import Foundation

@MainActor
final class SpeechService: ObservableObject {
    @Published var isSpeaking = false
    @Published var isSlow = false

    private let synthesizer = AVSpeechSynthesizer()

    func speak(_ text: String) {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
            isSpeaking = false
            return
        }
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = isSlow ? 0.32 : 0.46
        utterance.pitchMultiplier = 1.02
        isSpeaking = true
        synthesizer.speak(utterance)
        let duration = TimeInterval(max(1.2, Double(text.count) * (isSlow ? 0.14 : 0.09)))
        Task {
            try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
            if synthesizer.isSpeaking == false {
                isSpeaking = false
            } else {
                try? await Task.sleep(nanoseconds: 800_000_000)
                isSpeaking = synthesizer.isSpeaking
            }
        }
    }
}
