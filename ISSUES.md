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

### [P1] Implement capo support `[GH: -]`
- **Status:** Planned
- **Labels:** `phase-1`, `feature`
- **Description:** Capo position affects all fret calculations
- **Acceptance Criteria:**
  - [ ] Capo position property on Instrument or separate config
  - [ ] All note calculations account for capo
  - [ ] Validation (capo can't exceed fret count)
  - [ ] Unit tests for capo scenarios

### [P1] Create `setup` CLI command `[GH: -]`
- **Status:** Planned
- **Labels:** `phase-1`, `cli`
- **Description:** Command to configure instrument for subsequent operations
- **Acceptance Criteria:**
  - [ ] `setup --instrument <name>` for presets
  - [ ] `setup --tuning "<notes>"` for custom tuning
  - [ ] `setup --capo <fret>` for capo position
  - [ ] `setup --show` to display current config
  - [ ] Config persists for session (or saved to file)
  - [ ] `--help` with beginner-friendly explanations

---

## Phase 2: Notes & Chords Basics

### [P2] Implement PitchClass and Note models `[GH: -]`
- **Status:** Planned
- **Labels:** `phase-2`, `model`
- **Description:** Core note representation - the 12 chromatic notes
- **Acceptance Criteria:**
  - [ ] `PitchClass` enum for 12 notes (C through B)
  - [ ] `Note` class with pitch class and optional octave
  - [ ] Enharmonic equivalents (C# = Db)
  - [ ] Note parsing from string ("C#", "Db", "C4")
  - [ ] Note arithmetic (add semitones)
  - [ ] Unit tests for all note operations

### [P2] Implement Interval model `[GH: -]`
- **Status:** Planned
- **Labels:** `phase-2`, `model`
- **Description:** Musical intervals - the distance between notes
- **Acceptance Criteria:**
  - [ ] `Interval` class with semitones and quality
  - [ ] Named intervals: minor 2nd, major 3rd, perfect 5th, etc.
  - [ ] Calculate interval between two notes
  - [ ] Add interval to note
  - [ ] Beginner-friendly names ("half step", "whole step")
  - [ ] Unit tests for interval arithmetic

### [P2] Implement Chord model and formulas `[GH: -]`
- **Status:** Planned
- **Labels:** `phase-2`, `model`
- **Description:** Chord types as interval patterns
- **Acceptance Criteria:**
  - [ ] `ChordType` for common types (major, minor, 7th, maj7, m7, dim, aug, sus2, sus4)
  - [ ] `Chord` class with root note and type
  - [ ] Chord formula definitions (major = root + M3 + P5)
  - [ ] Get notes in any chord
  - [ ] Chord parsing from string ("Am", "G7", "Cmaj7")
  - [ ] Unit tests for chord construction

### [P2] Create `chord` CLI command `[GH: -]`
- **Status:** Planned
- **Labels:** `phase-2`, `cli`
- **Description:** Show what notes make up a chord
- **Acceptance Criteria:**
  - [ ] `chord <name>` shows notes and formula
  - [ ] `chord <name1> <name2>` compares chords
  - [ ] Output explains intervals in plain language
  - [ ] `--help` with examples for beginners

---

## Phase 3: Chord Voicings

### [P3] Implement Voicing model `[GH: -]`
- **Status:** Planned
- **Labels:** `phase-3`, `model`
- **Description:** A specific fingering for a chord on an instrument
- **Acceptance Criteria:**
  - [ ] `Voicing` class with fret positions per string
  - [ ] Optional finger numbers
  - [ ] Barre chord notation
  - [ ] Open/muted string indicators
  - [ ] Difficulty score calculation
  - [ ] Unit tests for voicing representation

### [P3] Implement voicing calculator `[GH: -]`
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

### [P3] Create `voicings` CLI command `[GH: -]`
- **Status:** Planned
- **Labels:** `phase-3`, `cli`
- **Description:** Show fingerings for a chord
- **Acceptance Criteria:**
  - [ ] `voicings <chord>` uses current instrument setup
  - [ ] `--level beginner|intermediate|advanced` filter
  - [ ] `--limit <n>` to cap results
  - [ ] ASCII fretboard diagram output
  - [ ] `--help` with beginner-friendly explanation

---

## Phase 4: Transposition

### [P4] Implement transposition functions `[GH: -]`
- **Status:** Planned
- **Labels:** `phase-4`, `feature`
- **Description:** Shift chords up or down by semitones
- **Acceptance Criteria:**
  - [ ] Transpose single chord by semitones
  - [ ] Transpose chord progression
  - [ ] Handle enharmonic spelling (prefer sharps or flats)
  - [ ] Key-aware transposition (stay in key signature)
  - [ ] Unit tests for edge cases (wrap-around, double sharps)

### [P4] Implement capo suggestion algorithm `[GH: -]`
- **Status:** Planned
- **Labels:** `phase-4`, `feature`
- **Description:** Suggest capo positions for easier chord shapes
- **Acceptance Criteria:**
  - [ ] Given chords, suggest capo + simpler shapes
  - [ ] Rank suggestions by chord difficulty
  - [ ] Consider common open chord shapes
  - [ ] Unit tests with known examples (F → capo 1 + E shape)

### [P4] Create `transpose` CLI command `[GH: -]`
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

### [P5] Implement key detection `[GH: -]`
- **Status:** Planned
- **Labels:** `phase-5`, `feature`
- **Description:** Infer the key from a chord progression
- **Acceptance Criteria:**
  - [ ] Detect major key from chords
  - [ ] Detect relative minor
  - [ ] Handle ambiguous cases
  - [ ] Unit tests with common progressions

### [P5] Implement Roman numeral analysis `[GH: -]`
- **Status:** Planned
- **Labels:** `phase-5`, `feature`
- **Description:** Label chords with their function (I, IV, V, etc.)
- **Acceptance Criteria:**
  - [ ] Convert chord to Roman numeral given key
  - [ ] Handle secondary dominants (V/V)
  - [ ] Beginner-friendly explanations
  - [ ] Unit tests for standard progressions

### [P5] Create `analyze` CLI command `[GH: -]`
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
