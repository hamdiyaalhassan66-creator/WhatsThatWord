import Foundation

enum WordCatalog {
    static var allTerms: [String] { analyses.keys.sorted() }

    static func analysis(for term: String) -> WordAnalysis? {
        let key = normalize(term)
        return analyses[key]
    }

    static func fallback(for term: String, surroundingText: String?) -> WordAnalysis {
        let isPhrase = term.contains(" ")
        return WordAnalysis(
            pronunciation: "",
            phoneticSpelling: approximatePhonetic(term),
            partOfSpeech: isPhrase ? "Phrase" : "Word",
            difficulty: term.count > 10 ? .advanced : .intermediate,
            definitionSimple: "A saved word from your reading. A richer analysis can fill this in later.",
            definitionDetailed: surroundingText.map { "Captured from: \($0)" } ?? "No extra context was saved.",
            literalMeaning: isPhrase ? term : nil,
            intendedMeaning: isPhrase ? "Meaning depends on how you heard it." : nil,
            synonymsSimple: [],
            synonymsIntermediate: [],
            synonymsAdvanced: [],
            antonymsSimple: [],
            antonymsIntermediate: [],
            antonymsAdvanced: [],
            examples: surroundingText.map { [$0] } ?? [],
            usageRegisters: [],
            conversations: [],
            whenToUse: ["When this word matches the situation you saved it from."],
            whenNotToUse: ["Don't force it into a sentence just to use it."],
            everydayScenario: "You noticed this in the wild. That's the best reason to keep it.",
            tone: "Unknown",
            frequency: "Unknown",
            origin: "",
            relatedWords: [],
            isFallback: true
        )
    }

    static let wordOfTheDay = WordAnalysis(
        pronunciation: "ih-FEM-er-uhl",
        phoneticSpelling: "/ɪˈfɛmərəl/",
        partOfSpeech: "Adjective",
        difficulty: .intermediate,
        definitionSimple: "Lasting for a very short time.",
        definitionDetailed: "Something ephemeral exists briefly and then is gone — a mood, a trend, a moment.",
        literalMeaning: nil,
        intendedMeaning: nil,
        synonymsSimple: ["short-lived", "brief", "temporary"],
        synonymsIntermediate: ["fleeting", "transient"],
        synonymsAdvanced: ["evanescent"],
        antonymsSimple: ["lasting", "permanent"],
        antonymsIntermediate: ["enduring"],
        antonymsAdvanced: ["perpetual"],
        examples: ["Sunset colors are beautiful and ephemeral."],
        usageRegisters: [
            UsageRegister(register: "Casual conversation", example: "That trend was pretty ephemeral."),
            UsageRegister(register: "Work", example: "We shouldn't build process around ephemeral spikes in traffic."),
            UsageRegister(register: "Writing", example: "Joy can be ephemeral without being any less real.")
        ],
        conversations: [
            ConversationExample(
                tone: "Casual",
                turns: [
                    ConversationTurn(speaker: "Maya", line: "I already miss that little café."),
                    ConversationTurn(speaker: "Jordan", line: "Same. Places like that can feel so ephemeral.")
                ],
                whyItWorks: "You're talking about something that didn't last, not something that failed."
            )
        ],
        whenToUse: ["When something is genuinely brief", "When the shortness is part of the point"],
        whenNotToUse: ["For things that are simply unpopular", "For a schedule delay"],
        everydayScenario: "A conversation, a fashion, a feeling that was here and then wasn't.",
        tone: "Neutral / slightly literary",
        frequency: "Uncommon in speech, common in writing",
        origin: "Greek",
        relatedWords: [
            RelatedWord(term: "Ephemera", gloss: "Things meant to last only a short time"),
            RelatedWord(term: "Transient", gloss: "Passing through; not lasting")
        ],
        isFallback: false
    )

    private static func normalize(_ term: String) -> String {
        term.trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .trimmingCharacters(in: CharacterSet(charactersIn: "\"“”'"))
    }

