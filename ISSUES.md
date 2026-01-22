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

### ~~[P3] Implement voicing calculator~~ `[GH: #8]`
- **Status:** Done
- **Labels:** `phase-3`, `feature`
- **Description:** Algorithm to find all ways to play a chord
- **Acceptance Criteria:**
  - [x] Find all voicings for a chord on an instrument
  - [x] Filter by playability (max finger stretch)
  - [x] Filter by difficulty level (beginner/intermediate/advanced)
  - [x] Rank voicings by ease of playing
  - [x] Known chord shapes match expected output (C, G, D, Am, Em)
  - [x] Unit tests with standard chord shapes (26 tests)

### ~~[P3] Create `voicings` CLI command~~ `[GH: #9]`
- **Status:** Done
- **Labels:** `phase-3`, `cli`
- **Description:** Show fingerings for a chord
- **Acceptance Criteria:**
  - [x] `voicings <chord>` uses current instrument setup
  - [x] `--level beginner|intermediate|advanced` filter
  - [x] `--limit <n>` to cap results
  - [x] ASCII fretboard diagram output with fret numbers
  - [x] `--help` with beginner-friendly explanation
  - [x] `--compact` mode for text-only output
  - [x] Unit tests (36 tests)
- **Notes:** Focus on fretted instruments (guitar, ukulele, etc.), not piano

### ~~[P3] Add diagram orientation preference~~ `[GH: #17]`
- **Status:** Done
- **Labels:** `phase-3`, `cli`, `feature`
- **Description:** Allow users to choose between vertical and horizontal fretboard diagrams
- **Acceptance Criteria:**
  - [x] Change default orientation to vertical (traditional chord diagram style)
  - [x] Add `DiagramOrientation` enum (vertical, horizontal)
  - [x] Add `diagramOrientation` field to `MusicTheoryConfig`
  - [x] Add `--orientation` option to `setup` command to persist preference
  - [x] Add `--orientation` option to `voicings` command to override config per-command
  - [x] Update tests for new default orientation

---

## Phase 4: Transposition

### ~~[P4] Implement transposition functions~~ `[GH: #10]`
- **Status:** Done
- **Labels:** `phase-4`, `feature`
- **Description:** Shift chords up or down by semitones
- **Acceptance Criteria:**
  - [x] Transpose single chord by semitones
  - [x] Transpose chord progression (`ChordProgression` class)
  - [x] Handle enharmonic spelling (prefer sharps or flats via `SpellingPreference`)
  - [x] Key-aware transposition (`Key` class with scale, diatonic chords, relative/parallel keys)
  - [x] Unit tests for edge cases (wrap-around, double sharps) - 86 tests

### ~~[P4] Implement capo suggestion algorithm~~ `[GH: #11]`
- **Status:** Done
- **Labels:** `phase-4`, `feature`
- **Description:** Suggest capo positions for easier chord shapes
- **Acceptance Criteria:**
  - [x] Given chords, suggest capo + simpler shapes (`CapoSuggester` class)
  - [x] Rank suggestions by chord difficulty (sorted by difficulty score)
  - [x] Consider common open chord shapes (C, G, D, E, A, Am, Em, Dm)
  - [x] Unit tests with known examples (F → capo 1 + E shape) - 31 tests

### ~~[P4] Create `transpose` CLI command~~ `[GH: #12]`
- **Status:** Done
- **Labels:** `phase-4`, `cli`
- **Description:** Change the key of chords
- **Acceptance Criteria:**
  - [x] `transpose <chord> --up <n>` or `--down <n>`
  - [x] `transpose "<progression>" --up <n>` for multiple chords
  - [x] `--suggest-capo` for easier shapes (uses CapoSuggester)
  - [x] `--spelling sharps|flats` for enharmonic preference
  - [x] `--help` explaining when to use transposition - 22 tests

---

## Phase 5: Simple Analysis

### ~~[P5] Implement key detection~~ `[GH: #13]`
- **Status:** Done
- **Labels:** `phase-5`, `feature`
- **Description:** Infer the key from a chord progression
- **Acceptance Criteria:**
  - [x] Detect major key from chords
  - [x] Detect relative minor
  - [x] Handle ambiguous cases (confidence scoring, first-chord tonic bonus)
  - [x] Unit tests with common progressions - 47 tests

### ~~[P5] Implement Roman numeral analysis~~ `[GH: #14]`
- **Status:** Done
- **Labels:** `phase-5`, `feature`
- **Description:** Label chords with their function (I, IV, V, etc.)
- **Acceptance Criteria:**
  - [x] Convert chord to Roman numeral given key
  - [x] Handle non-diatonic chords (chromatic alterations)
  - [x] Beginner-friendly explanations (function names)
  - [x] Pattern recognition (50s, pop, ii-V-I, Andalusian, etc.)
  - [x] Unit tests for standard progressions - 47 tests

### ~~[P5] Create `analyze` CLI command~~ `[GH: #15]`
- **Status:** Done
- **Labels:** `phase-5`, `cli`
- **Description:** Understand a chord progression
- **Acceptance Criteria:**
  - [x] `analyze "<progression>"` shows key and numerals
  - [x] `--key-only` for just key detection
  - [x] `--key` to analyze in a specific key
  - [x] Name common patterns ("pop progression", "ii-V-I", etc.)
  - [x] `--help` with music theory basics - 21 tests

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
