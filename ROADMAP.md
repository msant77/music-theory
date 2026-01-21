# Music Theory Development Roadmap

A Dart package that makes music theory accessible to beginners and hobbyists. Whether you're learning guitar, exploring chord progressions, or just curious about how music works, this library provides simple tools to understand and work with musical concepts.

---

## Who Is This For?

- **Beginners** learning their first instrument
- **Hobbyist musicians** who want to understand the "why" behind chords
- **Students** studying music theory basics
- **App developers** building tools for musicians

---

## Phase 1: Instrument Setup

**Goal:** Let users define their instrument so everything else "just works."

The instrument setup is the foundation. Once you tell the library what instrument you play (guitar, ukulele, bass, etc.) and how it's tuned, all other features automatically adapt.

### Features

- **Pick your instrument** - Choose from presets or define your own
- **Custom tunings** - Drop D? Open G? DADGAD? No problem
- **Capo support** - Set a capo position and all calculations adjust

### Why This Matters

Different instruments have different numbers of strings, tunings, and fret counts. A C chord on guitar looks completely different from a C chord on ukulele. By setting up your instrument first, the library gives you relevant results.

### Preset Instruments

| Instrument | Strings | Standard Tuning | Frets |
|------------|---------|-----------------|-------|
| Guitar | 6 | E A D G B E | 21 |
| 7-String Guitar | 7 | B E A D G B E | 24 |
| Bass | 4 | E A D G | 20 |
| Ukulele | 4 | G C E A | 12 |
| Cavaquinho | 4 | D G B D | 17 |
| Banjo (5-string) | 5 | G D G B D | 22 |

### CLI Command: `setup`

```bash
# Interactive setup
music_theory setup

# Quick setup with preset
music_theory setup --instrument guitar
music_theory setup --instrument ukulele --capo 2

# Custom tuning
music_theory setup --instrument guitar --tuning "D A D G B E"

# Show current setup
music_theory setup --show
```

Once configured, other commands use this setup automatically.

---

## Phase 2: Notes & Chords Basics

**Goal:** Understand what notes make up a chord.

### Features

- **Note names** - Learn that C, C#, D, D#, E, F, F#, G, G#, A, A#, B are the 12 notes
- **Chord spelling** - See what notes are in any chord (Am = A, C, E)
- **Chord types** - Major, minor, 7th, and why they sound different

### What You'll Learn

Ever wonder why Am sounds "sad" and A sounds "happy"? It's just one note difference! This phase helps you see inside chords.

### CLI Commands

```bash
# What notes are in this chord?
music_theory chord Am
# Output: Am = A, C, E (minor triad: root, minor 3rd, perfect 5th)

# Compare two chords
music_theory chord A Am
# Output:
#   A  = A, C#, E (major)
#   Am = A, C,  E (minor)
#   Difference: C# vs C (the 3rd is lowered in minor)
```

---

## Phase 3: Chord Voicings

**Goal:** Show you WHERE to put your fingers.

### Features

- **Fingering diagrams** - Multiple ways to play the same chord
- **Difficulty ranking** - Start with easy shapes, progress to harder ones
- **Position variety** - Open chords, barre chords, up-the-neck voicings

### Why Multiple Voicings?

There are many ways to play the same chord! Some are easier for beginners (open chords near the nut), others are better for certain musical contexts (jazz voicings, power chords).

### CLI Commands

```bash
# Show voicings for a chord (uses your instrument setup)
music_theory voicings Am

# Filter by difficulty
music_theory voicings Am --level beginner
music_theory voicings Am --level intermediate

# Show a specific number of options
music_theory voicings Am --limit 5
```

---

## Phase 4: Transposition

**Goal:** Change the key of a song to match your voice or skill level.

### Features

- **Shift by semitones** - Move all chords up or down
- **Capo suggestions** - "Use capo on fret 2 to play in original key with easier shapes"
- **Key-friendly output** - Shows sharps or flats based on the new key

### Common Use Cases

- Song is too high/low for your voice? Transpose it
- Original uses hard barre chords? Transpose to find easier shapes
- Want to play along with a recording in a different key? Transpose your chart

### CLI Commands

```bash
# Transpose a chord
music_theory transpose Am --up 2
# Output: Bm

# Transpose a progression
music_theory transpose "Am F C G" --up 5
# Output: Dm Bb F C

# Find capo position for easier chords
music_theory transpose "F Bb C" --suggest-capo
# Output: Capo on fret 3, play as D G A (easier shapes!)
```

---

## Phase 5: Simple Analysis (Future)

**Goal:** Understand why certain chords sound good together.

### Features

- **Chord functions** - "This is the I chord, this is the V chord"
- **Common progressions** - Recognize patterns like I-V-vi-IV
- **Key detection** - "These chords suggest you're in the key of G"

### Why This Helps

When you understand that most pop songs use the same 4-chord pattern (I-V-vi-IV), suddenly hundreds of songs become easier to learn and remember.

### CLI Commands

```bash
# Analyze a progression
music_theory analyze "G D Em C"
# Output:
#   Key: G major
#   Progression: I - V - vi - IV
#   This is the "pop progression" used in countless hits!

# What key am I in?
music_theory analyze "Am F C G" --key-only
# Output: C major (or A minor - they share the same chords)
```

---

## Summary

| Phase | What You Get | Difficulty |
|-------|--------------|------------|
| 1 | Set up your instrument | Easy |
| 2 | See what's inside chords | Easy |
| 3 | Learn where to put your fingers | Easy |
| 4 | Change keys to suit your needs | Medium |
| 5 | Understand why chords work together | Medium |

**First Release (v0.1):** Phases 1-3 (Setup + Notes + Voicings)

**Full Release (v1.0):** All phases

---

## Part of the Chordo Family

| Project | What It Does |
|---------|--------------|
| **chordo** | App for viewing song sheets with chords |
| **iclf-parser** | Reads song files in ICLF format |
| **music_theory** | This package - the brain for music concepts |

When you tap a chord in the chordo app, music_theory figures out how to display it for your instrument.