    private static func approximatePhonetic(_ term: String) -> String {
        "/\(term.lowercased())/"
    }

    static let analyses: [String: WordAnalysis] = [
        "ubiquitous": ubiquitous,
        "nonchalant": nonchalant,
        "serendipity": serendipity,
        "juxtaposition": juxtaposition,
        "ambiguous": ambiguous,
        "meticulous": meticulous,
        "ineffable": ineffable,
        "read between the lines": readBetween,
        "\"read between the lines\"": readBetween,
        "a blessing in disguise": blessing,
        "\"a blessing in disguise\"": blessing,
        "ephemeral": wordOfTheDay
    ]

    private static let ubiquitous = WordAnalysis(
        pronunciation: "yoo-BIK-wih-tuhs",
        phoneticSpelling: "/juːˈbɪkwɪtəs/",
        partOfSpeech: "Adjective",
        difficulty: .advanced,
        definitionSimple: "Something that is everywhere, or seems to be everywhere.",
        definitionDetailed: "Present, appearing, or found in many places or situations at the same time.",
        literalMeaning: nil,
        intendedMeaning: nil,
        synonymsSimple: ["common", "everywhere", "widespread"],
        synonymsIntermediate: ["prevalent", "pervasive"],
        synonymsAdvanced: ["omnipresent", "universal"],
        antonymsSimple: ["rare", "uncommon"],
        antonymsIntermediate: ["scarce", "limited"],
        antonymsAdvanced: ["exceptional"],
        examples: [
            "Smartphones are pretty much ubiquitous these days.",
            "The influence of social media has become ubiquitous."
        ],
        usageRegisters: [
            UsageRegister(register: "Casual conversation", example: "Smartphones are pretty much ubiquitous these days."),
            UsageRegister(register: "Work", example: "Email is ubiquitous across most companies."),
            UsageRegister(register: "Writing", example: "The influence of social media has become ubiquitous."),
            UsageRegister(register: "Texting", example: "wifi is ubiquitous here, thankfully")
        ],
        conversations: [
            ConversationExample(
                tone: "Casual",
                turns: [
                    ConversationTurn(speaker: "Alex", line: "Why are there so many coffee shops around here?"),
                    ConversationTurn(speaker: "Sam", line: "Coffee shops are pretty ubiquitous in this neighborhood.")
                ],
                whyItWorks: "You're describing something that appears almost everywhere — not just something popular."
            ),
            ConversationExample(
                tone: "Professional",
                turns: [
                    ConversationTurn(speaker: "Priya", line: "Do we still need a separate chat tool?"),
                    ConversationTurn(speaker: "Owen", line: "I'd keep it. Instant messaging is ubiquitous for this kind of work now.")
                ],
                whyItWorks: "It sounds measured at work when you're naming a pattern, not complaining."
            ),
            ConversationExample(
                tone: "Formal",
                turns: [
                    ConversationTurn(speaker: "Chair", line: "How would you describe the technology's reach?"),
                    ConversationTurn(speaker: "Speaker", line: "It has become ubiquitous in daily life, across both public and private settings.")
                ],
                whyItWorks: "Formal speech can carry the word without extra slang around it."
            )
        ],
        whenToUse: [
            "Something is extremely common",
            "You see it in almost every place or situation",
            "Presence across many contexts is the point"
        ],
        whenNotToUse: [
            "When something is merely popular",
            "When something is famous",
            "When something is used often, but not everywhere"
        ],
        everydayScenario: "If something is ubiquitous, you see it almost everywhere you look.",
        tone: "Neutral / slightly formal",
        frequency: "Common in writing, less common in casual speech",
        origin: "Latin",
        relatedWords: [
            RelatedWord(term: "Ubiquity", gloss: "The state of being everywhere"),
            RelatedWord(term: "Ubiquitously", gloss: "In a way that is everywhere")
        ],
        isFallback: false
    )

