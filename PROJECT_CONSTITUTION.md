# Project Constitution for music_theory

Foundational rules governing development of this Dart package. These ensure quality, consistency, and a great experience for users learning music theory.

---

## 1. Guiding Principles

### 1.1 Audience First

This package is for **beginners and hobbyists**, not music theory professors.

- **Use plain language** - "half step" alongside "semitone"
- **Explain the "why"** - Don't just compute, teach
- **Provide examples** - Show real chords and songs people know
- **Fail helpfully** - Error messages should guide, not confuse

### 1.2 Instrument-Centric Design

Everything flows from the instrument setup.

- **Setup first** - Users configure their instrument before other operations
- **Context-aware** - Commands use the configured instrument automatically
- **Practical output** - Show fingerings, not just abstract note names

### 1.3 Progressive Complexity

Start simple, allow depth.

- **Defaults work** - Commands should "just work" without options
- **Options add power** - Advanced users can customize
- **Levels matter** - Beginner/intermediate/advanced filters everywhere

---

## 2. Code Quality Standards

### 2.1 Testing Requirements

- **Minimum 95% code coverage** (enforced in CI)
- **Unit tests** for every public method
- **Real-world tests** - Use actual chord shapes musicians would recognize
- **Edge cases** - Enharmonics, unusual tunings, extreme transpositions

### 2.2 Lint Rules

We use strict analysis. See `analysis_options.yaml`.

| Category | Purpose |
|----------|---------|
| Type Safety | Catch errors at compile time |
| Error Prevention | No resource leaks |
| Style | Consistent, readable code |
| Documentation | All public APIs documented |

**Zero Tolerance:**
- No analyzer warnings in CI
- No `// ignore:` without documented justification
- No `dynamic` types without explanation

### 2.3 Documentation Standards

Every public API must have:
- **One-sentence summary** - What it does
- **Parameters explained** - What each one means
- **Example** - How to use it
- **Beginner note** (where helpful) - Plain-language explanation

```dart
/// Transposes a chord up or down by semitones.
///
/// [semitones] can be positive (up) or negative (down).
///
/// Example:
/// ```dart
/// final am = Chord.parse('Am');
/// final bm = transpose(am, 2); // Am → Bm (up 2 semitones)
/// ```
///
/// **For beginners:** Transposing means shifting all notes by the same
/// amount. If a song is too high for your voice, transpose down!
Chord transpose(Chord chord, int semitones);
```

---

## 3. API Design Rules

### 3.1 Immutability

All model classes should be immutable.

```dart
// Good
class Note {
  final PitchClass pitchClass;
  final int? octave;
  const Note(this.pitchClass, [this.octave]);
}

// Bad - mutable state
class Note {
  PitchClass pitchClass; // Not final!
}
```

### 3.2 Parsing

Provide `parse` factory constructors for string input.

```dart
class Chord {
  factory Chord.parse(String input); // "Am7" → Chord
}

class Note {
  factory Note.parse(String input); // "C#4" → Note
}
```

### 3.3 Error Messages

Errors should help users fix the problem.

```dart
// Good
throw FormatException(
  'Invalid chord: "$input". '
  'Expected format like "Am", "G7", or "Cmaj7". '
  'The root must be A-G, optionally followed by # or b.'
);

// Bad
throw FormatException('Parse error');
```

### 3.4 Named Constants

Use named constants for musical concepts.

```dart
// Good
static const minorSecond = Interval._(1, 'minor 2nd', 'half step');
static const majorThird = Interval._(4, 'major 3rd', '2 whole steps');

// Bad - magic numbers
return Interval(4);
```

---

## 4. CLI Design Rules

### 4.1 Command Structure

```
music_theory <command> [arguments] [options]
```

### 4.2 Help Text

Every command must have:
- Brief description
- Usage example
- Option explanations
- "For beginners" section where appropriate

### 4.3 Output Format

- **Human-readable by default** - Formatted for terminal
- **Machine-readable option** - `--json` for programmatic use
- **Diagrams where helpful** - ASCII fretboard, chord boxes

### 4.4 Error Handling

- Exit code 0 for success
- Exit code 64 for usage errors (bad arguments)
- Exit code 65 for data errors (invalid input)
- Helpful message to stderr, not stack traces

---

## 5. Musical Correctness

### 5.1 Enharmonic Handling

Respect that C# and Db are the same pitch but different notes.

- Store the user's preferred spelling
- Default to sharps for sharp keys, flats for flat keys
- Allow override with options

### 5.2 Standard Voicings

Include voicings that musicians actually use.

- Open chord shapes for beginners
- Barre chord shapes for intermediate
- Jazz voicings for advanced
- Verify against chord dictionaries

### 5.3 Instrument Accuracy

Preset instruments must match real-world specs.

- Standard guitar: 6 strings, EADGBE, 21 frets
- Verify tunings against manufacturer standards
- Document sources for unusual instruments

---

## 6. Security Rules

### 6.1 Input Validation

- Validate all user input before processing
- Reject unreasonable values (negative frets, 100-string guitars)
- Sanitize output for terminal (escape sequences)

### 6.2 No Network Access

This package should work entirely offline.

- No telemetry
- No external API calls
- All data bundled in package

### 6.3 Dependencies

- Minimal dependencies (currently just `args` for CLI)
- Audit before adding new packages
- No native code dependencies

---

## 7. Versioning

Follow [Semantic Versioning](https://semver.org/):

- **MAJOR** (1.x → 2.0): Breaking API changes
- **MINOR** (1.0 → 1.1): New features, backward compatible
- **PATCH** (1.0.0 → 1.0.1): Bug fixes only

---

## 8. Local CI

Run before every commit:

```bash
./scripts/ci.sh          # Full suite
./scripts/ci.sh quick    # Format + analyze only
./scripts/ci.sh test     # Tests with coverage
```

Setup pre-commit hooks:
```bash
./scripts/setup-hooks.sh
```

---

## 9. Review Checklist

For every PR, verify:

- [ ] Tests pass with 95%+ coverage
- [ ] No analyzer warnings
- [ ] Public APIs documented
- [ ] Error messages are helpful
- [ ] Beginner-friendly language used
- [ ] Works with configured instrument context
- [ ] CLI help text updated if commands changed

---

*Last updated: 2026-01-21*
*Version: 1.0*
