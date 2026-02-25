# Lucent — Accessible Slide Reading for Dyslexic Learners

Lucent is an accessibility-focused iPad application built with SwiftUI to support dyslexic learners in reading and understanding dense academic slide content.

This project was developed as a submission for the Apple Swift Student Challenge 2026.

Lucent transforms lecture slides into structured, readable content that reduces cognitive load and supports neurodiverse learning styles through thoughtful design and adaptive accessibility tools.

---

## Purpose

Many dyslexic students experience challenges such as:

- Long and complex sentences  
- Dense paragraph formatting  
- Losing their place while reading  
- Slower reading fluency  
- Cognitive fatigue  

Lucent addresses these challenges by restructuring slide content into clearer, more manageable formats while giving users control over how they read.

---

## Core Features

### Slide Import
- Import PDF lecture slides
- Extract text using PDFKit
- Prepare content for structured display

### Cognitive Clarity Tools
- Sentence chunking for long passages
- Adjustable text size
- Adjustable line spacing
- Adjustable letter spacing
- Focus Mode to isolate one sentence at a time
- Sentence highlighting

### Read-Aloud Support
- Text-to-speech using AVSpeechSynthesizer
- Adjustable speech rate
- Optional synchronized highlighting during playback

### Personalized Onboarding
Lucent includes a dyslexia-aware onboarding experience that:

- Explains the purpose of the app in an empowering tone
- Asks users about their reading challenges
- Automatically configures accessibility defaults
- Stores preferences locally using @AppStorage

Users can modify all preferences at any time in Settings.

---

## Technical Implementation

Lucent is built as an App Playground to comply with Apple Swift Student Challenge submission requirements.

Technologies used:

- SwiftUI for interface development  
- PDFKit for PDF text extraction  
- NaturalLanguage framework for sentence segmentation  
- AVFoundation for text-to-speech  
- @AppStorage for persistent accessibility preferences  

Architecture follows a lightweight MVVM structure suitable for Swift Playgrounds.

---

## Platform

- Designed for iPad  
- Built using Xcode App Playground template  
- Compatible with Swift Playgrounds  

No backend services are used. The app runs fully offline.

---

## How to Run

1. Open the App Playground project in Xcode.
2. Select an iPad Simulator.
3. Run the project.
4. Import a lecture PDF to test text restructuring and accessibility features.

A sample test lecture PDF can be used to validate text extraction and formatting behavior.

---

## Accessibility Considerations

Lucent was designed with accessibility-first principles:

- Large touch targets  
- High contrast text  
- Dynamic Type support  
- VoiceOver compatibility  
- Generous spacing and clean layout  

The design aims to reduce cognitive overload while maintaining a calm and focused reading experience.

---

## Project Context

This project was created for the Apple Swift Student Challenge 2026 to demonstrate thoughtful design, accessibility awareness, and technical implementation using SwiftUI within the App Playground format.

---

## License

MIT License