    private static let nonchalant = WordAnalysis(
        pronunciation: "non-shuh-LAHNT",
        phoneticSpelling: "/ˌnɒnʃəˈlɑːnt/",
        partOfSpeech: "Adjective",
        difficulty: .intermediate,
        definitionSimple: "Calm, relaxed, and apparently not worried — sometimes a little too casual.",
        definitionDetailed: "Feeling or appearing casually calm and relaxed; not displaying anxiety, interest, or enthusiasm.",
        literalMeaning: nil,
        intendedMeaning: nil,
        synonymsSimple: ["casual", "relaxed", "unbothered"],
        synonymsIntermediate: ["unconcerned", "easygoing"],
        synonymsAdvanced: ["insouciant", "blithe"],
        antonymsSimple: ["anxious", "nervous"],
        antonymsIntermediate: ["eager", "intense"],
        antonymsAdvanced: ["solicitous"],
        examples: [
            "She gave a nonchalant shrug and kept walking.",
            "His nonchalant attitude made it seem like he didn't care."
        ],
        usageRegisters: [
            UsageRegister(register: "Casual conversation", example: "He was so nonchalant about the whole thing."),
            UsageRegister(register: "Work", example: "Try not to sound nonchalant in the client meeting — they need to feel we care."),
            UsageRegister(register: "Writing", example: "She answered with a nonchalant wave, as if the news barely registered."),
            UsageRegister(register: "Texting", example: "he was weirdly nonchalant about missing the flight")
        ],
        conversations: [
            ConversationExample(
                tone: "Casual",
                turns: [
                    ConversationTurn(speaker: "Rae", line: "Did you see Maya after the interview?"),
                    ConversationTurn(speaker: "Chris", line: "Yeah. Completely nonchalant. Like it was a coffee run.")
                ],
                whyItWorks: "You're naming a vibe — calm on the surface — not saying she did a good job."
            ),
            ConversationExample(
                tone: "Professional",
                turns: [
                    ConversationTurn(speaker: "Dana", line: "The outage lasted twenty minutes."),
                    ConversationTurn(speaker: "Lee", line: "We shouldn't be nonchalant about that in the write-up.")
                ],
                whyItWorks: "At work it often means 'don't downplay this,' which is a natural, adult use."
            )
        ],
        whenToUse: [
            "Someone looks unworried on purpose or by habit",
            "The calmness is noticeable, even a little striking",
            "You want to describe attitude, not skill"
        ],
        whenNotToUse: [
            "When someone is simply polite",
            "When someone is professionally composed in a normal way",
            "As a compliment for being prepared"
        ],
        everydayScenario: "The person who hears surprising news and just says 'oh' and keeps scrolling.",
        tone: "Neutral, can be slightly critical",
        frequency: "Fairly common",
        origin: "French",
        relatedWords: [
            RelatedWord(term: "Nonchalance", gloss: "The quality of being unconcerned"),
            RelatedWord(term: "Casual", gloss: "Relaxed, but less pointed")
        ],
        isFallback: false
    )

