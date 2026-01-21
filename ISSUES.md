# Music Theory - Planned Issues

This file tracks development tasks before they become GitHub issues.

**Process:**
1. Draft issues here with acceptance criteria
2. Create in GitHub with `gh issue create`
3. Mark `[GH: #123]` with issue number once created

**Legend:**
- `[GH: -]` = Not yet created in GitHub
- `[GH: #123]` = Created, issue number 123

---

## Phase 1: Instrument Setup

### ~~[P1] Create Instrument and StringConfig models~~ `[GH: #1]`
- **Status:** Done
- **Labels:** `phase-1`, `model`
- **Description:** Define how instruments are represented - strings, tunings, fret counts
- **Acceptance Criteria:**
  - [x] `StringConfig` class with open note and fret count
  - [x] `Instrument` class with name and list of strings
  - [x] Factory constructors for preset instruments (guitar, ukulele, bass, cavaquinho, banjo, 7-string guitar)
  - [x] Custom instrument creation support
  - [x] Unit tests for all preset configurations (62 tests)

### ~~[P1] Add tuning presets and custom tuning support~~ `[GH: #1]`
- **Status:** Done
- **Labels:** `phase-1`, `feature`
- **Description:** Common alternate tunings and ability to define custom ones
- **Acceptance Criteria:**
  - [x] Standard tuning for each preset instrument
  - [x] Common alternates: Drop D, Open G, DADGAD, Open D/E/A, Half/Whole step down, etc.
  - [x] Tuning parsing from string (e.g., "D A D G B E")
  - [x] Validation that tuning matches string count
  - [x] Unit tests for tuning operations (34 new tests, 96 total)

