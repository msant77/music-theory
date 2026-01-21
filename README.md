# music_theory

A Dart library for music theory - notes, intervals, chords, instruments, and transposition.

## Features

This package provides programmatic access to music theory concepts:

- **Notes** - Pitch classes, octave notation, enharmonic equivalents
- **Intervals** - Major, minor, perfect, augmented, diminished
- **Chords** - Construction, types, inversions, extensions
- **Instruments** - Definitions, tunings, voicings
- **Transposition** - Key changes, capo calculations

> **Note:** This package is currently a scaffold (v0.1.0). Features will be implemented in future releases.

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  music_theory:
    path: ../music_theory  # or git URL when published
```

Then run:

```bash
dart pub get
```

## Usage

```dart
import 'package:music_theory/music_theory.dart';

void main() {
  // Features coming soon!
  //
  // Planned API examples:
  //
  // final note = Note.parse('C#4');
  // final interval = Interval.majorThird;
  // final transposed = note.transpose(interval);
  //
  // final chord = Chord.parse('Am7');
  // print('Notes in $chord: ${chord.notes}');
}
```

## CLI

A command-line tool is included for quick music theory operations:

```bash
# Show help
dart run bin/music_theory.dart --help

# Future commands:
# dart run bin/music_theory.dart transpose C Am --semitones 2
# dart run bin/music_theory.dart voicings Am7 --instrument guitar
```

## Development

```bash
# Get dependencies
dart pub get

# Run tests
dart test

# Run CI checks
./scripts/ci.sh
```

## License

MIT License - see [LICENSE](LICENSE) for details.