    private static let serendipity = WordAnalysis(
        pronunciation: "ser-uhn-DIP-ih-tee",
        phoneticSpelling: "/ˌsɛrənˈdɪpɪti/",
        partOfSpeech: "Noun",
        difficulty: .intermediate,
        definitionSimple: "A happy accident — finding something good you weren't looking for.",
        definitionDetailed: "The occurrence of a valuable or pleasant discovery by chance.",
        literalMeaning: nil,
        intendedMeaning: nil,
        synonymsSimple: ["lucky find", "happy accident"],
        synonymsIntermediate: ["chance", "fluke"],
        synonymsAdvanced: ["fortuity", "happenstance"],
        antonymsSimple: ["planning", "intention"],
        antonymsIntermediate: ["design"],
        antonymsAdvanced: ["premeditation"],
        examples: [
            "Meeting her in that tiny bookstore was pure serendipity.",
            "Some of the best recipes come from serendipity in the kitchen."
        ],
        usageRegisters: [
            UsageRegister(register: "Casual conversation", example: "Total serendipity that we were on the same train."),
            UsageRegister(register: "Work", example: "That partnership was serendipity more than strategy."),
            UsageRegister(register: "Writing", example: "The novel treats grief and serendipity as neighbors.")
        ],
        conversations: [
            ConversationExample(
                tone: "Casual",
                turns: [
                    ConversationTurn(speaker: "Noor", line: "How did you even find this place?"),
                    ConversationTurn(speaker: "Eli", line: "Serendipity. I took a wrong turn and smelled bread.")
                ],
                whyItWorks: "It names a lucky discovery without making a speech about fate."
            )
        ],
        whenToUse: [
            "The good outcome was unplanned",
            "Chance did the interesting work",
            "You want a warmer word than 'luck'"
        ],
        whenNotToUse: [
            "When someone worked hard for the result",
            "For bad surprises",
            "As a vague stand-in for 'nice'"
        ],
        everydayScenario: "You duck into a shop to avoid rain and find the exact book you needed.",
        tone: "Warm / slightly literary",
        frequency: "Common enough to feel natural",
        origin: "English, from a fairy tale",
        relatedWords: [
            RelatedWord(term: "Serendipitous", gloss: "Happening by happy chance"),
            RelatedWord(term: "Fortunate", gloss: "Lucky, but less about discovery")
        ],
        isFallback: false
    )

    private static let juxtaposition = WordAnalysis(
        pronunciation: "juk-stuh-puh-ZISH-uhn",
        phoneticSpelling: "/ˌdʒʌkstəpəˈzɪʃən/",
        partOfSpeech: "Noun",
        difficulty: .advanced,
        definitionSimple: "Placing two things side by side so the contrast (or surprise) is obvious.",
        definitionDetailed: "The fact of two things being seen or placed close together with contrasting effect.",
        literalMeaning: nil,
        intendedMeaning: nil,
        synonymsSimple: ["contrast", "side-by-side"],
        synonymsIntermediate: ["comparison", "pairing"],
        synonymsAdvanced: ["apposition", "collocation"],
        antonymsSimple: ["separation"],
        antonymsIntermediate: ["isolation"],
        antonymsAdvanced: ["uniformity"],
        examples: [
            "The photo's power is in the juxtaposition of wealth and hunger.",
            "The film uses juxtaposition instead of explaining the joke."
        ],
        usageRegisters: [
            UsageRegister(register: "Casual conversation", example: "The juxtaposition of that tiny house and the skyscraper is wild."),
            UsageRegister(register: "Work", example: "Let's look at the juxtaposition of last year's spend and this quarter's results."),
            UsageRegister(register: "Writing", example: "The poem lives in the juxtaposition of tenderness and threat.")
        ],
        conversations: [
            ConversationExample(
                tone: "Casual",
                turns: [
                    ConversationTurn(speaker: "Mina", line: "Why does this album artwork work so well?"),
                    ConversationTurn(speaker: "Theo", line: "It's the juxtaposition — kids' handwriting over a very adult photograph.")
                ],
                whyItWorks: "You're pointing at a design choice, not showing off a vocabulary word."
            )
        ],
        whenToUse: [
            "Two things are placed together on purpose",
            "The contrast is the interesting part",
            "You're talking about art, writing, photos, or ideas"
        ],
        whenNotToUse: [
            "When things are merely different",
            "When nothing is being compared on purpose",
            "As a fancy synonym for 'mix'"
        ],
        everydayScenario: "A luxury ad filmed in a crumbling alley. The point is the clash.",
        tone: "Intellectual, usable in serious conversation",
        frequency: "More common in writing and critique",
        origin: "Latin via French",
        relatedWords: [
            RelatedWord(term: "Juxtapose", gloss: "To place side by side for contrast"),
            RelatedWord(term: "Contrast", gloss: "The difference itself")
        ],
        isFallback: false
    )