### ~~[P1] Implement capo support~~ `[GH: #1]`
- **Status:** Done
- **Labels:** `phase-1`, `feature`
- **Description:** Capo position affects all fret calculations
- **Acceptance Criteria:**
  - [x] Capo position property on Instrument (default 0)
  - [x] All note calculations account for capo (`soundingNoteAt` method)
  - [x] Validation (capo can't be negative or exceed fret count)
  - [x] `withCapo()` and `withoutCapo()` methods
  - [x] `playableFrets` getter accounts for capo
  - [x] Tuning methods preserve capo
  - [x] Unit tests for capo scenarios (15 tests)

### ~~[P1] Create `setup` CLI command~~ `[GH: #2]`
- **Status:** Done
- **Labels:** `phase-1`, `cli`
- **Description:** Command to configure instrument for subsequent operations
- **Acceptance Criteria:**
  - [x] `setup --instrument <name>` for presets
  - [x] `setup --tuning "<notes>"` for custom tuning
  - [x] `setup --capo <fret>` for capo position
  - [x] `setup --show` to display current config
  - [x] Config persists to `~/.config/music_theory/config.json`
  - [x] `--help` with beginner-friendly explanations
  - [x] `--list` shows available instruments and tunings
  - [x] `--reset` resets to defaults
  - [x] Unit tests (30 tests)

---

## Phase 2: Notes & Chords Basics

### ~~[P2] Implement Note model with octave~~ `[GH: #3]`
- **Status:** Done
- **Labels:** `phase-2`, `model`
- **Description:** Core note representation with octave support (PitchClass already done)
- **Acceptance Criteria:**
  - [x] `PitchClass` enum for 12 notes (C through B) - DONE
  - [x] Enharmonic equivalents (C# = Db) - DONE
  - [x] `Note` class with pitch class and octave (e.g., C4, A#3)
  - [x] Note parsing from string ("C#4", "Db3")
  - [x] Note arithmetic (add semitones, crossing octave boundaries)
  - [x] Comparison operators (Note C4 < Note D4 < Note C5)
  - [x] MIDI note number conversion
  - [x] Frequency calculation (A4 = 440 Hz)
  - [x] Unit tests for all note operations (67 tests)

### [P2] Create `note` CLI command `[GH: #16]`
- **Status:** Planned
- **Labels:** `phase-2`, `cli`
- **Description:** CLI command to inspect and play musical notes
- **Acceptance Criteria:**
  - [ ] `note <name>` displays note info (pitch class, octave, MIDI number, frequency)
  - [ ] `note <name> --play` plays the note audio (platform-dependent)
  - [ ] `note <name> --transpose <semitones>` shows transposed note
  - [ ] `note <name1> <name2>` shows interval between notes
  - [ ] `note --midi <number>` converts MIDI number to note
  - [ ] `--help` with beginner-friendly explanations

### ~~[P2] Implement Interval model~~ `[GH: #4]`
- **Status:** Done
- **Labels:** `phase-2`, `model`
- **Description:** Musical intervals - the distance between notes
- **Acceptance Criteria:**
  - [x] `Interval` class with semitones and quality
  - [x] Named intervals: minor 2nd, major 3rd, perfect 5th, etc.
  - [x] Calculate interval between two notes
  - [x] Add interval to note (addTo, subtractFrom)
  - [x] Beginner-friendly names ("half step", "whole step")
  - [x] Interval inversion (M3 ↔ m6)
  - [x] Compound intervals (9th, 10th, etc.)
  - [x] Extension methods on Note and PitchClass
  - [x] Unit tests for interval arithmetic (59 tests)

### ~~[P2] Implement Chord model and formulas~~ `[GH: #5]`
- **Status:** Done
- **Labels:** `phase-2`, `model`
- **Description:** Chord types as interval patterns
- **Acceptance Criteria:**
  - [x] `ChordType` for common types (major, minor, 7th, maj7, m7, dim, aug, sus2, sus4)
  - [x] `Chord` class with root note and type
  - [x] Chord formula definitions (major = root + M3 + P5)
  - [x] Get notes in any chord
  - [x] Chord parsing from string ("Am", "G7", "Cmaj7")
  - [x] Unit tests for chord construction (72 tests)

### ~~[P2] Create `chord` CLI command~~ `[GH: #6]`
- **Status:** Done
- **Labels:** `phase-2`, `cli`
- **Description:** Show what notes make up a chord
- **Acceptance Criteria:**
  - [x] `chord <name>` shows notes and formula
  - [x] `chord <name1> <name2>` compares chords
  - [x] Output explains intervals in plain language
  - [x] `--help` with examples for beginners
  - [x] Unit tests (25 tests)

---

## Phase 3: Chord Voicings

### ~~[P3] Implement Voicing model~~ `[GH: #7]`
- **Status:** Done
- **Labels:** `phase-3`, `model`
- **Description:** A specific fingering for a chord on an instrument
- **Acceptance Criteria:**
  - [x] `Voicing` class with fret positions per string
  - [x] Optional finger numbers
  - [x] Barre chord notation
  - [x] Open/muted string indicators
  - [x] Difficulty score calculation
  - [x] Unit tests for voicing representation (59 tests)

### [P3] Implement voicing calculator `[GH: #8]`
- **Status:** Planned
- **Labels:** `phase-3`, `feature`
- **Description:** Algorithm to find all ways to play a chord
- **Acceptance Criteria:**
  - [ ] Find all voicings for a chord on an instrument
  - [ ] Filter by playability (max finger stretch)
  - [ ] Filter by difficulty level (beginner/intermediate/advanced)
  - [ ] Rank voicings by ease of playing
  - [ ] Known chord shapes match expected output
  - [ ] Unit tests with standard chord shapes

### [P3] Create `voicings` CLI command `[GH: #9]`
- **Status:** Planned
- **Labels:** `phase-3`, `cli`
- **Description:** Show fingerings for a chord
- **Acceptance Criteria:**
  - [ ] `voicings <chord>` uses current instrument setup
  - [ ] `--level beginner|intermediate|advanced` filter
  - [ ] `--limit <n>` to cap results
  - [ ] ASCII fretboard diagram output with fret numbers
  - [ ] `--help` with beginner-friendly explanation
- **Notes:** Focus on fretted instruments (guitar, ukulele, etc.), not piano

---

## Phase 4: Transposition

### [P4] Implement transposition functions `[GH: #10]`
- **Status:** Planned
- **Labels:** `phase-4`, `feature`
- **Description:** Shift chords up or down by semitones
- **Acceptance Criteria:**
  - [ ] Transpose single chord by semitones
  - [ ] Transpose chord progression
  - [ ] Handle enharmonic spelling (prefer sharps or flats)
  - [ ] Key-aware transposition (stay in key signature)
  - [ ] Unit tests for edge cases (wrap-around, double sharps)

### [P4] Implement capo suggestion algorithm `[GH: #11]`
- **Status:** Planned
- **Labels:** `phase-4`, `feature`
- **Description:** Suggest capo positions for easier chord shapes
- **Acceptance Criteria:**
  - [ ] Given chords, suggest capo + simpler shapes
  - [ ] Rank suggestions by chord difficulty
  - [ ] Consider common open chord shapes
  - [ ] Unit tests with known examples (F → capo 1 + E shape)

### [P4] Create `transpose` CLI command `[GH: #12]`
- **Status:** Planned
- **Labels:** `phase-4`, `cli`
- **Description:** Change the key of chords
- **Acceptance Criteria:**
  - [ ] `transpose <chord> --up <n>` or `--down <n>`
  - [ ] `transpose "<progression>" --up <n>` for multiple chords
  - [ ] `--suggest-capo` for easier shapes
  - [ ] `--help` explaining when to use transposition

---

## Phase 5: Simple Analysis (Future)

### [P5] Implement key detection `[GH: #13]`
- **Status:** Planned
- **Labels:** `phase-5`, `feature`
- **Description:** Infer the key from a chord progression
- **Acceptance Criteria:**
  - [ ] Detect major key from chords
  - [ ] Detect relative minor
  - [ ] Handle ambiguous cases
  - [ ] Unit tests with common progressions

### [P5] Implement Roman numeral analysis `[GH: #14]`
- **Status:** Planned
- **Labels:** `phase-5`, `feature`
- **Description:** Label chords with their function (I, IV, V, etc.)
- **Acceptance Criteria:**
  - [ ] Convert chord to Roman numeral given key
  - [ ] Handle secondary dominants (V/V)
  - [ ] Beginner-friendly explanations
  - [ ] Unit tests for standard progressions

### [P5] Create `analyze` CLI command `[GH: #15]`
- **Status:** Planned
- **Labels:** `phase-5`, `cli`
- **Description:** Understand a chord progression
- **Acceptance Criteria:**
  - [ ] `analyze "<progression>"` shows key and numerals
  - [ ] `--key-only` for just key detection
  - [ ] Name common patterns ("pop progression", "12-bar blues")
  - [ ] `--help` with music theory basics

---

## Scaffold (Done)

### ✅ Create music_theory package scaffold `[GH: -]`
- **Status:** Done
- **Description:** Initial package structure
- **Completed:**
  - [x] Package at `../music_theory`
  - [x] pubspec.yaml with package config
  - [x] Public API exports in `music_theory.dart`
  - [x] Test setup with `dart_test.yaml`
  - [x] CI script (`scripts/ci.sh`)
  - [x] analysis_options.yaml with strict lints
  - [x] CLI entry point with `--help` and `--version`

---

## Label Definitions

| Label | Description |
|-------|-------------|
| `phase-1` to `phase-5` | Development phase |
| `model` | Data model/class |
| `feature` | New functionality |
| `cli` | Command-line interface |
| `bug` | Something broken |
| `docs` | Documentation |
| `test` | Test coverage |
