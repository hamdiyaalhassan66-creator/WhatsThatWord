# What's That Word?

A native iPhone app for collecting words you didn’t know — then learning what they mean, when to use them, and how people actually say them.

This is a SwiftUI + SwiftData app (iOS 17+). Open `WhatsThatWord.xcodeproj` in Xcode on a Mac and run it on the iPhone simulator or a device.

## Open in Xcode

1. Copy this folder to a Mac if you are not already on one.
2. Open `WhatsThatWord.xcodeproj`.
3. Choose an iPhone simulator.
4. Press Run.

The first launch shows a short onboarding, then a seeded notebook (ubiquitous, nonchalant, serendipity, and the rest of the sample set).

## What this version does

- **Home** — greeting, progress, review queue, recently added, word of the day
- **Add word** — sheet, paste, sentence extraction, local analysis
- **Word detail** — meaning, real usage, conversations, synonyms/antonyms, notes, status
- **My words** — search, filter, sort, swipe actions, bookmarks
- **Review** — one word at a time, with persistence
- **Settings** — appearance, daily word, export

Analysis lives behind `WordAnalysisServing`. Today `LocalWordAnalysisService` + `WordCatalog` fill that in. Later you can swap in a network AI client without rewriting the screens.

Words are stored on device with SwiftData.