    private static let ambiguous = WordAnalysis(
        pronunciation: "am-BIG-yoo-uhs",
        phoneticSpelling: "/æmˈbɪɡjuəs/",
        partOfSpeech: "Adjective",
        difficulty: .intermediate,
        definitionSimple: "Unclear — it could mean more than one thing.",
        definitionDetailed: "Open to more than one interpretation; not having one obvious meaning.",
        literalMeaning: nil,
        intendedMeaning: nil,
        synonymsSimple: ["unclear", "vague"],
        synonymsIntermediate: ["equivocal", "indefinite"],
        synonymsAdvanced: ["polysemous"],
        antonymsSimple: ["clear", "obvious"],
        antonymsIntermediate: ["explicit", "definite"],
        antonymsAdvanced: ["unequivocal"],
        examples: [
            "The ending was deliberately ambiguous.",
            "Don't send an ambiguous deadline to the client."
        ],
        usageRegisters: [
            UsageRegister(register: "Casual conversation", example: "That text was so ambiguous. Are they free or not?"),
            UsageRegister(register: "Work", example: "The requirements are still ambiguous, so I don't want to estimate yet."),
            UsageRegister(register: "Writing", example: "She prefers an ambiguous ending to a tidy moral.")
        ],
        conversations: [
            ConversationExample(
                tone: "Casual",
                turns: [
                    ConversationTurn(speaker: "Jess", line: "Did they invite us or not?"),
                    ConversationTurn(speaker: "Omar", line: "The message is ambiguous. 'You should come if you can' is doing a lot of work.")
                ],
                whyItWorks: "Everyday speech uses it for mixed signals, not only for literature."
            )
        ],
        whenToUse: [
            "Meaning is genuinely split",
            "Someone left wiggle room on purpose or by accident",
            "Clarity is the missing piece"
        ],
        whenNotToUse: [
            "When something is simply unknown",
            "When someone is lying",
            "When the problem is volume of information, not double meaning"
        ],
        everydayScenario: "A calendar invite with no time zone. Two reasonable readings, both wrong for someone.",
        tone: "Neutral",
        frequency: "Common",
        origin: "Latin",
        relatedWords: [
            RelatedWord(term: "Ambiguity", gloss: "The quality of having more than one meaning"),
            RelatedWord(term: "Vague", gloss: "Unclear, but not always double-meaning")
        ],
        isFallback: false
    )

    private static let meticulous = WordAnalysis(
        pronunciation: "muh-TIK-yuh-luhs",
        phoneticSpelling: "/məˈtɪkjʊləs/",
        partOfSpeech: "Adjective",
        difficulty: .intermediate,
        definitionSimple: "Extremely careful about small details.",
        definitionDetailed: "Showing great attention to detail; very careful and precise.",
        literalMeaning: nil,
        intendedMeaning: nil,
        synonymsSimple: ["careful", "thorough", "picky"],
        synonymsIntermediate: ["precise", "fastidious"],
        synonymsAdvanced: ["punctilious", "scrupulous"],
        antonymsSimple: ["sloppy", "careless"],
        antonymsIntermediate: ["hasty", "rough"],
        antonymsAdvanced: ["slapdash"],
        examples: [
            "She's meticulous about how the table is set.",
            "The report is meticulous — every number has a source."
        ],
        usageRegisters: [
            UsageRegister(register: "Casual conversation", example: "He's meticulous with packing. There's a list for the list."),
            UsageRegister(register: "Work", example: "We need someone meticulous on the contract language."),
            UsageRegister(register: "Writing", example: "The painter is meticulous, almost stubborn, about light.")
        ],
        conversations: [
            ConversationExample(
                tone: "Professional",
                turns: [
                    ConversationTurn(speaker: "Asha", line: "Who should review the numbers?"),
                    ConversationTurn(speaker: "Ben", line: "Give it to Camille. She's meticulous, and this can't be 'close enough.'")
                ],
                whyItWorks: "It's a genuine compliment at work when accuracy actually matters."
            )
        ],
        whenToUse: [
            "Care about details is the notable trait",
            "Precision is a virtue in the situation",
            "You're praising method, not personality in general"
        ],
        whenNotToUse: [
            "When someone is simply slow",
            "When someone is controlling",
            "As a polite way to say 'annoying'"
        ],
        everydayScenario: "The friend who aligns the labels on spice jars — and the spreadsheet that never has a stray comma.",
        tone: "Usually positive",
        frequency: "Common",
        origin: "Latin",
        relatedWords: [
            RelatedWord(term: "Meticulously", gloss: "In a carefully detailed way"),
            RelatedWord(term: "Thorough", gloss: "Complete, a little less about tiny details")
        ],
        isFallback: false
    )

    private static let ineffable = WordAnalysis(
        pronunciation: "in-EF-uh-buhl",
        phoneticSpelling: "/ɪnˈɛfəbəl/",
        partOfSpeech: "Adjective",
        difficulty: .advanced,
        definitionSimple: "Too big, strange, or moving to put into words.",
        definitionDetailed: "Too great or extreme to be expressed or described in words.",
        literalMeaning: nil,
        intendedMeaning: nil,
        synonymsSimple: ["indescribable", "beyond words"],
        synonymsIntermediate: ["unspeakable", "inexpressible"],
        synonymsAdvanced: ["transcendent"],
        antonymsSimple: ["ordinary", "describable"],
        antonymsIntermediate: ["mundane"],
        antonymsAdvanced: ["articulated"],
        examples: [
            "There was an ineffable quiet after the music stopped.",
            "Some grief is ineffable, and talking around it is the honest thing."
        ],
        usageRegisters: [
            UsageRegister(register: "Casual conversation", example: "The view had this ineffable quality. I sounded ridiculous trying to text it."),
            UsageRegister(register: "Writing", example: "The novel reaches for ineffable feeling and, for once, gets close."),
            UsageRegister(register: "Formal", example: "The ceremony carried an ineffable sense of continuity.")
        ],
        conversations: [
            ConversationExample(
                tone: "Casual",
                turns: [
                    ConversationTurn(speaker: "June", line: "How was the last night of the tour?"),
                    ConversationTurn(speaker: "Ari", line: "Ineffable, honestly. If I try to explain it I'll make it smaller.")
                ],
                whyItWorks: "You're admitting language failed, which is the actual meaning — not 'very nice.'"
            )
        ],
        whenToUse: [
            "Words feel too small on purpose",
            "Emotion or atmosphere is the subject",
            "You want restraint, not hype"
        ],
        whenNotToUse: [
            "As a fancy 'amazing'",
            "For things that are simply hard to spell",
            "In a status report"
        ],
        everydayScenario: "Holding a newborn, or standing in a place that hushes you. You stop mid-sentence.",
        tone: "Literary / sincere",
        frequency: "Rare in casual speech",
        origin: "Latin",
        relatedWords: [
            RelatedWord(term: "Ineffably", gloss: "In a way that can't be put into words"),
            RelatedWord(term: "Sublime", gloss: "Awe that exceeds ordinary description")
        ],
        isFallback: false
    )

    private static let readBetween = WordAnalysis(
        pronunciation: "reed bih-TWEEN thuh lynz",
        phoneticSpelling: "/riːd bɪˈtwiːn ðə laɪnz/",
        partOfSpeech: "Phrase",
        difficulty: .intermediate,
        definitionSimple: "Notice the meaning that isn't said out loud.",
        definitionDetailed: "Look for the implied message, motive, or feeling underneath the actual words.",
        literalMeaning: "Look at the empty space between printed lines.",
        intendedMeaning: "Understand what someone means without them stating it directly.",
        synonymsSimple: ["pick up on it", "read the room"],
        synonymsIntermediate: ["infer", "deduce"],
        synonymsAdvanced: ["construe the subtext"],
        antonymsSimple: ["take it literally"],
        antonymsIntermediate: ["miss the hint"],
        antonymsAdvanced: ["accept at face value"],
        examples: [
            "If you read between the lines, the email is a no.",
            "She didn't complain, but it wasn't hard to read between the lines."
        ],
        usageRegisters: [
            UsageRegister(register: "Casual conversation", example: "Read between the lines — they're not coming."),
            UsageRegister(register: "Work", example: "If you read between the lines of the announcement, the timeline slipped."),
            UsageRegister(register: "Texting", example: "read between the lines… that's a soft no")
        ],
        conversations: [
            ConversationExample(
                tone: "Casual",
                turns: [
                    ConversationTurn(speaker: "Luis", line: "They said 'we'll keep you in mind.'"),
                    ConversationTurn(speaker: "Hana", line: "Read between the lines. That's a pass.")
                ],
                whyItWorks: "People actually say this when the polite wording hid a real answer."
            )
        ],
        whenToUse: [
            "The important meaning is implied",
            "Someone is being polite, careful, or indirect",
            "You're asking a friend to notice subtext"
        ],
        whenNotToUse: [
            "When the person was explicit",
            "To accuse someone of conspiracy without evidence",
            "In a legal document"
        ],
        everydayScenario: "A 'we should get dinner sometime' that never includes a day.",
        tone: "Conversational",
        frequency: "Very common",
        origin: "English idiom",
        relatedWords: [
            RelatedWord(term: "Subtext", gloss: "The unspoken meaning"),
            RelatedWord(term: "Implication", gloss: "What follows without being said")
        ],
        isFallback: false
    )

    private static let blessing = WordAnalysis(
        pronunciation: "uh BLESS-ing in dis-GYZ",
        phoneticSpelling: "/ə ˈblɛsɪŋ ɪn dɪsˈɡaɪz/",
        partOfSpeech: "Idiom",
        difficulty: .beginner,
        definitionSimple: "Something that seemed bad at first, but turned out to help you.",
        definitionDetailed: "An apparent misfortune that eventually produces an unexpected benefit.",
        literalMeaning: "A blessing wearing a disguise.",
        intendedMeaning: "A setback that later looks like good fortune.",
        synonymsSimple: ["hidden plus", "lucky in the end"],
        synonymsIntermediate: ["silver lining"],
        synonymsAdvanced: ["felicitous reversal"],
        antonymsSimple: ["pure setback"],
        antonymsIntermediate: ["unmitigated disaster"],
        antonymsAdvanced: ["pyrrhic victory"],
        examples: [
            "Missing the train was a blessing in disguise — I met them on the next one.",
            "Losing that job felt brutal. It was a blessing in disguise."
        ],
        usageRegisters: [
            UsageRegister(register: "Casual conversation", example: "Getting sick before the trip was a blessing in disguise. I needed the pause."),
            UsageRegister(register: "Work", example: "The delay was a blessing in disguise; we caught the bug first."),
            UsageRegister(register: "Texting", example: "honestly a blessing in disguise")
        ],
        conversations: [
            ConversationExample(
                tone: "Casual",
                turns: [
                    ConversationTurn(speaker: "Kim", line: "I still can't believe they cancelled."),
                    ConversationTurn(speaker: "Devon", line: "Give it a month. It might be a blessing in disguise.")
                ],
                whyItWorks: "It's comfort language — hopeful, not smug — when the good part isn't visible yet."
            )
        ],
        whenToUse: [
            "A bad event later helped",
            "You're offering a gentler frame, not a lecture",
            "There's a real upside, not just optimism"
        ],
        whenNotToUse: [
            "Immediately after someone's serious loss",
            "To dismiss real harm",
            "When nothing good actually followed"
        ],
        everydayScenario: "A rejected application that pushed you toward the job you actually wanted.",
        tone: "Warm, colloquial",
        frequency: "Very common",
        origin: "English idiom",
        relatedWords: [
            RelatedWord(term: "Silver lining", gloss: "A bright side to a dark situation"),
            RelatedWord(term: "Hindsight", gloss: "Understanding after the fact")
        ],
        isFallback: false
    )
}
